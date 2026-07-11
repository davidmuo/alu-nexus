# ALU Nexus — Firebase Setup Guide

## 1. Create Firebase Project

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create project named **alu-nexus**
3. Enable Google Analytics (optional)

## 2. Enable Firebase Services

### Authentication
- Go to **Authentication → Sign-in method**
- Enable **Email/Password**

### Firestore Database
- Go to **Firestore Database → Create database**
- Select **Production mode** (start in production, then configure rules)
- Choose a region close to Rwanda/Mauritius (e.g., `europe-west1`)

### Firebase Storage
- Go to **Storage → Get started**
- Accept default security rules (update later)

### Firebase Cloud Messaging (push notifications)
- Already enabled by default with the Firebase project

## 3. Add Apps to Firebase

### Android
- Package name: `com.alu.alu_nexus`
- Download **google-services.json** → place in `android/app/`

### iOS
- Bundle ID: `com.alu.aluNexus`
- Download **GoogleService-Info.plist** → place in `ios/Runner/` via Xcode

## 4. Configure FlutterFire

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# From project root:
flutterfire configure --project=alu-nexus
```

This auto-generates `lib/firebase_options.dart` with real values.

## 5. Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // others can read profiles
    }

    // Startups: owner can write, anyone authenticated can read
    match /startups/{startupId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        (resource.data.ownerId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }

    // Opportunities: startup owner can write, students can read
    match /opportunities/{oppId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null &&
        get(/databases/$(database)/documents/startups/$(request.resource.data.startupId)).data.ownerId == request.auth.uid;
    }

    // Applications: student writes own, startup reads their apps
    match /applications/{appId} {
      allow create: if request.auth != null &&
        request.resource.data.applicantId == request.auth.uid;
      allow read: if request.auth != null &&
        (resource.data.applicantId == request.auth.uid ||
         resource.data.startupId == get(/databases/$(database)/documents/startups/$(resource.data.startupId)).data.ownerId);
      allow update: if request.auth != null; // simplified; tighten in production
    }

    // Notifications: user reads own only
    match /notifications/{notifId} {
      allow read, write: if request.auth != null &&
        resource.data.userId == request.auth.uid;
    }

    // Admin actions: admin only
    match /admin_actions/{actionId} {
      allow read, write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 6. Firestore Indexes

Create composite indexes for these queries (Firestore will prompt you automatically when the app hits them):

- `opportunities`: `isActive ASC, startupVerified ASC, createdAt DESC`
- `opportunities`: `isActive ASC, type ASC, createdAt DESC`
- `applications`: `applicantId ASC, appliedAt DESC`
- `applications`: `startupId ASC, appliedAt DESC`
- `notifications`: `userId ASC, createdAt DESC`
- `startups`: `verificationStatus ASC, createdAt DESC`

## 7. Create Admin Account

After first signup, manually set role in Firestore:
```
users/{uid} → role: "admin"
```

Or use Firebase Admin SDK in a Cloud Function to bootstrap the first admin.

## 8. Run the App

```bash
flutter pub get
flutter run
```

---

## Architecture Overview

```
lib/
├── core/
│   ├── constants/       # App & Firebase constants
│   ├── errors/          # Failure types
│   ├── theme/           # AppTheme, AppColors
│   ├── utils/           # Validators, extensions
│   └── widgets/         # Shared UI components
├── features/
│   ├── auth/            # Login, Register, Splash — AuthCubit
│   ├── onboarding/      # Student & Startup onboarding flows
│   ├── home/            # Role-based home shells
│   ├── opportunities/   # Feed, Detail, Post — OpportunityCubit
│   ├── applications/    # Apply, Tracker — ApplicationCubit
│   ├── startups/        # Directory, Detail, Profile — StartupCubit
│   ├── profile/         # Student profile & settings
│   ├── notifications/   # Real-time notification feed — NotificationCubit
│   └── admin/           # Startup verification dashboard
├── router/              # GoRouter with auth-guard redirects
├── services/            # (FCM notification service — extend here)
└── main.dart            # MultiBlocProvider + Firebase init
```

## State Management: Cubit (flutter_bloc)

| Cubit | Responsibility |
|-------|---------------|
| `AuthCubit` | Auth state, onboarding completion |
| `OpportunityCubit` | Real-time opportunity feed with filters |
| `ApplicationCubit` | Student & startup application tracking |
| `StartupCubit` | Startup directory, detail, verification |
| `NotificationCubit` | Real-time notification stream, unread count |
