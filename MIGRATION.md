# Migration Guide: Android to Flutter

This document explains the migration from the native Android MediRoster app to the Flutter cross-platform version.

## Migration Overview

### What Changed

| Aspect | Android (Original) | Flutter (New) |
|--------|-------------------|---------------|
| **Platform** | Android only | Android + iOS |
| **Language** | Java | Dart |
| **Database** | SQLite (local) | Cloud Firestore (cloud) |
| **Authentication** | Local database | Firebase Authentication |
| **UI Framework** | Android XML layouts | Flutter widgets |
| **State Management** | Android lifecycle | Provider pattern |
| **Navigation** | Android Intents | Flutter Navigator |

## Architecture Comparison

### Android App Architecture

```
MediRoster/
├── app/src/main/java/com/example/mediroster/
│   ├── LoginPage.java
│   ├── HomePage.java
│   ├── AddCasePage.java
│   ├── ViewCasesPage.java
│   ├── ViewCaseDetailsPage.java
│   ├── MyShiftsPage.java
│   ├── EditCasePage.java
│   ├── AddEditShiftPage.java
│   ├── CheckInPage.java
│   └── UserDatabaseHelper.java (SQLite)
└── app/src/main/res/layout/
    └── (XML layouts)
```

### Flutter App Architecture

```
lib/
├── main.dart
├── screens/
│   ├── login_page.dart
│   ├── home_page.dart
│   ├── add_case_page.dart
│   ├── view_cases_page.dart
│   ├── view_case_details_page.dart
│   ├── my_shifts_page.dart
│   ├── edit_case_page.dart
│   ├── add_edit_shift_page.dart
│   └── check_in_page.dart
├── models/
│   ├── case_model.dart
│   ├── shift_model.dart
│   └── user_model.dart
└── services/
    ├── auth_service.dart
    ├── case_service.dart
    └── shift_service.dart
```

## Key Technical Changes

### 1. Database Migration

**Android (SQLite):**
```java
public class UserDatabaseHelper extends SQLiteOpenHelper {
    public boolean validateLogin(String username, String password) {
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.rawQuery(
            "SELECT * FROM users WHERE username = ? AND password = ?",
            new String[]{username, password}
        );
        return cursor.getCount() > 0;
    }
}
```

