# MVP Development Checklist - Shift Calendar

## Week-by-Week Milestones

### ✅ Phase 1: Foundation (Weeks 1-8)

#### Week 1-2: Setup
- [ ] Firebase project created (Firestore, Auth, Functions enabled)
- [ ] Flutter project initialized with proper folder structure
- [ ] Dev environment configured (Android Studio, Xcode, simulators)
- [ ] Git repository set up with .gitignore

#### Week 3-4: Authentication
- [ ] Email/password auth working
- [ ] Google Sign-In integrated (iOS + Android)
- [ ] Apple Sign-In integrated
- [ ] Auth state persistence
- [ ] Basic profile screen

#### Week 5-6: Partner Linking
- [ ] Generate 6-digit pairing codes
- [ ] Partner invite via email
- [ ] Accept/reject partner requests
- [ ] Unlink partner functionality
- [ ] Partner status indicator

#### Week 7-8: Basic Calendar
- [ ] Week view UI (7 days visible)
- [ ] Add manual shift (title, start/end time, notes)
- [ ] Edit existing shifts
- [ ] Delete shifts
- [ ] Color coding per partner

---

### ✅ Phase 2: Sync Engine (Weeks 9-12)

#### Week 9-10: Real-Time Sync
- [ ] Firestore data model implemented
- [ ] Real-time listeners for changes
- [ ] Local SQLite database
- [ ] Sync queue for offline changes
- [ ] Version tracking per event

#### Week 11-12: iCal + Offline
- [ ] Cloud Function for iCal polling (15 min cron)
- [ ] iCal feed URL input + validation
- [ ] Parse iCal events (ical.js)
- [ ] Offline mode with airplane mode test
- [ ] Exponential backoff retry logic
- [ ] Conflict detection basic implementation

---

### ✅ Phase 3: UX Polish (Weeks 13-16)

#### Week 13-14: Notifications
- [ ] FCM setup (Android)
- [ ] APNs setup (iOS)
- [ ] Push notification for partner shift changes
- [ ] Conflict alert notification
- [ ] Notification settings screen

#### Week 15-16: Polish
- [ ] Onboarding flow (3-4 screens)
- [ ] Error handling + user-friendly messages
- [ ] Loading states + skeleton screens
- [ ] Settings (account, notifications, privacy)
- [ ] Help/FAQ section

---

### ✅ Phase 4: Beta & Launch (Weeks 17-20)

#### Week 17-18: Beta Testing
- [ ] Recruit 50 beta couples (Reddit, Facebook groups)
- [ ] TestFlight (iOS) + Google Play Internal Testing setup
- [ ] Crashlytics + Firebase Analytics enabled
- [ ] Bug tracking sheet
- [ ] Weekly feedback sessions

#### Week 19-20: Store Prep
- [ ] App Store submission (iOS)
- [ ] Google Play submission (Android)
- [ ] Privacy policy written + hosted
- [ ] Terms of service written + hosted
- [ ] Support email set up
- [ ] Marketing website (single page)

---

## 🔴 Critical Paths (Don't Skip!)

1. **Week 10 Checkpoint:** Real-time sync must work reliably (>95%)
2. **Week 12 Checkpoint:** Offline mode must handle 10+ queued changes
3. **Week 14 Checkpoint:** Notifications must deliver within 5 seconds
4. **Week 17 Checkpoint:** Beta recruitment complete (50 couples confirmed)

---

## 🛠️ Tech Stack Checklist

### Flutter Packages
- [ ] `firebase_core` - Firebase initialization
- [ ] `firebase_auth` - Authentication
- [ ] `cloud_firestore` - Real-time database
- [ ] `firebase_messaging` - Push notifications
- [ ] `sqflite` - Local database
- [ ] `provider` or `riverpod` - State management
- [ ] `http` - HTTP requests for iCal
- [ ] `intl` - Date/time formatting
- [ ] `flutter_local_notifications` - Local notifications

### Firebase Setup
- [ ] Firestore database (multi-region: us-central1 + europe-west1)
- [ ] Authentication providers enabled
- [ ] Cloud Functions deployed (Node.js)
- [ ] Firestore security rules configured
- [ ] Firebase App Check enabled

### Testing Tools
- [ ] Flutter test suite
- [ ] Integration tests for sync
- [ ] Airplane mode testing script
- [ ] Load testing (100 concurrent users)

---

## 📊 Success Metrics Tracking

### Development Metrics
- [ ] Code coverage >70%
- [ ] Zero P0/P1 bugs before beta
- [ ] Average PR review time <24 hours
- [ ] Weekly velocity tracking

### Beta Metrics (Week 17-20)
- [ ] Sync reliability ≥95%
- [ ] Crash rate <1%
- [ ] Average latency <3s
- [ ] User feedback score >4.0/5
- [ ] Bug reports triaged within 24h

### Launch Metrics (Month 1)
- [ ] 100+ downloads
- [ ] 4.0+ store rating
- [ ] <5% uninstall rate
- [ ] 80%+ onboarding completion

---

## 🚫 OUT OF SCOPE (Defer to Post-MVP)

- Month/day calendar views
- AI suggestions
- PDF export
- Advanced analytics
- Shift templates
- Multiple premium tiers
- Localization
- Accessibility beyond basic
- Web app
- Desktop app

---

## 🆘 When You're Stuck

### Sync Issues?
1. Check Firestore security rules
2. Verify auth token not expired
3. Test with simple events first
4. Add verbose logging
5. Use Firebase emulator locally

### Offline Mode Not Working?
1. Test SQLite directly (insert/query)
2. Verify sync queue logic
3. Check connectivity listeners
4. Test with multiple offline changes
5. Verify version conflict resolution

### Notifications Not Delivering?
1. Check FCM/APNs tokens registered
2. Verify Cloud Functions trigger
3. Test with Firebase Console (manual send)
4. Check app permissions
5. Review notification payload format

---

## 📞 Resources

- Firebase Docs: https://firebase.google.com/docs/flutter
- Flutter Docs: https://docs.flutter.dev
- iCal Spec: https://tools.ietf.org/html/rfc5545
- r/FlutterDev: Reddit community
- Stack Overflow: flutter + firebase tags

---

**Remember: Ship P0 features with quality, defer everything else.**
