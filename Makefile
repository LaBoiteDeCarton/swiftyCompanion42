# Flutter Project Makefile
# Usage:
# make clean   - Clean the project
# make re      - Clean, build and run
# make         - Run the app (default target)
# make emul    - List and run first available emulator

# Default target - just run the app
all: run

# Clean the project
clean:
	@echo "🧹 Cleaning Flutter project..."
	flutter clean
	flutter pub get
	@echo "✅ Project cleaned successfully!"

# Clean, build and run
re: clean
	@echo "🚀 Building and running Flutter app..."
	flutter run

# Run the app
run:
	@echo "▶️  Running Flutter app..."
	flutter run

# List available emulators and launch selected one
emul:
	@echo "📱 Available emulators:"
	@emulator_output=$$(flutter emulators 2>/dev/null); \
	if [ $$? -ne 0 ]; then \
		echo "❌ Failed to get emulators. Make sure Flutter is installed."; \
		exit 1; \
	fi; \
	echo "$$emulator_output" | grep -E '^[a-zA-Z0-9_][a-zA-Z0-9_.-]*[[:space:]]*•.*•.*•' | tail -n +2 | while IFS= read -r line; do \
		emulator_id=$$(echo "$$line" | awk '{print $$1}'); \
		emulator_name=$$(echo "$$line" | awk -F'•' '{gsub(/^[ \t]+|[ \t]+$$/, "", $$2); print $$2}'); \
		printf "%-30s (%s)\n" "$$emulator_name" "$$emulator_id"; \
	done > /tmp/emulators_list; \
	if [ ! -s /tmp/emulators_list ]; then \
		echo "❌ No emulators found. Create one with: flutter emulators --create"; \
		exit 1; \
	fi; \
	nl -w2 -s'. ' /tmp/emulators_list; \
	echo ""; \
	printf "🎯 Choose emulator (number): "; \
	read choice; \
	selected_line=$$(sed -n "$${choice}p" /tmp/emulators_list); \
	if [ -n "$$selected_line" ]; then \
		emulator_id=$$(echo "$$selected_line" | sed 's/.*(\([^)]*\)).*/\1/'); \
		emulator_name=$$(echo "$$selected_line" | sed 's/ *(.*//' | sed 's/^[[:space:]]*//'); \
		echo "🚀 Starting emulator: $$emulator_name ($$emulator_id)"; \
		flutter emulators --launch "$$emulator_id"; \
	else \
		echo "❌ Invalid selection"; \
	fi; \
	rm -f /tmp/emulators_list

# List emulators with numbers for easy selection
list-emulators:
	@echo "📱 Available emulators:"
	@flutter emulators

# Show help
help:
	@echo "📚 Available commands:"
	@echo "  make clean    - Clean Flutter project"
	@echo "  make re       - Clean, build and run"
	@echo "  make run      - Run the app (default)"
	@echo "  make build    - Build app for release (APK)"
	@echo "  make build-android - Build Android APK"
	@echo "  make build-ios - Build iOS app"
	@echo "  make build-web - Build web app"
	@echo "  make build-apk - Build APK (same as build-android)"
	@echo "  make emul     - Choose and launch an emulator interactively"
	@echo "  make list-emulators - Show numbered list of emulators"
	@echo "  make kill-emulators - Kill all running emulators"
	@echo "  make help     - Show this help message"

# Kill all running emulators
kill-emulators:
	@echo "🔪 Killing all running emulators..."
	@pkill -f "flutter_tools.*emulator" 2>/dev/null || echo "No Flutter emulator processes found"
	@adb devices | grep emulator | cut -f1 | xargs -I {} adb -s {} emu kill 2>/dev/null || true
	@echo "✅ All emulators killed"

# Show running emulators
running-emulators:
	@echo "🏃 Running emulators:"
	@adb devices | grep emulator || echo "No emulators currently running"

# Build APK
build-apk:
	@echo "📦 Building APK..."
	flutter build apk
	@echo "✅ APK built successfully!"
	@echo "📍 Location: build/app/outputs/flutter-apk/app-release.apk"

# Build app (default: APK for Android)
build:
	@echo "🏗️  Building Flutter app..."
	flutter build apk --release
	@echo "✅ Build completed successfully!"
	@echo "📍 APK Location: build/app/outputs/flutter-apk/app-release.apk"

# Build for specific platforms
build-android:
	@echo "🤖 Building for Android..."
	flutter build apk --release
	@echo "✅ Android APK built successfully!"

build-ios:
	@echo "🍎 Building for iOS..."
	flutter build ios --release
	@echo "✅ iOS build completed!"

build-web:
	@echo "🌐 Building for Web..."
	flutter build web --release
	@echo "✅ Web build completed!"
	@echo "📍 Web files location: build/web/"

# Build and install APK
install: build-apk
	@echo "📲 Installing APK..."
	flutter install

# Show Flutter and Android info
info:
	@echo "ℹ️  Flutter Information:"
	flutter doctor -v
	@echo "\n📱 Connected devices:"
	flutter devices
	@echo "\n🎮 Available emulators:"
	flutter emulators

.PHONY: all clean re run emul list-emulators help kill-emulators build build-android build-ios build-web build-apk install info