# MediRoster

A cross-platform medical roster management application built with Flutter for Android and iOS, featuring cloud-based data storage with Firebase.

## Overview

MediRoster is a mobile application designed to help manage medical staff schedules, cases, and check-ins. The app has been migrated from a native Android application (Java) to Flutter with Firebase backend integration for cross-platform support.

## Features

- **User Authentication**: Firebase Authentication with username/password login
- **Case Management**: Create, view, edit, and delete medical cases
- **Shift Management**: Schedule and manage shifts for medical staff
- **Check-in System**: Mark attendance for daily shifts
- **Real-time Updates**: Cloud Firestore provides real-time data synchronization
- **Cross-platform**: Runs on both Android and iOS devices

## Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart with null safety
- **Backend**: Firebase (Authentication + Cloud Firestore)
- **State Management**: Provider
- **UI**: Material Design

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── screens/                    # UI screens
│   ├── login_page.dart         # Login screen
│   ├── home_page.dart          # Main dashboard
│   ├── add_case_page.dart      # Add new case
│   ├── view_cases_page.dart    # List all cases
│   ├── view_case_details_page.dart  # Case details
│   ├── my_shifts_page.dart     # User shifts
│   ├── edit_case_page.dart     # Edit case
│   ├── add_edit_shift_page.dart # Add/edit shift
│   └── check_in_page.dart      # Check-in functionality
├── models/                     # Data models
│   ├── case_model.dart         # Case data model
│   ├── shift_model.dart        # Shift data model
│   └── user_model.dart         # User data model
├── services/                   # Business logic
│   ├── auth_service.dart       # Authentication service
│   ├── case_service.dart       # Case CRUD operations
│   └── shift_service.dart      # Shift CRUD operations
├── widgets/                    # Reusable widgets
└── utils/                      # Utility functions
```

## Prerequisites

Before running the app, make sure you have:

1. **Flutter SDK** (3.0 or higher)
   - [Install Flutter](https://docs.flutter.dev/get-started/install)
   - Verify installation: `flutter doctor`

2. **Development Environment**
   - For Android: Android Studio with Android SDK
   - For iOS: Xcode (macOS only)

3. **Firebase Project**
   - Create a project at [Firebase Console](https://console.firebase.google.com/)

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Enable **Authentication** (Email/Password provider)
4. Enable **Cloud Firestore** in test mode

### 2. Android Configuration

1. In Firebase Console, add an Android app
2. Package name: `com.example.mediroster`
3. Download `google-services.json`
4. Place it at: `android/app/google-services.json`
   - A template is provided at `android/app/google-services.json.template`

### 3. iOS Configuration

1. In Firebase Console, add an iOS app
2. Bundle ID: `com.example.mediroster`
3. Download `GoogleService-Info.plist`
4. Place it at: `ios/Runner/GoogleService-Info.plist`
   - A template is provided at `ios/Runner/GoogleService-Info.plist.template`

### 4. Firestore Database Setup

Create the following collections in Cloud Firestore:

```
users/
  - username (string)
  - email (string)
  - role (string: "admin" or "nurse")
  - display_name (string)
  - created_at (timestamp)

cases/
  - description (string)
  - operation (string)
  - required_nurses (number)
  - scheduled_shift_id (string)
  - start_time (string)
  - end_time (string)
  - created_at (timestamp)
  - updated_at (timestamp)

shifts/
  - date (string: YYYY-MM-DD)
  - start_time (string: HH:MM)
  - end_time (string: HH:MM)
  - created_at (timestamp)
  - updated_at (timestamp)

assignments/
  - case_id (string)
  - user_id (string)
  - created_at (timestamp)

presence/
  - username (string)
  - date (string: YYYY-MM-DD)
  - checked_in_at (timestamp)
```

### 5. Authentication Setup

In Firebase Console > Authentication:

1. Enable **Email/Password** sign-in method
2. Create test users (the app converts username to email format):
   - Email: `admin1@mediroster.app`, Password: `adminpass`
   - Email: `nurse1@mediroster.app`, Password: `nursepass`
   
Or manually create users in Authentication with custom emails.

## Installation & Running

### 1. Clone the Repository

```bash
git clone https://github.com/mapiedra34/MediRoster.git
cd MediRoster
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in place.

### 4. Run the App

**Android:**
```bash
flutter run
```

**iOS (macOS only):**
```bash
cd ios
pod install
cd ..
flutter run
```

**Specific Device:**
```bash
flutter devices  # List available devices
flutter run -d <device_id>
```

### 5. Build Release

**Android APK:**
```bash
flutter build apk --release
```

**iOS (requires Apple Developer account):**
```bash
flutter build ios --release
```

## Test Accounts

Default test accounts (create these in Firebase Authentication):

- **Admin**: admin1@mediroster.app / adminpass
- **Nurse**: nurse1@mediroster.app / nursepass

## Migration Notes

This app was migrated from a native Android application to Flutter:

### Key Changes:
- **Local SQLite Database** → **Cloud Firestore**
- **Java/Android** → **Dart/Flutter**
- **Android-only** → **Cross-platform (Android + iOS)**
- **Local authentication** → **Firebase Authentication**

### Original Android App:
The original Android app source code is preserved in the `MediRoster/` directory for reference.

## Dependencies

Key Flutter packages used:

```yaml
firebase_core: ^3.6.0          # Firebase core
firebase_auth: ^5.3.1          # Authentication
cloud_firestore: ^5.4.4        # Cloud database
provider: ^6.1.2               # State management
intl: ^0.19.0                  # Date formatting
flutter_spinkit: ^5.2.1        # Loading indicators
fluttertoast: ^8.2.8           # Toast notifications
```

## Troubleshooting

### Firebase connection issues:
- Verify `google-services.json` and `GoogleService-Info.plist` are correctly placed
- Check Firebase project configuration
- Ensure internet connectivity

### Build errors:
```bash
flutter clean
flutter pub get
flutter run
```

### iOS build issues:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

## Development

### Adding Features

1. Models: Add data models in `lib/models/`
2. Services: Add business logic in `lib/services/`
3. Screens: Add UI screens in `lib/screens/`
4. Update routes in `lib/main.dart`

### Code Style

This project follows the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and uses `flutter_lints` for linting.

Run linter:
```bash
flutter analyze
```

Format code:
```bash
flutter format .
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues, questions, or contributions, please open an issue on the GitHub repository.

---

**Version**: 1.0.0  
**Flutter Version**: 3.x  
**Minimum SDK**: Android 21 (Lollipop), iOS 12.0