**Flutter (Firestore):**
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<UserCredential?> signInWithUsername({
    required String username,
    required String password,
  }) async {
    final email = '$username@mediroster.app';
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
```

### 2. UI Components

**Android XML:**
```xml
<EditText
    android:id="@+id/username_input"
    android:hint="Username"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"/>
```

**Flutter Dart:**
```dart
TextFormField(
  controller: _usernameController,
  decoration: const InputDecoration(
    labelText: 'Username',
    prefixIcon: Icon(Icons.person),
  ),
)
```

### 3. Navigation

**Android Intent:**
```java
Intent intent = new Intent(LoginPage.this, HomePage.class);
intent.putExtra("username", username);
startActivity(intent);
```

**Flutter Navigator:**
```dart
Navigator.pushReplacementNamed(
  context,
  '/home',
  arguments: {'username': username, 'role': role},
);
```

### 4. Async Operations

**Android AsyncTask/Callbacks:**
```java
new Thread(() -> {
    boolean result = dbHelper.validateLogin(username, password);
    runOnUiThread(() -> {
        if (result) {
            // Navigate
        }
    });
}).start();
```

**Flutter async/await:**
```dart
Future<void> _handleLogin() async {
  try {
    final credential = await authService.signInWithUsername(
      username: username,
      password: password,
    );
    // Navigate
  } catch (e) {
    // Handle error
  }
}
```

## Data Migration

### User Data

**Android Schema:**
```sql
CREATE TABLE users (
    username TEXT PRIMARY KEY,
    password TEXT,
    role TEXT,
    display_name TEXT
)
```

**Firestore Structure:**
```
users/{userId}
  - username: string
  - email: string
  - role: string
  - display_name: string
  - created_at: timestamp
```

### Migration Steps

1. **Export from SQLite:**
   ```java
   Cursor cursor = db.rawQuery("SELECT * FROM users", null);
   // Export to JSON or CSV
   ```

2. **Import to Firestore:**
   - Use Firebase Console bulk import
   - Or use Firebase Admin SDK
   - Or manually create users via Authentication

### Cases Data

**Android Schema:**
```sql
CREATE TABLE cases (
    case_id INTEGER PRIMARY KEY AUTOINCREMENT,
    description TEXT,
    required_nurses INTEGER,
    scheduled_shift_id INTEGER,
    operation TEXT,
    start_time TEXT,
    end_time TEXT
)
```

**Firestore Structure:**
```
cases/{caseId}
  - description: string
  - required_nurses: number
  - scheduled_shift_id: string
  - operation: string
  - start_time: string
  - end_time: string
  - created_at: timestamp
  - updated_at: timestamp
```

## Feature Parity

| Feature | Android | Flutter | Status |
|---------|---------|---------|--------|
| User Login | ✅ | ✅ | ✅ Complete |
| Home Dashboard | ✅ | ✅ | ✅ Complete |
| Add Case | ✅ | ✅ | ✅ Complete |
| View Cases | ✅ | ✅ | ✅ Complete |
| View Case Details | ✅ | ✅ | ✅ Complete |
| Edit Case | ✅ | ✅ | ✅ Complete |
| Delete Case | ✅ | ✅ | ✅ Complete |
| My Shifts | ✅ | ✅ | ✅ Complete |
| Add/Edit Shift | ✅ | ✅ | ✅ Complete |
| Delete Shift | ✅ | ✅ | ✅ Complete |
| Check-in | ✅ | ✅ | ✅ Complete |
| Nurse Assignment | ✅ | ✅ | ✅ Complete |
| Offline Support | ✅ (SQLite) | ✅ (Firestore) | ✅ Complete |

## Benefits of Flutter Migration

### 1. Cross-Platform Support
- **Before**: Android only
- **After**: Android + iOS with single codebase
- **Benefit**: Reach wider audience, reduce development time

### 2. Cloud Synchronization
- **Before**: Data stored locally, no sync
- **After**: Real-time cloud sync via Firestore
- **Benefit**: Data accessible from any device, automatic backup

### 3. Modern Development
- **Before**: Java, XML layouts
- **After**: Dart, declarative UI
- **Benefit**: Faster development, hot reload, better tooling

### 4. Scalability
- **Before**: Local database limits
- **After**: Cloud-based, auto-scaling
- **Benefit**: Handle more users and data

### 5. Security
- **Before**: Local password storage
- **After**: Firebase Authentication
- **Benefit**: Industry-standard security, no password storage

## Breaking Changes

### For End Users

1. **Authentication Change**
   - Old: Local username/password
   - New: Firebase email/password (username converted to email)
   - Action: Users need to re-register or have accounts created

2. **Data Location**
   - Old: Data stored on device
   - New: Data stored in cloud
   - Action: Existing data needs manual migration

3. **Internet Required**
   - Old: Works completely offline
   - New: Requires internet for initial sync (offline caching available)
   - Action: Ensure network connectivity

### For Developers

1. **Build System**
   - Old: Gradle (Android)
   - New: Flutter build system
   - Action: Learn Flutter tooling

2. **Dependencies**
   - Old: Android libraries
   - New: Flutter packages (pubspec.yaml)
   - Action: Review new dependency management

3. **Testing**
   - Old: JUnit, Espresso
   - New: Flutter test framework
   - Action: Rewrite tests for Flutter

## Migration Timeline

Recommended steps for full migration:

### Phase 1: Setup (Completed)
- ✅ Create Flutter project structure
- ✅ Set up Firebase
- ✅ Implement all screens
- ✅ Configure Android/iOS

### Phase 2: Data Migration (To Do)
- [ ] Export existing SQLite data
- [ ] Create Firebase collections
- [ ] Import data to Firestore
- [ ] Verify data integrity

### Phase 3: Testing (To Do)
- [ ] Test all features on Android
- [ ] Test all features on iOS
- [ ] Test authentication flow
- [ ] Test data synchronization
- [ ] Performance testing

### Phase 4: Deployment (To Do)
- [ ] Build Android APK/Bundle
- [ ] Build iOS IPA
- [ ] Deploy to Google Play Store
- [ ] Deploy to Apple App Store
- [ ] Monitor for issues

## Troubleshooting Common Issues

### Issue: "Can't login with old credentials"
**Solution**: Old local passwords don't exist in Firebase. Create new accounts via Firebase Authentication.

### Issue: "No data showing"
**Solution**: Firestore is empty. Migrate data from SQLite or create new test data.

### Issue: "App crashes on startup"
**Solution**: Verify `google-services.json` and `GoogleService-Info.plist` are correctly placed.

### Issue: "Permission denied in Firestore"
**Solution**: Check Firestore security rules. For testing, use test mode.

## Rollback Plan

If migration encounters issues:

1. Keep original Android app available
2. Maintain separate app IDs for gradual rollout
3. Implement data export from Firestore if needed
4. Users can switch back to Android app temporarily

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev/)
- [Migration Best Practices](https://docs.flutter.dev/development/platform-integration/platform-adaptations)

## Support

For migration support:
- Check existing documentation
- Review code comments
- Open issues on GitHub
- Contact development team

---

**Migration Date**: February 2026  
**Flutter Version**: 3.x  
**Original Android Version**: 1.0
