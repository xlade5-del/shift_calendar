# Shift Calendar PRD v2.0 - MVP Critical Updates

## Executive Summary of Changes

This document outlines critical updates to transform the PRD into a realistic, achievable MVP focused on core value delivery.

---

## 🔴 CRITICAL CHANGES IMPLEMENTED

### 1. **Revised Timeline: 14 weeks → 20 weeks**

**OLD (Unrealistic):**
- Week 1-6: MVP Foundation  
- Week 7-10: Enhanced UX
- Week 11-14: AI + Monetization + Launch

**NEW (Realistic):**
- **Week 1-8: Core MVP** (Auth, Partner Linking, Manual Events, Basic Calendar)
- **Week 9-12: Sync & iCal** (Real-time sync, iCal import, offline mode)
- **Week 13-16: Polish & Conflicts** (Notifications, conflict detection, testing)
- **Week 17-20: Beta Testing** (50 couples, bug fixes, store prep)
- **Week 21+: Launch Preparation** (Marketing, support, monitoring)

**Rationale:** Solo development with complex features (cross-platform sync, real-time updates, offline mode) requires realistic time allocation.

---

### 2. **Simplified MVP Scope - P0 Features ONLY**

**REMOVED from MVP (moved to Phase 2):**
- ❌ AI-powered scheduling suggestions
- ❌ Advanced analytics dashboard  
- ❌ PDF export
- ❌ Multiple calendar views (month/day) - Keep WEEK VIEW only
- ❌ Shift templates
- ❌ Advanced premium features

**CORE MVP (P0 Only):**
- ✅ Email/Google/Apple authentication
- ✅ Partner linking via code/email
- ✅ Manual shift creation/editing
- ✅ Single iCal feed import per user
- ✅ Week view calendar (shared)
- ✅ Real-time Firebase sync
- ✅ Offline mode with sync queue
- ✅ Basic conflict alerts (both working same time)
- ✅ Push notifications for changes

---

### 3. **Clear Monetization Model**

#### Free Tier (Core Value):
- Unlimited manual events
- Partner linking (2 people)
- 1 iCal feed per user
- Week calendar view
- Real-time sync
- Conflict alerts
- Push notifications

#### Premium Tier ($4.99/month or $49.99/year):
- **Unlimited iCal feeds** (multiple jobs/calendars)
- **Free time finder** (shows mutual availability)
- **PDF/iCal export**
- **Priority support** (24hr response)
- **Advanced notifications** (customizable)
- **Future: AI suggestions** (post-10k users)

#### Why This Works:
- Free tier delivers core promise: "sync our shifts"
- Premium adds convenience, not core functionality
- Price point: $2.50/person when split
- Clear value prop: "Add your work calendar + partner's = done"

---

### 4. **Technical Specifications Added**

#### Background Sync Strategy:
```
iOS:
- FCM triggers immediate foreground refresh
- Background fetch every 15 minutes (iOS limit)
- Silent push notifications for critical updates

Android:
- FCM triggers immediate updates
- WorkManager periodic sync (15 min minimum)
- Foreground service for active sync

Offline:
- SQLite queue stores pending changes
- Exponential backoff retry (1s, 2s, 4s, 8s...)
- Conflict detection on reconnection
```

#### Conflict Resolution:
```
Strategy: Versioned Optimistic Locking

1. Each event has version field (integer, increments)
2. Client sends current version with updates
3. Server checks: if version matches → accept
4. If mismatch → return conflict with both versions
5. User prompted: "Alex modified after you. Keep yours/theirs/merge?"
6. Auto-merge if only metadata changed (color, notes)
7. Timestamp breaks ties for time conflicts
```

#### iCal Import:
```
- Cloud Function runs every 15 minutes (cron)
- Fetches feed, parses with ical.js
- Compares UID + LAST-MODIFIED
- Inserts new, updates changed, marks source='ical'
- Triggers FCM/APNs for immediate app refresh
```

---

### 5. **Non-Functional Requirements (NFRs)**

| Metric | MVP Target | Production Target | Measurement |
|--------|-----------|------------------|-------------|
| Sync Reliability | ≥95% | ≥99.9% | Firebase Performance |
| Update Latency | <3s | <2s | Firebase Performance |
| Data Loss Rate | <0.5% | <0.1% | Firestore logs |
| App Load Time | <3s | <2s | Firebase Performance |
| Crash-Free Sessions | ≥99% | ≥99.5% | Crashlytics |
| Offline Sync Success | ≥90% | ≥95% | Custom analytics |
| API Response Time | <500ms | <300ms | Firebase Functions logs |

**Why Two Targets:**
- MVP: Achievable with solid engineering
- Production: Goal after optimization and scale testing

---

### 6. **Growth Metrics Added**

| Metric | Target | Measurement Source |
|--------|--------|-------------------|
| Onboarding Completion | >70% | Firebase Analytics |
| Partner Invite Acceptance | >40% | Custom events |
| D1 Retention | >80% | Firebase Analytics |
| D7 Retention | >70% | Firebase Analytics |
| D30 Retention | >65% | Firebase Analytics |
| D90 Retention | >60% | Firebase Analytics |
| Free→Premium Conversion | 20-50% | Stripe + Firebase |
| Monthly Churn | <5% | Stripe subscriptions |
| Feature Adoption (iCal) | >60% | Firebase Analytics |

---

### 7. **Compliance Requirements**

