# Shift Calendar for Couples - Project Summary

**Last Updated:** October 25, 2025
**Current Phase:** Week 5-6 (Partner Linking) - Complete
**Next Phase:** Week 7-8 (Partner Management & Calendar UI)

---

## Project Overview

**Shift Calendar for Couples** is a cross-platform Flutter mobile application designed to eliminate scheduling friction for couples managing complex, rotating work schedules. The app provides real-time calendar synchronization across iOS and Android with automatic conflict detection and iCal integration.

**Mission:** Helping couples find more time together — not just sync their shifts.

**Target Users:** Couples working non-standard shifts in healthcare, emergency services, retail, hospitality, and manufacturing.

---

## Tech Stack

### Frontend
- **Flutter 3.35.6** - Cross-platform mobile framework
- **Dart 3.9.2** - Programming language
- **Riverpod 3.0.3** - State management (Provider pattern)
- **Material Design 3** - UI components and theming

### Backend & Services
- **Firebase Core 4.2.0** - Firebase SDK integration
- **Firebase Auth 6.1.1** - Authentication (email/password, Google, Apple)
- **Cloud Firestore 6.0.3** - Real-time NoSQL database
- **Firebase Messaging 16.0.3** - Push notifications (FCM)

### Development Tools
- **Android Studio Narwhal 2025.1.4** - IDE and Android emulator
- **Android SDK 36.1.0** - Android platform tools
- **Mockito 5.5.0** - Testing framework for mocks
- **Build Runner 2.7.1** - Code generation for tests

### Platform Support
- **Android** - Minimum SDK 21 (Android 5.0 Lollipop)
- **iOS** - Minimum iOS 13.0 (planned, not yet tested)

---

## Completed Features

### Week 1-4: Authentication System ✅

#### Firebase Authentication Integration
- **Email/Password Authentication**
  - User sign-up with display name
  - User sign-in with validation
  - Password reset functionality
  - Comprehensive error handling for all Firebase Auth error codes

- **Authentication State Management**
  - Riverpod providers for auth state
  - Real-time auth state changes stream
  - Persistent sessions (user stays signed in after app restart)
  - Automatic route management via AuthWrapper

#### User Model & Data Layer
```dart
class UserModel {
  final String userId;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? partnerId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### Auth UI Screens
- **LoginScreen** - Email/password sign-in with error feedback
- **SignupScreen** - User registration with name, email, password
- **HomeScreen** - Post-authentication landing page

#### Testing
- 10 unit tests for AuthService error handling
- All Firebase Auth error codes covered
- Tests for weak passwords, invalid emails, user collisions
- Auth state persistence tested and confirmed working

### Week 5-6: Partner Linking System ✅

#### Firestore Service Layer
Created `lib/services/firestore_service.dart` (283 lines) with:
- User CRUD operations (getUserData, updateUser)
- Partner code generation and validation
- Real-time data streams
- Atomic batch operations for data consistency

#### 6-Digit Partner Code System
**Security Features:**
- Cryptographically secure random generation (Random.secure())
- 6-digit numeric codes (100000-999999)
- Collision detection with retry logic (up to 10 attempts)
- 24-hour expiration window
- One-time use enforcement
- Self-linking prevention
- Double-linking prevention

**Firestore Schema:**
```javascript
partnerCodes/{code} {
  userId: string,
  createdAt: timestamp,
  expiresAt: timestamp,
  used: boolean,
  usedAt?: timestamp,
  usedBy?: string
}
```

**Validation Logic:**
- Check code exists
- Check not already used
- Check not expired
- Check not user's own code
- Check neither user already has a partner
- Atomic link operation via batch write

#### Partner Linking UI

**PartnerInviteScreen** (394 lines)
- Generate partner code button
- Code display with large, letter-spaced typography
- Real-time expiry countdown ("Expires in X hours")
- Copy to clipboard functionality
- Step-by-step instructions
- Security information card
- Already-linked state handling

**PartnerAcceptScreen** (352 lines)
- 6-digit code input field with validation
- Real-time form validation
  - Must be 6 digits
  - Must be numeric only
  - Cannot be empty
- Loading states during link operation
- Success dialog with partner information
- Comprehensive error handling
- Already-linked state handling

#### Riverpod Providers
```dart
// Firestore service singleton
final firestoreServiceProvider = Provider<FirestoreService>

// Real-time partner data stream
final partnerDataProvider = StreamProvider<UserModel?>

// Check if user has partner
final hasPartnerProvider = FutureProvider<bool>
```

#### Home Screen Integration
- "Invite Partner" button (navigates to PartnerInviteScreen)
- "Enter Partner Code" button (navigates to PartnerAcceptScreen)
- Material Design 3 styling with FilledButton and OutlinedButton

---

## Pending Features

### Week 7-8: Partner Management & Calendar Foundation
- [ ] Test partner linking flow end-to-end on Android emulator
- [ ] Create partner management screen
  - View current partner information
  - Unlink partner functionality
  - Confirmation dialogs for destructive actions
- [ ] Build basic calendar week view UI
  - Week navigation (previous/next)
  - Day headers with dates
  - Empty state (no events yet)
  - Both users' schedules side-by-side or overlaid

### Week 9-12: Sync Engine & Event Management
- [ ] Event model and Firestore schema
- [ ] Manual event CRUD operations
  - Create shift/event
  - Edit existing events
  - Delete events
  - Color coding
- [ ] SyncService with real-time Firestore listeners
- [ ] SQLite local cache for offline mode
- [ ] Sync queue for offline changes
- [ ] iCal import Cloud Functions (polls every 15 minutes)
- [ ] Version-based conflict resolution

### Week 13-16: UX Polish & Notifications
- [ ] Push notifications via FCM (Android) and APNs (iOS)
- [ ] Conflict detection alerts
- [ ] Free time finder (mutual availability)
- [ ] Settings screen
  - Notification preferences
  - iCal feed management
  - Account settings
- [ ] Onboarding flow for new users
- [ ] Profile editing

### Week 17-20: Beta Testing & Launch
- [ ] Recruit 50 couples for beta testing
- [ ] Bug fixes based on beta feedback
- [ ] Performance optimization (sync reliability ≥95%)
- [ ] App Store and Google Play submission
- [ ] Privacy policy and terms of service

---

## Key Technical Decisions

### 1. State Management: Riverpod over Bloc/Provider
**Decision:** Use Riverpod 3.0.3 for state management
**Rationale:**
- Compile-time safety and better error messages
- Simplified syntax compared to Bloc
- Better performance than Provider
- Built-in support for async operations
- No context required for reading providers

**Implementation Pattern:**
```dart
// Service providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Stream providers for real-time data
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Notifier providers for stateful operations
final authStateNotifierProvider = NotifierProvider<AuthStateNotifier, AsyncValue<UserModel?>>
```

### 2. Authentication: Email/Password as Primary Method
**Decision:** Prioritize email/password authentication over social login
**Rationale:**
- Google Sign-In has API breaking changes in v7.2.0 (needs further research)
- Apple Sign-In requires macOS for iOS testing (not yet available)
- Email/password provides universal authentication without third-party dependencies
- Target users (shift workers) may not have Google/Apple accounts readily accessible

**Status:**
- ✅ Email/Password: Fully implemented and tested
- ⏸️ Google Sign-In: Temporarily disabled (API compatibility issue)
- ⏳ Apple Sign-In: Package installed but not implemented (requires iOS testing)

### 3. Partner Linking: Code-Based Instead of Username/Search
**Decision:** Use 6-digit temporary codes instead of username search
**Rationale:**
- Privacy: No public usernames or searchable profiles
- Security: Time-limited, one-time use codes
- Simplicity: Easy to communicate verbally or via text
- Target audience: Couples who already communicate outside the app

**Alternative considered:** Email invitation system (deferred to future enhancement)

### 4. Firestore Batch Writes for Partner Linking
**Decision:** Use batch writes for atomic partner linking operations
**Rationale:**
- Ensures both users are linked simultaneously or not at all
- Prevents orphaned relationships (one user linked, other not)
- Marks partner code as used atomically
- Better data consistency than sequential writes

**Implementation:**
```dart
final batch = _firestore.batch();
batch.update(currentUserDoc, {'partnerId': partnerUserId});
batch.update(partnerUserDoc, {'partnerId': currentUserId});
batch.update(codeDoc, {'used': true, 'usedBy': currentUserId});
await batch.commit();
```

### 5. Real-Time Streams for Partner Data
**Decision:** Use StreamProvider for partner data instead of periodic polling
**Rationale:**
- Firestore provides real-time listeners out of the box
- Lower latency for updates (<2 seconds target)
- More efficient than polling (no wasted requests)
- Better user experience (immediate updates when partner changes info)

**Implementation:**
```dart
Stream<UserModel?> partnerDataStream(String userId) {
  return userDataStream(userId).asyncMap((user) async {
    if (user?.partnerId == null) return null;
    return await getUserData(user!.partnerId!);
  });
}
```

### 6. Android Core Library Desugaring
**Decision:** Enable core library desugaring for flutter_local_notifications compatibility
**Rationale:**
- flutter_local_notifications requires Java 8+ APIs not available on older Android versions
- Desugaring backports modern Java APIs to older Android versions
- Maintains minimum SDK 21 (Android 5.0) support
- Industry standard solution for this compatibility issue

**Configuration:**
```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

---

## Critical Milestones Achieved

### ✅ Week 4 Checkpoint: Authentication Complete
- [x] Email/password sign-in working on Android
- [x] Auth state persistence confirmed
- [x] User data model with Firestore serialization
- [x] 10 unit tests for AuthService error handling
- [ ] Google Sign-In (deferred - API compatibility)
- [ ] Apple Sign-In (deferred - requires iOS testing)
- [ ] Profile editing screen (deferred)

**Outcome:** Core authentication system is production-ready for email/password users.

### ✅ Week 6 Checkpoint: Partner Linking Backend Complete
- [x] FirestoreService with CRUD operations
- [x] 6-digit partner code generation and validation
- [x] Atomic batch operations for linking
- [x] Real-time partner data streams
- [x] Partner invite and accept UI screens
- [x] Home screen integration
- [ ] End-to-end testing (pending - requires two accounts/devices)

**Outcome:** Partner linking system architecture is complete and ready for testing.

---

## Known Issues & Workarounds

### 1. Google Sign-In Disabled
**Issue:** google_sign_in 7.2.0 has breaking API changes
**Error Messages:**
```
Error: Couldn't find constructor 'GoogleSignIn'
Error: The method 'signIn' isn't defined for the type 'GoogleSignIn'
```
**Workaround:** Disabled Google Sign-In, throws UnimplementedError
**Fix Required:** Research google_sign_in 7.2.0 API documentation and update implementation
**Priority:** Medium (email/password is working alternative)

### 2. Git 'nul' File Error
**Issue:** Windows special device name 'nul' created accidentally
**Error:** `error: unable to index file 'nul'`
**Fix Applied:** Used `rm -f nul` to remove, staged only relevant files
**Prevention:** Avoid redirecting output to 'nul' on Windows

### 3. Cloud Firestore Not Initially Enabled
**Issue:** Sign-up appeared to do nothing (button click had no effect)
**Root Cause:** Cloud Firestore API not enabled in Firebase Console
**Error Log:**
```
Stream closed with status: Status{code=PERMISSION_DENIED,
description=Cloud Firestore API has not been used in project}
```
**Fix Applied:** Enabled Cloud Firestore in Firebase Console
**Lesson:** Always verify Firebase services are enabled before testing

---

## Project File Structure

```
shift_calendar/
├── lib/
│   ├── models/
│   │   └── user_model.dart              # User data model with Firestore serialization
│   ├── providers/
│   │   └── auth_provider.dart           # Riverpod providers for auth and Firestore
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart        # Email/password sign-in UI
│   │   │   └── signup_screen.dart       # User registration UI
│   │   ├── partner/
│   │   │   ├── partner_invite_screen.dart   # Generate and share partner code
│   │   │   └── partner_accept_screen.dart   # Enter partner code to link
│   │   └── home_screen.dart             # Post-auth landing page
│   ├── services/
│   │   ├── auth_service.dart            # Firebase Auth wrapper
│   │   └── firestore_service.dart       # Firestore CRUD operations
│   ├── widgets/                         # (Empty - reusable components)
│   └── main.dart                        # App entry point with AuthWrapper
├── test/
│   └── unit/
│       └── services/
│           └── auth_service_test.dart   # 10 unit tests for AuthService
├── android/
│   └── app/
│       └── build.gradle.kts             # Android build config with desugaring
├── docs/
│   ├── shift_calendar_prd_v2.md         # Product Requirements Document
│   ├── quick_mvp_checklist.md           # Sprint-by-sprint checklist
│   ├── mvp_updates_summary.md           # Critical MVP updates
│   └── project_summary.md               # This document
├── firebase_options.dart                # Auto-generated Firebase config
├── pubspec.yaml                         # Dependencies and metadata
├── CLAUDE.md                            # AI assistant context and guidelines
└── README.md                            # Project documentation
```

---

## Development Environment

### Android Configuration
- **Android Studio:** Narwhal 2025.1.4 Feature Drop
- **Android SDK:** Version 36.1.0
- **Emulator:** Running on emulator-5554
- **Build Tools:** Gradle 8.10, AGP 8.9.0
- **Minimum SDK:** 21 (Android 5.0 Lollipop)
- **Target SDK:** 36 (Android 15)

### Firebase Project
- **Project ID:** deb-shiftsync-7984c
- **Enabled Services:**
  - ✅ Firebase Authentication (email/password enabled)
  - ✅ Cloud Firestore (Native mode)
  - ✅ Firebase Messaging
- **Collections:**
  - `users` - User profiles and partner relationships
  - `partnerCodes` - Temporary 6-digit linking codes

### Git Repository
- **Current Branch:** master
- **Latest Commit:** ea7984f - "Add partner linking system (Week 5-6 complete)"
- **Status:** Clean working tree (all changes committed)
- **Files Tracked:** 11 modified/created (1,405 lines added in last commit)

---

## Performance & Testing

### Current Test Coverage
- **Unit Tests:** 10 tests for AuthService error handling
- **Widget Tests:** 0 (not yet implemented)
- **Integration Tests:** 0 (not yet implemented)
- **Test Status:** All 10 unit tests passing ✅

### Manual Testing Completed
- [x] Email sign-up with valid credentials
- [x] Email login with existing account
- [x] Sign out functionality
- [x] Auth state persistence (app restart)
- [x] Error handling (wrong password, invalid email)
- [x] Partner code generation
- [x] Partner code UI (copy to clipboard, expiry display)

### Manual Testing Pending
- [ ] Partner code validation (full flow with two accounts)
- [ ] Partner linking success flow
- [ ] Partner linking error cases (expired code, already used, etc.)
- [ ] Unlink partner functionality
- [ ] iOS testing (all features)

### Performance Metrics (Not Yet Measured)
- Sync Reliability: Target ≥95% (not yet applicable)
- Update Latency: Target <3 seconds (not yet applicable)
- Crash-Free Sessions: Target ≥99.0%
- App Load Time: Target <3 seconds

---

## Next Steps

### Immediate (Week 7-8)
1. **Test Partner Linking End-to-End**
   - Create two test accounts
   - Generate code with Account A
   - Accept code with Account B
   - Verify both users see each other as partners
   - Test error cases (invalid code, expired code)

2. **Build Partner Management Screen**
   - Display current partner information
   - Show partner linking status
   - Add "Unlink Partner" button with confirmation dialog
   - Handle edge cases (no partner, partner account deleted)

3. **Create Basic Calendar Week View**
   - Week navigation (previous/next week)
   - Day headers with dates (Mon-Sun)
   - Empty state UI (no events yet)
   - Prepare for dual-user view (my shifts vs partner's shifts)

### Short-Term (Week 9-12)
4. **Implement Event Model & CRUD**
   - Define Event data model
   - Firestore schema for events collection
   - Create/edit/delete shift operations
   - Color coding for shift types

5. **Build Sync Engine**
   - Real-time Firestore listeners for events
   - SQLite local cache
   - Offline mode with sync queue
   - Version-based conflict resolution

6. **iCal Import System**
   - Cloud Functions for polling external calendars
   - Parse iCal feeds (ical.js library)
   - Store imported events with source metadata

### Medium-Term (Week 13-16)
7. **Push Notifications**
   - FCM integration for Android
   - APNs integration for iOS
   - Notification triggers (partner schedule changes, conflicts)

8. **UX Polish**
   - Conflict detection and alerts
   - Free time finder
   - Settings screen
   - Onboarding flow

---

## Resources

- **Firebase Console:** https://console.firebase.google.com/project/deb-shiftsync-7984c
- **Flutter Docs:** https://docs.flutter.dev
- **Riverpod Docs:** https://riverpod.dev
- **Firebase Flutter Docs:** https://firebase.google.com/docs/flutter
- **Project PRD:** docs/shift_calendar_prd_v2.md
- **MVP Checklist:** docs/quick_mvp_checklist.md

---

## Commit History

### Recent Commits
```
ea7984f - Add partner linking system (Week 5-6 complete)
  - Created FirestoreService with CRUD operations
  - Implemented 6-digit partner code generation and validation
  - Built partner invite and accept UI screens
  - Added Firestore providers to auth_provider.dart
  - Updated home screen with partner linking buttons
  - Added unit tests for AuthService
  - Updated CLAUDE.md with progress

43c37cb - Add Flutter project with complete authentication system (Week 1-4 MVP)
  - Firebase Authentication integration
  - Email/password sign-in/sign-up
  - User model with Firestore serialization
  - Auth state management with Riverpod
  - Login and signup screens

fc26097 - Deb-ShiftSync (Initial commit)
```

---

**Status:** Week 5-6 Complete ✅ | Ready for Week 7-8 Partner Management & Calendar UI
