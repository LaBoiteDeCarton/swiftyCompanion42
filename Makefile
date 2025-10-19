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

# List available emulators and run the first one
emul:
	@echo "📱 Available emulators:"
	@emulator -list-avds | head -1 | xargs -I {} sh -c 'if [ -n "{}" ]; then echo "🚀 Starting emulator: {}"; emulator -avd {} & else echo "❌ No emulators found. Create one with: avdmanager create avd"; fi'

# List emulators with numbers for easy selection
list-emulators:
	@echo "📱 Available emulators:"
	@emulator -list-avds | nl -v1 -s'. '

# Run specific emulator by number
emul1 emul2 emul3 emul4 emul5:
	@$(eval EMUL_NUM := $(subst emul,,$@))
	@echo "🚀 Starting emulator #$(EMUL_NUM)..."
	@EMUL_NAME=$$(emulator -list-avds | sed -n '$(EMUL_NUM)p'); \
	if [ -n "$$EMUL_NAME" ]; then \
		echo "📱 Launching emulator: $$EMUL_NAME"; \
		emulator -avd "$$EMUL_NAME" & \
	else \
		echo "❌ Emulator #$(EMUL_NUM) not found!"; \
		echo "Available emulators:"; \
		emulator -list-avds | nl -v1 -s'. '; \
	fi

# Show help
help:
	@echo "📚 Available commands:"
	@echo "  make clean    - Clean Flutter project"
	@echo "  make re       - Clean, build and run"
	@echo "  make run      - Run the app (default)"
	@echo "  make emul     - Launch first available emulator"
	@echo "  make emul1    - Launch emulator #1"
	@echo "  make emul2    - Launch emulator #2"
	@echo "  make emul3    - Launch emulator #3"
	@echo "  make list-emulators - Show numbered list of emulators"
	@echo "  make kill-emulators - Kill all running emulators"
	@echo "  make help     - Show this help message"

# Kill all running emulators
kill-emulators:
	@echo "🔪 Killing all running emulators..."
	@pkill -f "emulator" 2>/dev/null || echo "No emulator processes found"
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

.PHONY: all clean re run emul list-emulators help kill-emulators build-apk install info