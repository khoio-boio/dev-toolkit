param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$GroupId = "com.khoi",

    [Alias("j")]
    [ValidateSet(17, 21)]
    [int]$JavaVersion = 17
)

function Import-DotEnv {
    param([string]$Path)

    if (-not (Test-Path $Path)) { return }

    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        if ($line.Length -eq 0) { return }          # skip blanks
        if ($line.StartsWith("#")) { return }       # skip comments

        $parts = $line -split "=", 2
        if ($parts.Count -ne 2) { return }

        $name  = $parts[0].Trim()
        $value = $parts[1].Trim()

        # sets env var for this PowerShell process (and anything it launches)
        [System.Environment]::SetEnvironmentVariable($name, $value)
    }
}

Import-DotEnv (Join-Path $PSScriptRoot ".env")

$envFile = Join-Path $PSScriptRoot ".env"

if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*#' -or $_ -match '^\s*$') { return }
        $name, $value = $_ -split '=', 2
        [System.Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim())
    }
}

$ErrorActionPreference = "Stop"

$Root = $env:JAVA_ROOT
$projectPath = Join-Path $Root $Name

if (Test-Path $projectPath) {
    throw "Project already exists: $projectPath"
}

# ----- Create folder layout -----
$srcMainJava = Join-Path $projectPath "src\main\java"
$srcTestJava = Join-Path $projectPath "src\test\java"
New-Item -ItemType Directory -Path $srcMainJava -Force | Out-Null
New-Item -ItemType Directory -Path $srcTestJava -Force | Out-Null

# Convert groupId into a folder path: com.khoi -> com\khoi
$pkgPath = $GroupId.Replace(".", "\")
$pkgDir  = Join-Path $srcMainJava $pkgPath
New-Item -ItemType Directory -Path $pkgDir -Force | Out-Null

# ----- App.java -----
# Why package line? It matches the folder structure so Java can locate the class.
$appJava = @"
package $GroupId;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello from $Name");
    }
}
"@
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($appPath,  $appJava,     $Utf8NoBom)
[System.IO.File]::WriteAllText($testPath, $appTestJava, $Utf8NoBom)

# ----- AppTest.java (JUnit scaffolding) -----
# Why: proves mvn test works and gives you a template to copy for real tests.
$testPkgDir = Join-Path $srcTestJava $pkgPath
New-Item -ItemType Directory -Path $testPkgDir -Force | Out-Null

$appTestJava = @"
package $GroupId;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class AppTest {

    @Test
    void sanityCheck() {
        assertTrue(true);
    }
}
"@
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($appPath,  $appJava,     $Utf8NoBom)
[System.IO.File]::WriteAllText($testPath, $appTestJava, $Utf8NoBom)

# ----- pom.xml -----
# Why properties? It pins the Java version so Maven doesn't guess.
$pom = @"
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">

  <modelVersion>4.0.0</modelVersion>

  <groupId>$GroupId</groupId>
  <artifactId>$Name</artifactId>
  <version>1.0-SNAPSHOT</version>

  <properties>
    <maven.compiler.source>$JavaVersion</maven.compiler.source>
    <maven.compiler.target>$JavaVersion</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencies>
    <!-- JUnit 5 (Jupiter) for unit testing -->
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter</artifactId>
      <version>5.10.2</version>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <!-- Surefire runs unit tests; this config ensures JUnit 5 tests are discovered -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.2.5</version>
      </plugin>
    </plugins>
  </build>

</project>
"@

Set-Content -Path (Join-Path $projectPath "pom.xml") -Value $pom -Encoding UTF8

# ----- Git init + .gitignore -----
git init $projectPath | Out-Null

$gitignore = @"
# Maven build output
target/

# IDE/editor noise
.vscode/
.idea/

# OS noise
.DS_Store
Thumbs.db
"@
Set-Content -Path (Join-Path $projectPath ".gitignore") -Value $gitignore -Encoding UTF8

# ----- Open in VS Code -----
code $projectPath