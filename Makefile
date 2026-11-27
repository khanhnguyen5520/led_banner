# Makefile for LED Banner (Flutter / Android)
# Adapted for led_banner (com.ledbanner.led_banner)

.PHONY: help setup l10n clean run dev log test test-ui analyze format format-check check build-debug build-release build-appbundle info devices kill reset

FLUTTER ?= flutter
DART ?= dart
ADB ?= adb
DEVICE ?=

DEVICE_FLAG := $(if $(DEVICE),-d $(DEVICE),)

# Default target
help:
	@echo "📱 LED Banner Project Makefile (Flutter / Android)"
	@echo ""
	@echo "Available commands:"
	@echo "  make setup           - Cài đặt dependencies (pub get + gen-l10n)"
	@echo "  make l10n            - Sinh lại file đa ngôn ngữ (flutter gen-l10n)"
	@echo "  make clean           - Dọn dẹp thư mục build"
	@echo "  make run             - Chạy app trên thiết bị kết nối (flutter run)"
	@echo "  make dev             - Chạy chế độ dev (Hot Reload & Debug Log)"
	@echo "  make log             - Xem log trực tiếp của app (flutter logs)"
	@echo "  make test            - Chạy toàn bộ unit & widget tests"
	@echo "  make test-ui         - Chạy widget/UI tests (test/app_widget_test.dart)"
	@echo "  make analyze         - Chạy phân tích tĩnh (flutter analyze)"
	@echo "  make format          - Format toàn bộ code Dart trong lib & test"
	@echo "  make format-check    - Kiểm tra format code không sửa file"
	@echo "  make check           - Chạy format-check + analyze + test"
	@echo "  make build-debug     - Build Android APK (Debug)"
	@echo "  make build-release   - Build Android APK (Release)"
	@echo "  make build-appbundle - Build Android App Bundle (AAB Release)"
	@echo "  make info            - Hiển thị thông tin Flutter, Dart & Doctor"
	@echo "  make devices         - Liệt kê các thiết bị đang kết nối"
	@echo "  make kill            - Dừng Gradle daemon và ADB server"
	@echo "  make reset           - Reset toàn bộ cache (.dart_tool, build, .gradle) & setup lại"
	@echo ""
	@echo "Tips: Truyền thiết bị cụ thể bằng DEVICE=<id>, ví dụ: make run DEVICE=emulator-5554"

# Initial project setup
setup:
	@echo "🚀 Setting up project..."
	@$(FLUTTER) pub get
	@$(FLUTTER) gen-l10n
	@echo "✅ Dependencies downloaded and l10n generated"
	@echo "🎉 Setup complete!"

# Regenerate localization files
l10n:
	@echo "🌐 Generating localization files..."
	@$(FLUTTER) gen-l10n
	@echo "✅ Localization files generated"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning project..."
	@$(FLUTTER) clean
	@echo "✅ Clean complete"

# Run app on connected device
run:
	@echo "🚀 Running app on device..."
	@$(FLUTTER) run $(DEVICE_FLAG)

# Build, install, launch app with hot reload and logs (Flutter dev mode)
dev:
	@echo "📱 Starting dev session (Hot Reload & Logs)..."
	@$(FLUTTER) run $(DEVICE_FLAG)

# View app logs in real-time
log:
	@echo "📜 Opening Flutter logs... (Press Ctrl+C to exit)"
	@$(FLUTTER) logs $(DEVICE_FLAG)

# Run all tests
test:
	@echo "🧪 Running unit & widget tests..."
	@$(FLUTTER) test
	@echo "✅ All tests complete"

# Run widget/UI tests
test-ui:
	@echo "📸 Running widget/UI tests..."
	@$(FLUTTER) test test/app_widget_test.dart
	@echo "✅ Widget/UI tests complete"

# Run static analysis
analyze:
	@echo "🔍 Running static analysis..."
	@$(FLUTTER) analyze
	@echo "✅ Analysis complete"

# Format all Dart files
format:
	@echo "✨ Formatting Dart code..."
	@$(DART) format lib test
	@echo "✅ Format complete"

# Check format without modifying files
format-check:
	@echo "🔍 Checking Dart code format..."
	@$(DART) format --output=none --set-exit-if-changed lib test
	@echo "✅ Format check complete"

# Comprehensive check (format-check + analyze + test)
check: format-check analyze test
	@echo "✅ All checks passed!"

# Build Android APK (Debug)
build-debug:
	@echo "🤖 Building Android APK (Debug)..."
	@$(FLUTTER) build apk --debug
	@echo "✅ Android Debug APK build complete"

# Build Android APK (Release)
build-release:
	@echo "🤖 Building Android APK (Release)..."
	@$(FLUTTER) build apk --release
	@echo "✅ Android Release APK build complete"

# Build Android App Bundle (Release)
build-appbundle:
	@echo "🤖 Building Android App Bundle (Release)..."
	@$(FLUTTER) build appbundle --release
	@echo "✅ Android App Bundle build complete"

# Show project info
info:
	@echo "📊 Project Information"
	@$(FLUTTER) --version
	@echo ""
	@$(FLUTTER) doctor

# List all devices
devices:
	@echo "📱 Available devices:"
	@$(FLUTTER) devices

# Kill Gradle daemon and ADB server
kill:
	@echo "🔪 Stopping Gradle daemons and ADB server..."
	@cd android && (./gradlew --stop || ./gradlew.bat --stop || true)
	@$(ADB) kill-server || true
	@echo "✅ Daemons killed"

# Full reset (clean caches, stop daemons, re-setup)
reset:
	@echo "🔄 Performing full reset..."
	@cd android && (./gradlew --stop || ./gradlew.bat --stop || true)
	@$(FLUTTER) clean || true
	@rm -rf .dart_tool build android/.gradle
	@$(FLUTTER) pub get
	@$(FLUTTER) gen-l10n
	@echo "✅ Reset complete"
