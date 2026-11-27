# PowerShell dev script for LED Banner (Flutter / Android)
# Equivalent of Makefile for Windows PowerShell

param(
    [Parameter(Position = 0)]
    [string]$Command = "help",

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

function Read-LocalProperties {
    $props = @{}
    $localPropsPath = Join-Path $ProjectRoot "android\local.properties"
    if (Test-Path $localPropsPath) {
        foreach ($line in Get-Content $localPropsPath -Encoding UTF8) {
            $trimmed = $line.Trim()
            if (-not $trimmed -or $trimmed.StartsWith("#")) { continue }
            $idx = $trimmed.IndexOf("=")
            if ($idx -gt 0) {
                $key = $trimmed.Substring(0, $idx).Trim()
                $val = $trimmed.Substring($idx + 1).Trim() -replace "\\\\", "\"
                $props[$key] = $val
            }
        }
    }
    return $props
}

$LocalProps = Read-LocalProperties

function Resolve-Tool {
    param(
        [string]$Name,
        [string]$FallbackPath
    )
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    if ($FallbackPath -and (Test-Path $FallbackPath)) { return $FallbackPath }
    throw "Could not find '$Name'. Ensure it is in PATH or configured in android\local.properties."
}

$FlutterSdk = $LocalProps["flutter.sdk"]
$AndroidSdk = $LocalProps["sdk.dir"]

$FlutterFallback = if ($FlutterSdk) { Join-Path $FlutterSdk "bin\flutter.bat" } else { $null }
$DartFallback = if ($FlutterSdk) { Join-Path $FlutterSdk "bin\dart.bat" } else { $null }
$AdbFallback = if ($AndroidSdk) { Join-Path $AndroidSdk "platform-tools\adb.exe" } else { $null }

if (-not $env:JAVA_HOME) {
    $DefaultJbr = "C:\Program Files\Android\Android Studio\jbr"
    if (Test-Path $DefaultJbr) {
        $env:JAVA_HOME = $DefaultJbr
    }
}

function Get-FlutterExe { Resolve-Tool -Name "flutter" -FallbackPath $FlutterFallback }
function Get-DartExe    { Resolve-Tool -Name "dart"    -FallbackPath $DartFallback }
function Get-AdbExe     { Resolve-Tool -Name "adb"     -FallbackPath $AdbFallback }

function Invoke-Step {
    param(
        [string]$Executable,
        [string[]]$Arguments = @()
    )
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

function Show-Help {
    Write-Host "📱 LED Banner Project Script (Flutter / Android)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\dev.ps1 <command> [extra args]"
    Write-Host ""
    Write-Host "Available commands:"
    Write-Host "  help            - Hiển thị hướng dẫn này"
    Write-Host "  setup           - Cài đặt dependencies (pub get + gen-l10n)"
    Write-Host "  l10n            - Sinh lại file đa ngôn ngữ (flutter gen-l10n)"
    Write-Host "  clean           - Dọn dẹp thư mục build"
    Write-Host "  run             - Chạy app trên thiết bị kết nối (flutter run)"
    Write-Host "  dev             - Chạy chế độ dev (Hot Reload & Debug Log)"
    Write-Host "  log             - Xem log trực tiếp của app (flutter logs)"
    Write-Host "  test            - Chạy toàn bộ unit & widget tests"
    Write-Host "  test-ui         - Chạy widget/UI tests (test/app_widget_test.dart)"
    Write-Host "  analyze         - Chạy phân tích tĩnh (flutter analyze)"
    Write-Host "  format          - Format toàn bộ code Dart trong lib & test"
    Write-Host "  format-check    - Kiểm tra format code không sửa file"
    Write-Host "  check           - Chạy format-check + analyze + test"
    Write-Host "  build-debug     - Build Android APK (Debug)"
    Write-Host "  build-release   - Build Android APK (Release)"
    Write-Host "  build-appbundle - Build Android App Bundle (AAB Release)"
    Write-Host "  info            - Hiển thị thông tin Flutter, Java & Doctor"
    Write-Host "  devices         - Liệt kê các thiết bị đang kết nối"
    Write-Host "  kill            - Dừng Gradle daemon và ADB server"
    Write-Host "  reset           - Reset toàn bộ cache (.dart_tool, build, .gradle) & setup lại"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\dev.ps1 check"
    Write-Host "  .\dev.ps1 run -d emulator-5554"
}

switch ($Command.ToLowerInvariant()) {
    "help" {
        Show-Help
    }
    "setup" {
        Write-Host "🚀 Setting up project..." -ForegroundColor Green
        $flutter = Get-FlutterExe
        Invoke-Step $flutter @("pub", "get")
        Invoke-Step $flutter @("gen-l10n")
        Write-Host "✅ Dependencies downloaded and l10n generated" -ForegroundColor Green
        Write-Host "🎉 Setup complete!" -ForegroundColor Green
    }
    "l10n" {
        Write-Host "🌐 Generating localization files..." -ForegroundColor Green
        Invoke-Step (Get-FlutterExe) @("gen-l10n")
        Write-Host "✅ Localization files generated" -ForegroundColor Green
    }
    "clean" {
        Write-Host "🧹 Cleaning project..." -ForegroundColor Yellow
        Invoke-Step (Get-FlutterExe) @("clean")
        Write-Host "✅ Clean complete" -ForegroundColor Green
    }
    "run" {
        Write-Host "🚀 Running app on device..." -ForegroundColor Green
        $cmdArgs = @("run") + $ExtraArgs
        Invoke-Step (Get-FlutterExe) $cmdArgs
    }
    "dev" {
        Write-Host "📱 Starting dev session (Hot Reload & Logs)..." -ForegroundColor Green
        $cmdArgs = @("run") + $ExtraArgs
        Invoke-Step (Get-FlutterExe) $cmdArgs
    }
    "log" {
        Write-Host "📜 Opening Flutter logs... (Press Ctrl+C to exit)" -ForegroundColor Cyan
        $cmdArgs = @("logs") + $ExtraArgs
        Invoke-Step (Get-FlutterExe) $cmdArgs
    }
    "test" {
        Write-Host "🧪 Running unit & widget tests..." -ForegroundColor Cyan
        $cmdArgs = @("test") + $ExtraArgs
        Invoke-Step (Get-FlutterExe) $cmdArgs
        Write-Host "✅ All tests complete" -ForegroundColor Green
    }
    "test-ui" {
        Write-Host "📸 Running widget/UI tests..." -ForegroundColor Cyan
        $cmdArgs = @("test", "test/app_widget_test.dart") + $ExtraArgs
        Invoke-Step (Get-FlutterExe) $cmdArgs
        Write-Host "✅ Widget/UI tests complete" -ForegroundColor Green
    }
    "analyze" {
        Write-Host "🔍 Running static analysis..." -ForegroundColor Cyan
        Invoke-Step (Get-FlutterExe) @("analyze")
        Write-Host "✅ Analysis complete" -ForegroundColor Green
    }
    "format" {
        Write-Host "✨ Formatting Dart code..." -ForegroundColor Cyan
        Invoke-Step (Get-DartExe) @("format", "lib", "test")
        Write-Host "✅ Format complete" -ForegroundColor Green
    }
    "format-check" {
        Write-Host "🔍 Checking Dart code format..." -ForegroundColor Cyan
        Invoke-Step (Get-DartExe) @("format", "--output=none", "--set-exit-if-changed", "lib", "test")
        Write-Host "✅ Format check complete" -ForegroundColor Green
    }
    "check" {
        Write-Host "🔍 Running full check (format-check + analyze + test)..." -ForegroundColor Cyan
        Invoke-Step (Get-DartExe) @("format", "--output=none", "--set-exit-if-changed", "lib", "test")
        $flutter = Get-FlutterExe
        Invoke-Step $flutter @("analyze")
        Invoke-Step $flutter @("test")
        Write-Host "✅ All checks passed!" -ForegroundColor Green
    }
    "build-debug" {
        Write-Host "🤖 Building Android APK (Debug)..." -ForegroundColor Green
        $cmdArgs = @("build", "apk", "--debug") + $ExtraArgs
        Invoke-Step (Get-FlutterExe) $cmdArgs
        Write-Host "✅ Android Debug APK build complete" -ForegroundColor Green
    }
    "build-release" {
        Write-Host "🤖 Building Android APK (Release)..." -ForegroundColor Green
        $cmdArgs = @("build", "apk", "--release") + $ExtraArgs
        Invoke-Step (Get-FlutterExe) $cmdArgs
        Write-Host "✅ Android Release APK build complete" -ForegroundColor Green
    }
    "build-appbundle" {
        Write-Host "🤖 Building Android App Bundle (Release)..." -ForegroundColor Green
        $cmdArgs = @("build", "appbundle", "--release") + $ExtraArgs
        Invoke-Step (Get-FlutterExe) $cmdArgs
        Write-Host "✅ Android App Bundle build complete" -ForegroundColor Green
    }
    "info" {
        Write-Host "📊 Project Information" -ForegroundColor Cyan
        Invoke-Step (Get-FlutterExe) @("--version")
        Write-Host ""
        if ($env:JAVA_HOME) {
            Write-Host "JAVA_HOME: $env:JAVA_HOME"
        }
        Write-Host ""
        Invoke-Step (Get-FlutterExe) @("doctor")
    }
    "devices" {
        Write-Host "📱 Available devices:" -ForegroundColor Cyan
        Invoke-Step (Get-FlutterExe) @("devices")
    }
    "kill" {
        Write-Host "🔪 Stopping Gradle daemons and ADB server..." -ForegroundColor Yellow
        $gradlew = Join-Path $ProjectRoot "android\gradlew.bat"
        if ((Test-Path $gradlew) -and $env:JAVA_HOME) {
            Push-Location (Join-Path $ProjectRoot "android")
            try { & $gradlew --stop } catch {} finally { Pop-Location }
        }
        try {
            $adb = Get-AdbExe
            & $adb kill-server
        } catch {}
        Write-Host "✅ Daemons killed" -ForegroundColor Green
    }
    "reset" {
        Write-Host "🔄 Performing full reset..." -ForegroundColor Yellow
        $gradlew = Join-Path $ProjectRoot "android\gradlew.bat"
        if ((Test-Path $gradlew) -and $env:JAVA_HOME) {
            Push-Location (Join-Path $ProjectRoot "android")
            try { & $gradlew --stop } catch {} finally { Pop-Location }
        }
        $flutter = Get-FlutterExe
        try { & $flutter clean } catch {}
        foreach ($dir in @(".dart_tool", "build", "android\.gradle")) {
            $fullPath = Join-Path $ProjectRoot $dir
            if (Test-Path $fullPath) {
                Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        Invoke-Step $flutter @("pub", "get")
        Invoke-Step $flutter @("gen-l10n")
        Write-Host "✅ Reset complete" -ForegroundColor Green
    }
    default {
        Write-Host "❌ Unknown command: '$Command'" -ForegroundColor Red
        Write-Host ""
        Show-Help
        exit 1
    }
}
