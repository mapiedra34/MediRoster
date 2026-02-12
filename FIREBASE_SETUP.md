# Firebase Setup Guide for MediRoster

This guide will help you set up Firebase for the MediRoster Flutter application.

## Prerequisites

- A Google account
- The MediRoster Flutter project cloned locally
- Flutter SDK installed

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `MediRoster` (or your preferred name)
4. Disable Google Analytics (optional)
5. Click **"Create project"**

## Step 2: Enable Authentication

1. In your Firebase project, click **"Authentication"** in the left menu
2. Click **"Get started"**
3. Click on **"Email/Password"** in the Sign-in providers
4. Enable **"Email/Password"**
5. Click **"Save"**

## Step 3: Create Test Users

In the Authentication section:

1. Click the **"Users"** tab
2. Click **"Add user"**
3. Create the following users:
   - Email: `admin1@mediroster.app`, Password: `adminpass`
   - Email: `admin2@mediroster.app`, Password: `adminpass`
   - Email: `nurse1@mediroster.app`, Password: `nursepass`
   - Email: `nurse2@mediroster.app`, Password: `nursepass`

## Step 4: Enable Cloud Firestore

1. Click **"Firestore Database"** in the left menu
2. Click **"Create database"**
3. Select **"Start in test mode"** (for development)
4. Choose a Cloud Firestore location (select closest to your users)
5. Click **"Enable"**

**Security Rules for Testing (NOT for production):**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 5: Add Android App

1. In Project Overview, click the **Android icon** (Add app)
2. Register app details:
   - **Android package name**: `com.example.mediroster`
   - **App nickname**: MediRoster Android (optional)
   - **Debug signing certificate SHA-1**: (optional, can add later)
3. Click **"Register app"**
4. Download `google-services.json`
5. Place the file in your project: `android/app/google-services.json`
6. Click **"Next"** through the remaining steps

## Step 6: Add iOS App

1. In Project Overview, click the **iOS icon** (Add app)
2. Register app details:
   - **iOS bundle ID**: `com.example.mediroster`
   - **App nickname**: MediRoster iOS (optional)
3. Click **"Register app"**
4. Download `GoogleService-Info.plist`
5. Place the file in your project: `ios/Runner/GoogleService-Info.plist`
6. Click **"Next"** through the remaining steps

## Step 7: Create Firestore Collections

In Firestore Database, create the following collections with sample data:

### Collection: `users`
Document ID: Auto-generated
Fields:
```
username: "admin1"
email: "admin1@mediroster.app"
role: "admin"
display_name: "Admin One"
created_at: (timestamp)
```

### Collection: `operations`
Create documents for common operations:
```
operation_name: "Appendectomy"
operation_name: "Gallbladder Removal"
operation_name: "Knee Replacement"
... (add more as needed)
```

### Collections to Create (initially empty):
- `cases`
- `shifts`
- `assignments`
- `presence`

## Step 8: Verify Configuration Files

**Android:**
Verify `android/app/google-services.json` exists and contains your project details.

**iOS:**
Verify `ios/Runner/GoogleService-Info.plist` exists and contains your project details.

## Step 9: Test the Setup

1. Open the project in your IDE
2. Run `flutter pub get`
3. Run the app: `flutter run`
4. Try logging in with one of the test accounts

## Production Security Rules

When deploying to production, update Firestore security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read their own data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow authenticated users to read cases
    match /cases/{caseId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Allow authenticated users to read shifts
    match /shifts/{shiftId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Allow authenticated users to manage their assignments
    match /assignments/{assignmentId} {
      allow read, write: if request.auth != null;
    }
    
    // Allow authenticated users to mark presence
    match /presence/{presenceId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Troubleshooting

### "FirebaseApp not initialized"
- Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in the correct location
- Run `flutter clean` and `flutter pub get`

### "Permission denied" errors
- Check Firestore security rules
- Verify user is authenticated
- For testing, use test mode rules

### Build errors on Android
- Ensure `google-services` plugin is applied in `android/app/build.gradle`
- Check that `google-services.json` is valid JSON

### Build errors on iOS
- Run `cd ios && pod install`
- Ensure `GoogleService-Info.plist` is added to Xcode project

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)

## Support

If you encounter issues, please:
1. Check the Firebase Console for errors
2. Review the troubleshooting section above
3. Open an issue on the GitHub repository
