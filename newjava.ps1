param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$GroupId = "com.khoi",

    [Alias("j")]
    [ValidateSet(8, 11, 17, 21)]
    [int]$JavaVersion = 17
)


$ErrorActionPreference = "Stop"

$Root = "C:\Users\profile 1\dev\java"
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
Set-Content -Path (Join-Path $pkgDir "App.java") -Value $appJava -Encoding UTF8

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
  </properties>

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