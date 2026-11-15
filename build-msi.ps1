#Requires -Version 7
# Builds dist\ScreenScope.exe with build.bat, then a per-user installer:
# dist\ScreenScope-<version>-x64.msi. Needs WiX 7 (dotnet tool install -g wix). The version is the
# latest tag unless given.
param([string]$Version)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not $Version) {
    $Version = (git describe --tags --abbrev=0) -replace '^v', ''
    while ($Version.Split('.').Count -lt 3) { $Version += '.0' }
}

# build.bat ignores PyInstaller's exit code: a failed build would leave the previous exe to package.
Remove-Item dist\ScreenScope.exe -ErrorAction SilentlyContinue
# .\ because cmd may be told not to search the current folder (NoDefaultCurrentDirectoryInExePath);
# nul answers the final pause.
cmd /c ".\build.bat < nul"
if (-not (Test-Path dist\ScreenScope.exe)) { throw 'build.bat did not produce dist\ScreenScope.exe' }

wix build installer\screenscope.wxs -arch x64 -d Version=$Version -o "dist\ScreenScope-$Version-x64.msi"
if ($LASTEXITCODE) { exit $LASTEXITCODE }
"dist\ScreenScope-$Version-x64.msi"
