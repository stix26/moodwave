# MoodWave 🌿

![coverage][coverage_badge]
[![License: MIT][license_badge]][license_link]

A beautiful Flutter mood tracking application built with Stacked architecture, featuring a modern green leaf design that represents growth, wellness, and nature.

## 🎬 Live Demo

📱 **[Watch the App Demo Video](https://drive.google.com/file/d/12I9nldrVWl3DJtg2_KExIwWb5eSnjo__/view?usp=sharing)** - See MoodWave in action with the new green leaf branding!

*The demo showcases the complete app functionality including mood tracking, journaling, insights, and the beautiful responsive design across different screen sizes.*

---

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Complete Setup Guide](#complete-setup-guide)
- [Asset and Icon Replacement](#asset-and-icon-replacement)
- [Dependency Management](#dependency-management)
- [Localization Setup](#localization-setup)
- [Running the Application](#running-the-application)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)

---

## 🎯 Overview

MoodWave is a cross-platform mood tracking application that helps users monitor their emotional well-being. The app features:

- 🌿 Beautiful green leaf branding
- 📱 Cross-platform support (iOS, Android, Web, macOS, Windows)
- 🌍 Internationalization (English & Spanish)
- 🎨 Modern Material Design UI
- 📊 Mood tracking and insights
- 📝 Mood journaling capabilities

---

## 🛠️ Prerequisites

Before setting up the project locally, ensure you have the following installed:

### Required Software
- **Flutter SDK** (>=3.22.3)
- **Dart SDK** (>=3.0.3)
- **Git**
- **Chrome** (for web development)
- **Xcode** (for iOS development on macOS)
- **Android Studio** (for Android development)

### macOS-Specific Requirements
- **Homebrew** (recommended package manager)
- **rsvg-convert** (for SVG to PNG conversion)
  ```bash
  brew install librsvg
  ```

### Verify Installation
```bash
flutter doctor -v
dart --version
```

---

## 🚀 Complete Setup Guide

### 1. Clone and Navigate to Project
```bash
git clone <repository-url>
cd moodwave
```

### 2. Install Dependencies
```bash
flutter pub get
```

**⚠️ Note:** You may encounter an `intl` version conflict. If so, run:
```bash
flutter pub add intl:^0.20.2
```

### 3. Verify Flutter Configuration
```bash
flutter doctor
flutter devices
```

---

## 🎨 Asset and Icon Replacement

This section documents the complete process of replacing all app icons and assets with a custom green leaf design.

### Original Asset Structure
The project originally contained these key assets:
- `assets/images/image.png` (1024x1024, 8-bit gray+alpha)
- `assets/images/app_icon.png` (PNG image data)
- Multiple platform-specific launcher icons

### Creating the New Leaf Icon

#### Step 1: Create SVG Source
I created a custom SVG with green gradient leaf design:

```svg
<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="grad1" cx="50%" cy="30%" r="70%">
      <stop offset="0%" style="stop-color:#7CB342;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#4CAF50;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#2E7D32;stop-opacity:1" />
    </radialGradient>
  </defs>
  <rect width="1024" height="1024" fill="url(#grad1)" rx="180"/>
  <g transform="translate(512,512)">
    <path d="M 0,-200 C -100,-150 -150,-50 -100,50 C -50,100 0,120 0,120 C 0,120 50,100 100,50 C 150,-50 100,-150 0,-200 Z" fill="white" opacity="0.9"/>
    <path d="M 0,-150 C -70,-110 -100,-30 -70,30 C -35,70 0,85 0,85 C 0,85 35,70 70,30 C 100,-30 70,-110 0,-150 Z" fill="white" opacity="0.7"/>
    <path d="M 0,-100 C -40,-70 -60,-20 -40,20 C -20,40 0,50 0,50 C 0,50 20,40 40,20 C 60,-20 40,-70 0,-100 Z" fill="white" opacity="0.5"/>
  </g>
</svg>
```

#### Step 2: Convert SVG to PNG
```bash
# Save SVG content to temp_icon.svg
python3 -c "svg_content = '''[SVG_CONTENT_HERE]'''; open('temp_icon.svg', 'w').write(svg_content)"

# Convert to PNG using rsvg-convert
rsvg-convert -w 1024 -h 1024 temp_icon.svg -o assets/images/image.png

# Copy to secondary asset location
cp assets/images/image.png assets/images/app_icon.png

# Clean up temporary file
rm temp_icon.svg
```

#### Step 3: Update Launcher Icon Configuration

**File: `flutter_launcher_icons.yaml`**
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/image.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/images/image.png"
  min_sdk_android: 21
  remove_alpha_ios: true
  web:
    generate: true
    image_path: "assets/images/image.png"
    background_color: "#4CAF50"
    theme_color: "#2E7D32"
  windows:
    generate: true
    image_path: "assets/images/image.png"
    icon_size: 48
  macos:
    generate: true
    image_path: "assets/images/image.png"
```

**File: `pubspec.yaml` (ensure consistency)**
```yaml
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/images/image.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/images/image.png"
    background_color: "#4CAF50"
    theme_color: "#2E7D32"
  windows:
    generate: true
    image_path: "assets/images/image.png"
    icon_size: 48
  macos:
    generate: true
    image_path: "assets/images/image.png"
```

#### Step 4: Generate Platform Icons
```bash
flutter pub run flutter_launcher_icons:main
```

**Expected Output:**
```
✓ Successfully generated launcher icons
• Creating default icons Android
• Creating adaptive icons Android
• Updating colors.xml with color for adaptive icon background
• Overwriting default iOS launcher icon with new icon
Creating Icons for Web...              done
Creating Icons for Windows...          done
Creating Icons for MacOS...            done
```

#### Step 5: Verify Icon Generation
```bash
# Check Android icons
file android/app/src/main/res/mipmap-hdpi/ic_launcher.png

# Check iOS icons
ls -la ios/Runner/Assets.xcassets/AppIcon.appiconset/ | head -5

# Verify web icons
ls -la web/icons/
```

---

## 📦 Dependency Management

### Common Issues and Solutions

#### 1. Intl Version Conflict
**Problem:** `flutter_localizations` requires `intl 0.20.2` but project specified `^0.19.0`

**Solution:**
```bash
flutter pub add intl:^0.20.2
```

#### 2. Build Cache Issues
**Solution:**
```bash
flutter clean
flutter pub get
```

#### 3. Dependency Analysis
```bash
# Check for outdated packages
flutter pub outdated

# Upgrade compatible packages
flutter pub upgrade
```

---

## 🌍 Localization Setup

### Problem: Missing flutter_gen Package

The app initially failed to compile due to missing localization files:
```
Error: Couldn't resolve the package 'flutter_gen' in 'package:flutter_gen/gen_l10n/app_localizations.dart'
```

### Solution Process

#### Step 1: Analyze Current Configuration

**File: `l10n.yaml`**
```yaml
arb-dir: lib/l10n/arb
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
nullable-getter: false
```

#### Step 2: Update Configuration
```yaml
arb-dir: lib/l10n/arb
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n/gen
nullable-getter: false
```

#### Step 3: Create Output Directory
```bash
mkdir -p lib/l10n/gen
```

#### Step 4: Generate Localization Files
```bash
flutter gen-l10n
```

#### Step 5: Fix Import Paths

**File: `lib/l10n/supported_locales.dart`**
```dart
import 'package:flutter/widgets.dart';
import 'gen/app_localizations.dart';  // Fixed import path

List<LocalizationsDelegate<dynamic>> get localizationsDelegates =>
    AppLocalizations.localizationsDelegates;

List<Locale> get supportedLocales => AppLocalizations.supportedLocales;
```

### Localization Files Structure
```
lib/l10n/
├── arb/
│   ├── app_en.arb          # English translations
│   ├── app_es.arb          # Spanish translations
│   ├── app_localizations.dart
│   ├── app_localizations_en.dart
│   └── app_localizations_es.dart
├── gen/                    # Generated files
│   ├── app_localizations.dart
│   ├── app_localizations_en.dart
│   └── app_localizations_es.dart
├── l10n.dart
├── localizations_extension.dart
└── supported_locales.dart
```

---

## 🏃‍♂️ Running the Application

### Development Flavors

The project supports multiple build flavors:
- `development`
- `staging` 
- `production`

### Platform-Specific Launch Commands

#### Web (Recommended for Local Development)
```bash
# Run on localhost only
flutter run --target lib/main/main_development.dart -d chrome

# Run with network access (accessible from other devices)
flutter run --target lib/main/main_development.dart -d chrome --web-hostname 0.0.0.0 --web-port 8080
```

**Access URLs:**
- Local: `http://localhost:8080`
- Network: `http://[YOUR_IP]:8080` (e.g., `http://192.168.1.104:8080`)

#### iOS Simulator
```bash
flutter run --target lib/main/main_development.dart -d "iPhone 16 Pro"
```

**⚠️ Known iOS Issue:** The Xcode project has custom build configurations that may cause issues. If you encounter build errors, you may need to:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Add a standard "Debug" configuration
3. Duplicate the "Debug-development" configuration and rename it to "Debug"

#### Android Emulator
```bash
flutter run --target lib/main/main_development.dart -d android
```

#### macOS Desktop
```bash
flutter run --target lib/main/main_development.dart -d macos
```

### Checking Available Devices
```bash
flutter devices
```

**Expected Output:**
```
Found 3 connected devices:
  iPhone 16 Pro (mobile) • 03318641-D0B3-4290-BEFB-B52F0E7709AD • ios            • com.apple.CoreSimulator.SimRuntime.iOS-18-0 (simulator)
  macOS (desktop)        • macos                                • darwin-arm64   • macOS 15.5 24F74 darwin-arm64
  Chrome (web)           • chrome                               • web-javascript • Google Chrome 138.0.7204.93
```

### Development Server Status

#### Check if Server is Running
```bash
lsof -i :8080 | grep LISTEN
```

#### Get Local Network IP
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1
```

#### Open in Browser
```bash
open http://localhost:8080
```

---

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Localization Errors
**Symptoms:**
- `flutter_gen` package not found
- `AppLocalizations` undefined

**Solution:**
```bash
flutter gen-l10n
flutter clean
flutter pub get
```

#### 2. Icon Generation Issues
**Symptoms:**
- Old icons still showing
- Icon generation fails

**Solution:**
```bash
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons:main
```

#### 3. iOS Build Configuration Issues
**Symptoms:**
- "Flutter expects a build configuration named Debug"
- Build fails on iOS simulator

**Solutions:**
- Use web platform for development: `-d chrome`
- Or fix Xcode configuration manually

#### 4. Port Already in Use
**Symptoms:**
- "Port 8080 already in use"

**Solution:**
```bash
# Find and kill process using port 8080
lsof -ti:8080 | xargs kill -9

# Or use different port
flutter run --target lib/main/main_development.dart -d chrome --web-port 8081
```

#### 5. Hot Reload Not Working
**Solution:**
```bash
# In the running app terminal, press:
r  # Hot reload
R  # Hot restart
q  # Quit
```

### Debug Commands

#### Check Flutter Installation
```bash
flutter doctor -v
```

#### Analyze Project
```bash
flutter analyze
```

#### Run Tests
```bash
flutter test
```

#### Check Dependencies
```bash
flutter pub deps
```

---

## 📁 Project Structure

```
moodwave/
├── android/                 # Android-specific code and configs
├── ios/                     # iOS-specific code and configs  
├── lib/
│   ├── app/                 # App configuration and routing
│   ├── features/            # Feature modules
│   │   ├── auth/           # Authentication
│   │   ├── home/           # Home screen
│   │   ├── mood_entry/     # Mood tracking
│   │   ├── mood_insights/  # Analytics and insights
│   │   ├── mood_journal/   # Journaling
│   │   ├── mood_timeline/  # Timeline view
│   │   └── profile/        # User profile
│   ├── l10n/               # Localization files
│   ├── main/               # Entry points for different flavors
│   ├── models/             # Data models
│   ├── services/           # Business logic services
│   ├── shared/             # Shared UI components
│   └── utils/              # Utility functions
├── web/                    # Web-specific assets
├── windows/                # Windows-specific code
├── macos/                  # macOS-specific code
├── assets/
│   └── images/
│       ├── image.png       # Main app icon (1024x1024)
│       └── app_icon.png    # Secondary icon reference
├── pubspec.yaml            # Project dependencies and configuration
├── l10n.yaml              # Localization configuration
├── flutter_launcher_icons.yaml  # Icon generation configuration
└── README.md              # This file
```

### Key Configuration Files

#### `pubspec.yaml`
- Dependencies and dev dependencies
- Asset declarations
- Launcher icon configuration

#### `l10n.yaml` 
- Localization generation settings
- ARB file locations
- Output directory configuration

#### `flutter_launcher_icons.yaml`
- Platform-specific icon generation
- Source image paths
- Icon sizes and formats

---

## 🎯 Quick Start Summary

For the impatient developer, here's the minimal setup:

```bash
# 1. Get dependencies and fix intl
flutter pub get
flutter pub add intl:^0.20.2

# 2. Generate localizations
flutter gen-l10n

# 3. Generate launcher icons (if icons were changed)
flutter pub run flutter_launcher_icons:main

# 4. Run on web with network access
flutter run --target lib/main/main_development.dart -d chrome --web-hostname 0.0.0.0 --web-port 8080

# 5. Open in browser
open http://localhost:8080
```

**Access from other devices:** `http://[YOUR_IP]:8080`

---

## 🌟 Features Implemented

- ✅ **Custom Green Leaf Branding** - Modern, nature-inspired design
- ✅ **Cross-Platform Icon Generation** - Automated for all platforms
- ✅ **Internationalization** - English and Spanish support
- ✅ **Development Server** - Network-accessible for testing
- ✅ **Hot Reload** - Live development updates
- ✅ **PWA Support** - Installable web app experience
- ✅ **Responsive Design** - Works on mobile, tablet, and desktop

---

## 📝 Development Notes

### Asset Management
- All icons are generated from a single source: `assets/images/image.png`
- SVG source is converted to PNG for compatibility
- Platform-specific icons are auto-generated using `flutter_launcher_icons`

### Localization Strategy
- ARB files store translations
- Generated files are in `lib/l10n/gen/`
- Import paths use relative imports for reliability

### Network Development
- Web server binds to `0.0.0.0` for network access
- Default port is `8080`
- Supports hot reload for live development

---

## 🤝 Contributing

When contributing to this project:

1. **Icons**: Update `assets/images/image.png` and regenerate with `flutter pub run flutter_launcher_icons:main`
2. **Translations**: Add new ARB files in `lib/l10n/arb/` and run `flutter gen-l10n`
3. **Dependencies**: Always run `flutter pub get` after pubspec changes
4. **Testing**: Verify on web platform first, then other platforms

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

[coverage_badge]: coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT