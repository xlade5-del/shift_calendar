# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Shift Calendar for Couples** is a cross-platform Flutter mobile application designed to eliminate scheduling friction for couples managing complex, rotating work schedules. The app provides real-time calendar synchronization across iOS and Android with automatic conflict detection and iCal integration.

**Mission:** Helping couples find more time together — not just sync their shifts.

**Target Users:** Couples working non-standard shifts in healthcare, emergency services, retail, hospitality, and manufacturing.

## Current Implementation Status

**Phase:** Week 1-4 (Authentication & Basic Setup)
**Last Updated:** October 2025

### ✅ Completed
- Flutter project initialized with Firebase
- Riverpod state management configured
- Firebase Authentication integration (email/password)
- Basic auth screens (LoginScreen, SignupScreen)
- AuthService with sign-in/sign-up/sign-out methods
- User model with Firestore serialization
- Auth state management with authProvider
- Main app with AuthWrapper for route management
- Home screen with user info display
- **Android emulator setup and configuration**
- **Android build fixed (core library desugaring for flutter_local_notifications)**
- **Unit tests for AuthService (10 tests passing)**
- **Comprehensive error handling in AuthService**
- **Testing dependencies added (mockito, build_runner)**

### 🚧 In Progress
- Google Sign-In for mobile (API compatibility issue with google_sign_in 7.2.0)
- Apple Sign-In integration (sign_in_with_apple package installed)

### ⏳ Not Yet Started
- Partner linking system (6-digit code + email invite)
- Calendar UI (week view)
- Firestore service layer (FirestoreService)
- Sync service with SQLite
- iCal import Cloud Functions
- Notification service (FCM/APNs)
- Conflict detection logic
- Offline mode with sync queue
- Widget and integration tests

### Current Firebase Setup

**Configured:**
- ✅ Firebase Core
- ✅ Firebase Auth (email/password, Google Sign-In)
- ✅ Platform configs: Android (google-services.json)
- ✅ iOS configuration files ready

**Not Yet Configured:**
- ⏳ Cloud Firestore security rules
- ⏳ Cloud Functions directory
- ⏳ FCM/APNs for push notifications
- ⏳ Firebase Scheduler for iCal polling

**Firebase Project:** deb-shiftsync-7984c

### State Management Implementation (Riverpod)

**Current Providers (lib/providers/auth_provider.dart):**
- `authServiceProvider` - Manages AuthService singleton instance
- `authStateChangesProvider` - Streams Firebase auth state changes
- `currentUserProvider` - Provides current User model from Firestore (when implemented)

**Usage Pattern:**
```dart
// In widgets - watching auth state
final authState = ref.watch(authStateChangesProvider);

// Calling auth methods
final authService = ref.read(authServiceProvider);
await authService.signInWithEmail(email, password);
await authService.signUpWithEmail(email, password, name);
await authService.signInWithGoogle();
await authService.signOut();
```

### Current Project Structure

```
lib/
├── models/
│   └── user_model.dart          # ✅ User model with Firestore serialization
├── providers/
│   └── auth_provider.dart       # ✅ Riverpod auth providers
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    # ✅ Email/Google sign-in UI
│   │   └── signup_screen.dart   # ✅ Email/Google sign-up UI
│   └── home_screen.dart         # ✅ Post-auth placeholder screen
├── services/
│   └── auth_service.dart        # ✅ Firebase Auth wrapper
├── widgets/                     # ⏳ Empty (reusable components)
└── utils/                       # ⏳ Empty (helpers, validators)

test/
└── widget_test.dart             # ⏳ Default test (needs implementation)

firebase_options.dart            # ✅ Auto-generated Firebase config
main.dart                        # ✅ App entry point with AuthWrapper
```

## Next Development Steps

### Immediate (Complete Week 4 Checkpoint)
1. ⏳ Fix Google Sign-In for mobile (google_sign_in 7.2.0 API issues)
2. ⏳ Complete Apple Sign-In integration
3. ✅ Add comprehensive error handling to AuthService
4. ⏳ Test auth persistence (close/reopen app)
5. ✅ Write unit tests for AuthService (10 tests passing)
6. ⏳ Test all auth methods on iOS + Android

### Week 5-8 (Partner Linking & Basic UI)
1. Create FirestoreService for user/partner CRUD operations
2. Implement 6-digit partner code generation and validation
3. Build partner linking UI (invite screen, accept screen)
4. Add partner invite via email
5. Create partner management screen
6. Build basic calendar week view UI (no events yet)

### Week 9-12 (Sync & Calendar)
1. Create Event model and Firestore schema
2. Implement manual event creation/editing/deletion
3. Build SyncService with real-time Firestore listeners
4. Set up SQLite for offline cache
5. Implement sync queue for offline changes
6. Create iCal import Cloud Functions
7. Test offline mode extensively

See **docs/quick_mvp_checklist.md** for detailed week-by-week breakdown.

## Development Commands

### Current Phase Commands (Week 1-4: Auth)

```bash
# Test authentication flow
flutter run

# Test with verbose logging
flutter run -v

# Clear app data and test fresh install
flutter run --clear-app-data

# Check for auth-specific issues
flutter analyze

# Hot reload during development (press 'r' in terminal while app is running)
# Hot restart (press 'R' in terminal)
```

**Testing Checklist:**
- [ ] Email sign-up with valid credentials
- [ ] Email login with existing account
- [ ] Google Sign-In flow
- [ ] Sign out functionality
- [ ] Auth state persistence (close/reopen app)
- [ ] Error handling (wrong password, network issues)

## Standard Development Commands

### Setup & Dependencies
```bash
# Install Flutter dependencies
flutter pub get

# Clean and rebuild
flutter clean && flutter pub get

# Check for Flutter/Dart issues
flutter doctor
```

### Running the App
```bash
# Run on connected device/simulator (debug mode)
flutter run

# Run on specific device
flutter devices                    # List available devices
flutter run -d <device-id>

# Run with specific flavor (once configured)
flutter run --flavor dev
flutter run --flavor prod
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/some_test.dart

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget/
```

### Building
```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android - for Play Store)
flutter build appbundle --release

# Build iOS (requires macOS + Xcode)
flutter build ios --release

# Build for specific flavor
flutter build apk --flavor prod --release
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Fix auto-fixable issues
dart fix --apply
```

### Firebase (When Configured in Later Phases)

**Note:** Cloud Functions not yet set up. These commands will be used in Week 9-12.

```bash
# Initialize Firebase Functions (to be done later)
firebase init functions

# Deploy Cloud Functions (Week 9-12)
cd functions
npm install
npm run deploy

# Deploy Firestore rules (Week 5-8)
firebase deploy --only firestore:rules

# Deploy Firestore indexes (Week 9-12)
firebase deploy --only firestore:indexes

# View Firebase logs
firebase functions:log
```

## Architecture Overview

### Tech Stack
- **Frontend:** Flutter (Dart) - Cross-platform mobile framework
- **Backend:** Firebase (Firestore, Auth, Cloud Functions, FCM)
- **State Management:** Riverpod
- **Local Storage:** SQLite (offline cache, sync queue)
- **Push Notifications:** FCM (Android) + APNs (iOS)

### Planned Project Structure (Full MVP)

**Note:** See "Current Project Structure" section above for what's currently implemented.

```
lib/
├── models/          # Data models (Event, User, Partner, SyncQueue)
│   ├── user_model.dart             # ✅ Implemented
│   ├── event_model.dart            # ⏳ To be created
│   ├── partner_model.dart          # ⏳ To be created
│   └── sync_queue_model.dart       # ⏳ To be created
├── screens/         # UI screens (Calendar, Auth, Settings, Partner)
│   ├── auth/                       # ✅ Login & Signup implemented
│   ├── calendar/                   # ⏳ Week view to be created
│   ├── partner/                    # ⏳ Partner linking to be created
│   └── settings/                   # ⏳ Settings to be created
├── services/        # Business logic services
│   ├── auth_service.dart           # ✅ Firebase Authentication
│   ├── firestore_service.dart      # ⏳ Firestore CRUD operations
│   ├── sync_service.dart           # ⏳ Real-time sync + offline queue
│   ├── ical_service.dart           # ⏳ iCal feed parsing
│   ├── notification_service.dart   # ⏳ FCM/APNs push notifications
│   └── conflict_service.dart       # ⏳ Conflict detection logic
├── widgets/         # ⏳ Reusable UI components
└── utils/           # ⏳ Helper functions (date formatting, validators)

test/
├── unit/           # ⏳ Unit tests for services and models
├── widget/         # ⏳ Widget tests for UI components
└── integration/    # ⏳ End-to-end integration tests

assets/
├── images/         # App images and icons
└── fonts/          # Custom fonts (if any)

docs/               # Project documentation
├── shift_calendar_prd_v2.md       # Product Requirements Document
├── quick_mvp_checklist.md         # Sprint-by-sprint checklist
└── mvp_updates_summary.md         # Critical MVP updates
```

### Core Architecture Patterns

**Note:** These patterns describe the planned architecture for the full MVP. Implementation begins in Week 5+.

#### Three-Layer Sync Architecture (Weeks 9-12)

1. **Real-Time Cloud Database (Firebase Firestore)**
   - Single source of truth for all calendar events
   - Real-time listeners provide <2s latency updates
   - Automatic propagation to all connected devices

2. **iCal Integration Layer**
   - Cloud Functions poll external calendars every 15 minutes
   - Parses iCal feeds using ical.js
   - Compares UID + LAST-MODIFIED fields to detect changes
   - Triggers FCM/APNs for immediate app refresh

3. **Offline Resilience (SQLite)**
   - Local cache of all events for offline access
   - Sync queue stores pending changes with timestamps
   - Exponential backoff retry: 1s, 2s, 4s, 8s, 16s, 32s
   - Version-based conflict resolution on reconnection

#### Conflict Resolution Strategy (Weeks 9-12)

**Versioned Optimistic Locking:**
- Each event has an integer `version` field that increments with changes
- Client sends current version with all update requests
- Server validates: if version matches → accept and increment
- If version mismatch → return conflict with both versions
- User prompted: "Alex modified this shift after you. Keep yours, keep theirs, or merge?"
- Auto-merge if only metadata changed (color, notes)
- Timestamp-based last-write-wins for irreconcilable time conflicts

#### Background Sync Strategy (Weeks 13-16)

**iOS:**
- FCM triggers immediate foreground refresh
- Background fetch every 15 minutes (iOS platform limit)
- Silent push notifications for critical updates

**Android:**
- FCM triggers immediate updates
- WorkManager schedules periodic sync (15 min minimum)
- Foreground service for active sync sessions

### Data Models

#### Users Collection (Firestore)
```javascript
{
  userId: string,
  email: string,
  name: string,
  partnerId: string | null,
  icalFeeds: [{
    url: string,
    lastSync: timestamp,
    syncInterval: number
  }],
  notificationSettings: {
    partnerChanges: boolean,
    conflicts: boolean,
    freeTime: boolean
  },
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### Events Collection (Firestore)
```javascript
{
  eventId: string,
  userId: string,
  title: string,
  startTime: timestamp,
  endTime: timestamp,
  notes: string | null,
  color: string,
  source: 'manual' | 'ical' | 'google' | 'apple',
  icalUid: string | null,
  version: number,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### Sync Queue (Local SQLite)
```sql
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY,
  operation TEXT CHECK(operation IN ('create', 'update', 'delete')),
  event_data TEXT,
  timestamp INTEGER,
  retry_count INTEGER DEFAULT 0,
  status TEXT CHECK(status IN ('pending', 'syncing', 'failed'))
);
```

## MVP Scope (P0 Features Only)

### In Scope
- Email/password, Google Sign-In, Apple Sign-In authentication
- Partner linking via 6-digit code or email invite
- Manual shift creation/editing/deletion
- Single iCal feed import per user (free tier)
- Week view calendar showing both partners' schedules
- Real-time Firebase sync (<3s latency)
- Offline mode with automatic sync when online
- Push notifications for partner schedule changes
- Conflict detection (both partners working same time)

### Out of Scope (Defer to Post-MVP)
- Month/day calendar views (week view only for MVP)
- AI-powered scheduling suggestions (requires 10k+ users)
- Advanced analytics dashboard
- PDF/iCal export (premium feature)
- Shift templates and recurring events
- Multiple premium subscription tiers
- Localization beyond English
- Web or desktop applications

## Development Timeline

**Total: 20 weeks** (16 weeks development + 4 weeks beta testing)

- **Phase 1 (Weeks 1-8):** Core MVP - Auth, partner linking, manual events, basic calendar UI
- **Phase 2 (Weeks 9-12):** Sync Engine - Real-time sync, iCal import, offline mode
- **Phase 3 (Weeks 13-16):** UX Polish - Notifications, conflict alerts, settings
- **Phase 4 (Weeks 17-20):** Beta testing with 50 couples + store submission

## Critical Performance Targets

### MVP Launch Targets
- Sync Reliability: ≥95%
- Update Latency: <3 seconds
- Crash-Free Sessions: ≥99.0%
- App Load Time: <3 seconds
- Offline Sync Success: ≥90%
- Data Loss Rate: <0.5%

### Production Targets (Post-Optimization)
- Sync Reliability: ≥99.9%
- Update Latency: <2 seconds
- Crash-Free Sessions: ≥99.5%
- App Load Time: <2 seconds
- Offline Sync Success: ≥95%
- Data Loss Rate: <0.1%

## Key Implementation Notes

### Firestore Security Rules
- User can only read/write their own events and their partner's events
- Partner relationship must be mutually confirmed before calendar access
- iCal feeds are user-specific and cannot be accessed by other users
- Rate limiting: 100 requests per minute per user

### iCal Import Process (Cloud Functions)
```javascript
// Runs every 15 minutes via Cloud Scheduler
exports.pollIcalFeeds = functions.pubsub.schedule('every 15 minutes').onRun(async (context) => {
  // 1. Fetch all users with active iCal feeds
  // 2. For each feed: fetch via HTTPS, parse with ical.js
  // 3. Compare UID + LAST-MODIFIED against existing events
  // 4. Insert new events, update changed events
  // 5. Mark source='ical' and store icalUid
  // 6. Trigger FCM/APNs notification for immediate refresh
});
```

### Offline Mode Implementation
1. All read operations check SQLite first (faster, offline-capable)
2. Write operations immediately write to SQLite
3. If online: also write to Firestore immediately
4. If offline: add to sync queue with pending status
5. On reconnection: process sync queue with exponential backoff
6. Conflict detection: compare versions, prompt user if mismatch

### Testing Strategy
- Unit tests: Services, models, conflict resolution logic
- Widget tests: UI components, calendar views, forms
- Integration tests: End-to-end flows (signup → partner link → create event → sync)
- Offline testing: Airplane mode scenarios with 10+ queued changes
- Platform testing: Both iOS and Android simulators + real devices

## Monetization

### Free Tier
- Unlimited manual events
- Partner linking (2 people)
- 1 iCal feed per user
- Week calendar view
- Real-time sync and offline mode
- Basic conflict alerts

### Premium Tier ($4.99/month or $49.99/year)
- Unlimited iCal feeds
- Free time finder (mutual availability)
- PDF/iCal export
- Advanced notification customization
- Priority support (24hr response)
- Future: AI suggestions (post-10k users)

## Critical Checkpoints

### Week 4: Auth Complete
- All 3 sign-in methods working on iOS + Android
- Auth state persistence
- Basic profile screen

### Week 10: Sync Working
- Real-time sync >95% reliable in testing
- Partner's changes appear within 3 seconds
- Version conflict detection working

### Week 12: Offline Tested
- Offline mode handles 10+ queued changes
- Reconnection syncs all pending changes
- Conflict resolution UI tested

### Week 14: Notifications Live
- Push notifications deliver within 5 seconds
- FCM (Android) and APNs (iOS) both working
- Notification settings functional

### Week 17: Beta Recruited
- 50 couples confirmed and onboarded
- Feedback collection process established
- Bug tracking system in place

## Common Pitfalls & Solutions

### Sync Issues
1. Check Firestore security rules (most common cause)
2. Verify auth token not expired
3. Test with simple events first before complex scenarios
4. Add verbose logging to sync_service.dart
5. Use Firebase Local Emulator Suite for local testing

### Offline Mode Not Working
1. Test SQLite directly (insert/query operations)
2. Verify sync queue logic handles edge cases
3. Check connectivity listeners (Android WorkManager, iOS BackgroundFetch)
4. Test with multiple offline changes before reconnection
5. Verify version conflict resolution prompts user correctly

### Notifications Not Delivering
1. Check FCM/APNs tokens are registered on app launch
2. Verify Cloud Functions trigger correctly (check logs)
3. Test with Firebase Console manual send
4. Check app notification permissions granted
5. Review notification payload format matches platform requirements

### iCal Import Failures
1. Validate iCal URL is HTTPS (HTTP not supported)
2. Test URL directly in browser to verify accessibility
3. Check Cloud Function logs for parsing errors
4. Verify ical.js library version compatibility
5. Test with known-good iCal feeds (Google Calendar export)

## Git Workflow

Since this is a solo development project:
- Main branch: production-ready code
- Feature branches: feature/auth, feature/sync, feature/ical, etc.
- Commit frequently with clear messages
- Tag releases: v0.1.0-beta, v1.0.0, etc.

## Resources

- **Firebase Docs:** https://firebase.google.com/docs/flutter
- **Flutter Docs:** https://docs.flutter.dev
- **iCal Spec (RFC 5545):** https://tools.ietf.org/html/rfc5545
- **Project Documents:** See /docs folder for PRD and checklists

## Development Philosophy

**Ship P0 features with quality, defer everything else.**

- Focus on reliability over features
- Test offline mode extensively (real-world shift workers have spotty connectivity)
- Prioritize cross-platform consistency
- Measure everything (Firebase Analytics + custom events)
- Cut scope, not quality (defer features, not testing)
- Real users > perfect code (ship MVP, iterate based on feedback)
