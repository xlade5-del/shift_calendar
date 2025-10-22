# 📅 Shift Calendar for Couples

Real-time calendar sync app for couples with shift work schedules.

## 📖 Documentation

- **[PRD v2.0](docs/shift_calendar_prd_v2.md)** - Complete product requirements
- **[MVP Checklist](docs/quick_mvp_checklist.md)** - Week-by-week development guide  
- **[MVP Updates](docs/mvp_updates_summary.md)** - Key decisions and rationale

## 🎯 Current Status

**Phase:** Pre-Development  
**Target Launch:** Q2 2026  
**Timeline:** 20 weeks (16 dev + 4 beta)

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- Firebase account
- Android Studio + Xcode
- Git

### Setup
```bash
# Clone repository
git clone <your-repo-url>
cd shift-calendar

# Install dependencies (once Flutter project is initialized)
flutter pub get

# Run on simulator
flutter run
```

## 🏗️ Tech Stack

- **Mobile:** Flutter
- **Backend:** Firebase (Firestore, Auth, Functions)
- **Local DB:** SQLite
- **Notifications:** FCM + APNs
- **State:** Riverpod

## ✅ MVP Features (P0 Only)

- [ ] Authentication (email, Google, Apple)
- [ ] Partner linking (code + email)
- [ ] Manual shift creation
- [ ] Week view calendar
- [ ] iCal import (1 feed)
- [ ] Real-time sync
- [ ] Offline mode
- [ ] Conflict alerts
- [ ] Push notifications

## 📊 Success Metrics

- 95% sync reliability
- <3s update latency
- 1,000 DAU at 6 months
- 60% D90 retention
- 4.5+ store rating

## 💰 Monetization

**Free:** Core sync, 1 iCal feed, week view  
**Premium ($4.99/mo):** Unlimited feeds, exports, free time finder

## 🗓️ Development Phases

1. **Weeks 1-8:** Auth + Partner Linking + Calendar UI
2. **Weeks 9-12:** Real-time Sync + iCal + Offline
3. **Weeks 13-16:** Notifications + Conflicts + Polish
4. **Weeks 17-20:** Beta Testing + Store Submission

## 🤝 Contributing

This is a solo MVP project. Post-launch, contributions welcome!

## 📄 License

TBD

---

Built with ❤️ to help couples find more time together