#### GDPR/Privacy:
- ✅ Firestore multi-region (US + EU)
- ✅ Explicit consent for partner linking
- ✅ Data export (iCal format) in settings
- ✅ Account deletion removes all data in 30 days
- ✅ Privacy policy: no third-party sharing except analytics
- ✅ Audit log of consent actions

#### Security:
- ✅ Firebase Auth (tokens, OAuth)
- ✅ Firestore security rules (user-level access)
- ✅ TLS 1.3 + AES-256 encryption
- ✅ App Check (prevent API abuse)
- ✅ Rate limiting on Cloud Functions

---

### 8. **Risk Updates**

| Risk | Impact | NEW Mitigation |
|------|--------|----------------|
| Timeline Slippage | High | 20-week buffer, weekly milestones, cut scope not deadline |
| Sync Reliability | Critical | Extensive testing, staged rollout (10→100→1000 users), kill switch |
| Low Adoption | High | Beta program with 50 couples, Reddit/Facebook targeting shift workers |
| Scope Creep | Medium | Hard freeze on P0 features, defer all P1/P2 to post-MVP |

---

## 📋 UPDATED SPRINT BREAKDOWN

### Phase 1: Core MVP (Weeks 1-8, 240 hours)
**Sprint 1-2 (Week 1-4):** Project setup, Firebase config, Flutter scaffold, auth flows
**Sprint 3-4 (Week 5-8):** Partner linking, manual events, basic calendar UI

### Phase 2: Sync Engine (Weeks 9-12, 120 hours)
**Sprint 5-6 (Week 9-10):** Firebase real-time listeners, local SQLite, sync queue
**Sprint 7-8 (Week 11-12):** iCal import (Cloud Function), offline mode, conflict detection

### Phase 3: UX & Alerts (Weeks 13-16, 120 hours)
**Sprint 9-10 (Week 13-14):** Push notifications (FCM/APNs), conflict alerts UI
**Sprint 11-12 (Week 15-16):** Polish, error handling, settings, onboarding flow

### Phase 4: Beta & Launch (Weeks 17-20, 120 hours)
**Sprint 13-14 (Week 17-18):** Beta with 50 couples, bug fixes, performance tuning
**Sprint 15-16 (Week 19-20):** App store submission, marketing prep, support docs

**Total: 600 hours over 20 weeks (~30 hrs/week solo)**

---

## 🎯 SUCCESS CRITERIA (MVP Launch)

### Must-Have (Go/No-Go):
- [ ] 95% sync reliability in beta
- [ ] <3s average update latency
- [ ] <1% crash rate
- [ ] 2 iCal feeds successfully importing
- [ ] Offline mode works (tested with airplane mode)
- [ ] Conflict resolution tested with 10 scenarios
- [ ] iOS + Android builds approved by stores

### Nice-to-Have (Can Ship Without):
- [ ] 99% sync reliability (target post-launch)
- [ ] <2s latency (optimize later)
- [ ] Advanced onboarding (keep simple)
- [ ] Perfect UI polish (iterate based on feedback)

---

## 🚀 POST-MVP ROADMAP

### Phase 2 (Weeks 21-28): Enhanced UX
- Month/day calendar views
- Free time finder
- Shift templates
- Improved notifications

### Phase 3 (Weeks 29-36): Monetization
- Stripe integration
- Premium features
- Upgrade prompts
- A/B testing

### Phase 4 (Month 6+): AI & Scale
- ML-based suggestions (after 10k users)
- Advanced analytics
- Family mode (3-5 people)
- International expansion

---

## 💡 KEY TAKEAWAYS FOR SOLO DEV

1. **20 weeks is realistic for quality MVP** (not 14)
2. **Week view only** (month/day views are P1)
3. **Rule-based conflicts** (ML-based comes later)
4. **Free tier is complete product** (premium adds convenience)
5. **One iCal feed in free tier** (unlimited in premium)
6. **Beta testing is critical** (50 couples minimum)
7. **NFRs guide development** (don't just "make it work")
8. **Compliance is table stakes** (GDPR, data deletion)
9. **Measure everything** (Firebase Analytics + custom events)
10. **Cut scope, not quality** (defer features, not testing)

---

## 📊 UPDATED AT-A-GLANCE

| Aspect | Detail |
|--------|--------|
| **Problem** | Couples lose 15-20 hrs/month coordinating shifts manually |
| **Solution** | Real-time cross-platform calendar sync with conflict detection |
| **Market** | 5-8M US couples in shift work, $300-400M TAM |
| **MVP Scope** | Auth, partner link, manual events, 1 iCal feed, week view, sync, conflicts |
| **Tech** | Flutter + Firebase (Firestore, Functions, Auth) + SQLite |
| **Timeline** | 16 weeks dev + 4 weeks beta = 20 weeks to launch |
| **Pricing** | Free (core) + $4.99/mo premium (unlimited feeds, exports) |
| **Target** | 1k DAU at 6 months, 60% D90 retention, 4.5+ rating |

---

## ✅ ACTION ITEMS

1. **Accept updated 20-week timeline** or compress by removing features
2. **Freeze P0 scope** - resist any additions during development
3. **Set up Firebase project** and enable Firestore, Auth, Functions
4. **Create Flutter project** with proper folder structure
5. **Build authentication first** (foundation for everything)
6. **Weekly check-ins** against sprint milestones
7. **Beta recruitment** starts week 12 (before completion)

---

**This MVP is achievable, realistic, and fundable.**
