# Changelog

All notable changes to the MediRoster Flutter project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-12

### Added - Initial Flutter Migration

#### Core Application
- Complete Flutter project structure with lib/, android/, ios/ directories
- Cross-platform support for Android and iOS
- Firebase integration for authentication and data storage
- Provider-based state management

#### Screens
- LoginPage: User authentication with Firebase
- HomePage: Main dashboard with navigation
- AddCasePage: Form to create new medical cases
- ViewCasesPage: List view of all cases with real-time updates
- ViewCaseDetailsPage: Detailed case information view
- MyShiftsPage: User shifts management
- EditCasePage: Edit existing cases
- AddEditShiftPage: Add or modify shifts
- CheckInPage: Daily attendance check-in system

#### Data Models
- CaseModel: Medical case data with Firestore integration
- ShiftModel: Shift scheduling data
- UserModel: User authentication and profile data

#### Services
- AuthService: Firebase Authentication integration
- CaseService: CRUD operations for medical cases
- ShiftService: CRUD operations for shifts

#### UI Components
- Common reusable widgets (LoadingIndicator, ErrorDisplay, EmptyState)
- Custom styled text fields and cards
- Material Design theme with teal color scheme
- Gradient app bars

#### Utilities
- Constants: App-wide constants and configurations
- DateTimeHelper: Date and time formatting utilities
- Validators: Input validation functions

#### Testing
- Unit tests for CaseModel
- Unit tests for ShiftModel
- Unit tests for UserModel

#### Documentation
- Comprehensive README with setup instructions
- FIREBASE_SETUP.md: Step-by-step Firebase configuration guide
- MIGRATION.md: Detailed migration guide from Android to Flutter
- CONTRIBUTING.md: Contribution guidelines and coding standards
- CHANGELOG.md: Version history tracking

#### Configuration
- pubspec.yaml with all required dependencies:
  - firebase_core: ^3.6.0
  - firebase_auth: ^5.3.1
  - cloud_firestore: ^5.4.4
  - provider: ^6.1.2
  - intl: ^0.19.0
  - flutter_spinkit: ^5.2.1
  - fluttertoast: ^8.2.8
- Android build configuration with Firebase
- iOS Podfile configuration
- Dart analysis options with linting rules
- .gitignore for Flutter projects

#### Firebase Configuration
- Android google-services.json template
- iOS GoogleService-Info.plist template
- Firestore security rules examples
- Authentication setup instructions

### Changed

#### Architecture
- Migrated from Java/Android to Dart/Flutter
- Changed from local SQLite database to Cloud Firestore
- Replaced Android Intents with Flutter Navigator
- Converted XML layouts to Flutter widgets

#### Authentication
- Replaced local password validation with Firebase Authentication
- Username converted to email format for Firebase compatibility

#### Data Storage
- All data now stored in Cloud Firestore instead of local SQLite
- Real-time data synchronization across devices
- Cloud-based backup and recovery

### Deprecated
- Original Android-only application (preserved in MediRoster/ directory for reference)
- Local SQLite database implementation
- Java-based UserDatabaseHelper class

### Removed
- Android-specific dependencies (no longer needed for main app)
- Local database queries and SQL schemas
- Android lifecycle components (replaced with Flutter equivalents)

### Security
- Implemented Firebase Authentication with industry-standard security
- Added Firestore security rules for data protection
- Removed plain-text password storage
- Added input validation for all forms

### Technical Details

#### Dependencies
- Flutter SDK: 3.x
- Dart: 3.0+
- Minimum Android SDK: 21 (Lollipop)
- Minimum iOS version: 12.0

#### Platforms Supported
- Android (phone and tablet)
- iOS (iPhone and iPad)

#### Known Issues
- Firebase configuration files (google-services.json, GoogleService-Info.plist) must be manually added
- Requires internet connection for initial data sync
- Existing Android app data needs manual migration

#### Breaking Changes
- Users need to re-register or have accounts created in Firebase
- Existing local data must be manually migrated to Firestore
- App package name changed from Android-specific to cross-platform

### Migration Path

For users migrating from the Android-only version:

1. Set up Firebase project (see FIREBASE_SETUP.md)
2. Create user accounts in Firebase Authentication
3. Export data from SQLite (if needed)
4. Import data to Cloud Firestore
5. Install new Flutter app
6. Login with new Firebase credentials

## [Unreleased]

### Planned Features
- Push notifications for shift reminders
- Offline mode with local caching
- Advanced filtering and search
- Role-based permissions
- Calendar view for shifts
- Export data to PDF/CSV
- Multi-language support

---

## Version History

- **1.0.0** (2026-02-12) - Initial Flutter release with cross-platform support
- **0.x.x** (2024-2025) - Android-only version (Java)
