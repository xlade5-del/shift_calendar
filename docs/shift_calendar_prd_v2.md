# VelloShift - Product Requirements Document v2.1

**Version:** 2.1 - MVP Focused
**Last Updated:** November 2025
**Status:** Week 17-20 Complete, Ready for Beta Testing (Week 21-24)
**Target Launch:** Q1 2026 (24 weeks development + testing)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Problem Statement](#problem-statement)
3. [Solution Overview](#solution-overview)
4. [User Personas](#user-personas)
5. [Technical Architecture](#technical-architecture)
6. [Functional Requirements](#functional-requirements)
7. [Non-Functional Requirements](#non-functional-requirements)
8. [Monetization Model](#monetization-model)
9. [Implementation Plan](#implementation-plan)
10. [Success Metrics](#success-metrics)
11. [Future Expansion](#future-expansion)
12. [Appendix](#appendix)

---

## 1. Executive Summary

### 1.1 Vision

**Mission:** Helping couples find more time together — not just sync their shifts.

VelloShift is a cross-platform mobile application designed to eliminate the friction couples experience when managing complex, rotating work schedules across iOS and Android devices. Built specifically for shift workers in healthcare, emergency services, retail, and hospitality, the app provides seamless, real-time calendar synchronization with automatic conflict detection and free time identification.

### 1.2 At-a-Glance

| Aspect | Detail |
|--------|--------|
| **Problem** | Couples lose 15-20 hours/month coordinating shifts manually; cross-platform sync is unreliable |
| **Solution** | Real-time cross-platform calendar sync with conflict detection and iCal import |
| **Market** | 5-8M US couples in shift work industries, $300-400M TAM |
| **MVP Scope** | Auth, partner linking, manual events, 1 iCal feed, week view, real-time sync, offline mode, conflict alerts |
| **Tech Stack** | Flutter + Firebase (Firestore, Auth, Functions) + SQLite + FCM/APNs |
| **Timeline** | 20 weeks development + 4 weeks beta testing = 24 weeks to launch |
| **Pricing** | Free (core features) + $3.99/month premium (unlimited feeds, exports) |
| **Target Metrics** | 1k DAU at 6 months, 60% D90 retention, 4.5+ store rating, 95% sync reliability |

### 1.3 Key Objectives

| Objective | Target | Timeline |
|-----------|--------|----------|
| Reliable cross-platform sync | 95% success rate | MVP launch (Week 16) |
| Real-time updates | <3 second latency | MVP launch |
| User acquisition | 1,000 daily active users | 6 months post-launch |
| User satisfaction | 4.5+ store rating | Ongoing |
| User retention | 60% Day-90 retention | 3 months post-launch |
| Monetization validation | 20-50% premium conversion | 3-6 months post-launch |

### 1.4 Expected Impact

**User Benefits:**
- Eliminate 15-20 hours per month of manual schedule coordination
- Reduce schedule-related conflicts and missed plans by 85%
- Increase quality time together through proactive free time identification
- Provide peace of mind through reliable, always-current schedule visibility

**Business Benefits:**
- Capture first-mover advantage in relationship-focused calendar synchronization
- Establish platform for recurring subscription revenue
- Build defensible moat through superior sync technology
- Create foundation for expansion into family scheduling and group coordination

---

## 2. Problem Statement

### 2.1 Current Market Situation

The calendar application market is dominated by platform-specific solutions (Apple Calendar, Google Calendar) and general productivity tools that prioritize individual use cases over relationship coordination. While these applications offer basic calendar sharing, they fail to address the specific needs of couples managing complex shift schedules across different mobile platforms.

**Market Data:**
- 42% of US workforce works non-standard hours (Bureau of Labor Statistics, 2024)
- 68% of couples report difficulty coordinating schedules when both partners work shifts
- Android holds 43% US market share, iOS 57%, making cross-platform sync essential
- Average couple spends 3-4 hours weekly manually coordinating schedules

### 2.2 User Pain Points

| Pain Point | Real-World Impact |
|------------|-------------------|
| **Cross-Platform Sync Failure** | Sarah (iOS) shares her nursing schedule with Mike (Android). Mike's calendar shows updates 30-60 minutes late or not at all, leading to missed pickups and childcare conflicts. |
| **Manual Entry Burden** | James gets his retail schedule via PDF. He spends 20 minutes every week manually entering shifts, then screenshots to share with his partner who re-enters them into Apple Calendar. |
| **Missed Schedule Changes** | Elena's shifts change frequently. Her partner doesn't know about last-minute updates, resulting in double-booked commitments and wasted time. |
| **No Conflict Detection** | David and Rachel both work irregular hours. They frequently discover conflicts (both working the same evening) only when it's too late to arrange childcare. |
| **Poor Free Time Visibility** | Marcus and Lisa can't easily identify when they're both free. They spend hours texting back and forth trying to find mutual availability for date nights. |

### 2.3 Market Opportunity

| Market Segment | Size (US) | Pain Level |
|----------------|-----------|------------|
| Healthcare Workers | 2.8M couples | High |
| Emergency Services | 1.2M couples | High |
| Retail & Hospitality | 4.5M couples | Medium |
| Manufacturing | 2.1M couples | Medium |

**Total Addressable Market:** 5-8 million couples in the United States, with global expansion potential of 50+ million couples. At a premium subscription rate of $3.99/month per couple, this represents annual recurring revenue potential of $240-320 million in the US market.

**Cost of Inaction:** Without a purpose-built solution, users continue losing 15-20 hours monthly to manual coordination, experiencing relationship stress, missing important events, and accepting suboptimal schedule management as inevitable.

---

## 3. Solution Overview

### 3.1 How It Works

The Shift Calendar for Couples employs a three-layer synchronization architecture:

#### Layer 1: Real-Time Cloud Database
All calendar events are stored in Firebase Firestore, serving as the single source of truth. When either partner creates, modifies, or deletes an event, the change is immediately propagated via Firebase real-time listeners, ensuring sub-2-second latency for updates.

#### Layer 2: iCal Integration
Users can connect existing work calendars (Google Calendar, Apple Calendar, or any iCal-compatible system). The application polls external calendars every 15 minutes via Cloud Functions to detect changes from third-party sources, ensuring comprehensive visibility even when schedules are managed through multiple systems.

#### Layer 3: Offline Resilience
A local SQLite database caches all data for offline access. When connectivity is lost, changes are queued and automatically synchronized when the device comes back online, with versioned conflict resolution to handle simultaneous edits.

### 3.2 Technical Architecture

#### Background Sync Strategy

**iOS:**
- Firebase Cloud Messaging (FCM) triggers immediate foreground refresh
- Background fetch every 15 minutes (iOS platform limit)
- Silent push notifications for critical updates

**Android:**
- FCM triggers immediate updates
- WorkManager schedules periodic sync (15 minute minimum)
- Foreground service for active sync sessions

**Offline Handling:**
- SQLite queue stores pending changes with timestamps
- Exponential backoff retry: 1s, 2s, 4s, 8s, 16s, 32s
- Conflict detection on reconnection with user prompts

#### Conflict Resolution

**Strategy: Versioned Optimistic Locking**

1. Each event has a version field (integer that increments with each change)
2. Client sends current version number with all update requests
3. Server validates: if version matches → accept change and increment version
4. If version mismatch → return conflict with both versions
5. User prompted: "Alex modified this shift after you. Keep yours, keep theirs, or merge?"
6. Auto-merge if only metadata changed (color, notes, non-time fields)
7. Timestamp-based last-write-wins for irreconcilable time conflicts

#### iCal Import Process

- Cloud Function runs every 15 minutes (scheduled via Firebase cron)
- Fetches iCal feed via HTTPS, parses events using ical.js library
- Compares UID + LAST-MODIFIED fields against existing database
- Inserts new events, updates changed events, marks source as 'ical-import'
- Triggers FCM/APNs notifications for immediate app refresh
- Real-time sync propagates imported changes to partner's device

### 3.3 Technology Stack

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| **Mobile Framework** | Flutter | Single codebase for iOS/Android, native performance, excellent UI toolkit |
| **Backend** | Firebase | Managed services, real-time database, built-in auth, generous free tier |
| **Database (Cloud)** | Firestore | Real-time sync, offline support, automatic scaling, integrated ecosystem |
| **Database (Local)** | SQLite | Offline data cache, sync queue, user preferences |
| **Authentication** | Firebase Auth | Email/password, Google, Apple Sign-In, secure token management |
| **Push Notifications** | FCM + APNs | Native platform support, reliable delivery, cross-platform |
| **Cloud Functions** | Node.js | iCal polling, conflict detection triggers, data validation |
| **State Management** | Provider/Riverpod | Simple, performant, Flutter-idiomatic |

### 3.4 Core Differentiators

- **True Real-Time Sync:** Firebase-based architecture delivers updates in under 2 seconds (vs 5-15 minute delays with competitors)
- **Relationship-First Design:** Purpose-built for couples with shared views, free time visualization, and partner-oriented notifications
- **Cross-Platform Excellence:** Single codebase ensures feature parity and consistent UX on both platforms
- **Smart Automation:** Rule-based conflict detection identifies overlaps and free time windows automatically
- **Offline Resilience:** Full functionality without internet, automatic sync when connectivity returns

---

## 4. User Personas

### 4.1 Persona 1: Alex - The Rotating Shift Worker

**Demographics:**
- Age: 29
- Device: Android (Samsung Galaxy)
- Occupation: Warehouse logistics coordinator with rotating 4-on/3-off schedule
- Relationship: Partnered for 3 years, no children
- Technical Proficiency: Moderate - comfortable with apps but not a power user

**Current Workflow:**
Alex receives monthly schedules via email as PDF attachments. He manually enters each shift into Google Calendar, then shares it with partner Jamie (iPhone user). The sharing works inconsistently - sometimes updates appear hours later, sometimes not at all. When supervisors make last-minute changes via text, Alex must remember to update both calendar and notify Jamie separately.

**Pain Points:**
- Spends 30 minutes monthly manually entering shifts from PDF
- Calendar sharing with iPhone user is unreliable and slow
- Must manually notify partner of schedule changes via separate texts
- Frequently discovers conflicts when partner books plans during work shifts

**Goals:**
- Automatically sync schedule without manual entry
- Ensure partner always has current schedule visibility
- Eliminate miscommunication about availability

**Quote:** *"I just want Jamie to know when I'm working without having to text every time something changes. Half the time I forget to update the calendar and we end up with plans we can't keep."*

### 4.2 Persona 2: Jamie - The Healthcare Professional

**Demographics:**
- Age: 31
- Device: iOS (iPhone 14)
- Occupation: Registered nurse with 12-hour shifts, frequent overtime and on-call duties
- Relationship: Partnered for 3 years with Alex
- Technical Proficiency: High - early adopter, uses multiple productivity apps

**Current Workflow:**
Jamie's hospital uses a proprietary scheduling system that publishes an iCal feed. She subscribes to this feed in Apple Calendar, which works well for her device. However, sharing this schedule with Alex is problematic - the shared calendar connection drops frequently, requires re-authorization, and often shows outdated information. When she picks up extra shifts or gets called in for emergencies, there's no automatic way to notify Alex.

**Pain Points:**
- iCal subscription doesn't sync reliably with partner's Android device
- Last-minute shift changes and call-ins create communication chaos
- Can't easily identify mutual free time for planning activities
- Feels guilty when scheduling conflicts cause partner inconvenience

**Goals:**
- Maintain professional iCal integration while sharing seamlessly with partner
- Get instant notifications when schedule changes affect shared plans
- Easily visualize when both partners are free

**Quote:** *"My schedule is unpredictable enough without technology making it worse. I need something that just works, especially when I get called in last minute and Alex needs to know immediately."*

### 4.3 Persona 3: The Couple - Shared Coordination Needs

**Joint Characteristics:**
- Both partners work non-traditional hours
- Use different mobile platforms (Android + iOS)
- Value quality time together but struggle to find and protect it
- Experience relationship stress from scheduling miscommunication

**Shared Needs:**
- Unified view showing both partners' schedules with color coding
- Automatic detection of conflicts (both working same time) and free windows
- Smart notifications for schedule conflicts, mutual free time, upcoming shared events
- Planning assistance for optimal times for date nights and appointments

**Success Criteria:**
- Reduce scheduling conflicts by 85%
- Identify 3-5 additional hours of quality time together per month
- Eliminate manual schedule coordination tasks
- Decrease relationship stress related to schedule management

**Quote:** *"We're tired of playing schedule tetris over text messages. We just want to know when we're both free so we can actually spend time together."*

---

## 5. Technical Architecture

### 5.1 System Components

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Mobile App** | Flutter, Dart, Provider/Riverpod | Cross-platform UI, business logic, state management |
| **Authentication** | Firebase Authentication | User identity, secure tokens, OAuth providers |
| **Real-Time Database** | Cloud Firestore | Calendar events, user profiles, couple relationships |
| **Local Storage** | SQLite, Hive | Offline cache, sync queue, user preferences |
| **Backend Functions** | Cloud Functions (Node.js) | iCal polling, conflict detection, validation |
| **Push Notifications** | FCM, APNs | Schedule updates, conflicts, reminders |
| **API Integrations** | iCal parser, Google/Apple Calendar APIs | External calendar import, bidirectional sync |
| **Analytics** | Firebase Analytics, Crashlytics | User behavior, performance monitoring, error tracking |

### 5.2 Data Flow

#### Event Creation Flow

1. User creates event in mobile app (Android or iOS)
2. App validates event data locally and saves to SQLite with version ID
3. If online: Event immediately sent to Firestore via authenticated API
4. Firestore updates collection with new document and increments version
5. Real-time listener triggers, pushing update to all connected devices
6. Partner's device receives update, compares version IDs, merges with local database
7. If offline: Event queued in sync queue for transmission when online

#### iCal Import Flow

1. Cloud Function polls iCal feed every 15 minutes (scheduled cron job)
2. System fetches iCal file via HTTPS, parses events using ical.js
3. Events compared against existing database using UID and LAST-MODIFIED
4. New or modified events inserted/updated with source tag 'ical-import'
5. FCM/APNs notification sent to trigger immediate app refresh
6. Real-time sync propagates imported changes to partner's device

### 5.3 Data Model

#### Users Collection

```javascript
{
  userId: string (primary key),
  email: string (unique),
  name: string,
  partnerId: string (foreign key, nullable),
  icalFeeds: array[{
    url: string,
    lastSync: timestamp,
    syncInterval: integer (minutes)
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

#### Events Collection

```javascript
{
  eventId: string (primary key),
  userId: string (foreign key),
  title: string (1-200 chars),
  startTime: timestamp,
  endTime: timestamp,
  notes: string (max 1000 chars, optional),
  color: string (hex code),
  source: enum['manual', 'ical', 'google', 'apple'],
  icalUid: string (nullable),
  version: integer,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### Sync Queue (Local SQLite)

```sql
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY,
  operation TEXT CHECK(operation IN ('create', 'update', 'delete')),
  event_data TEXT (JSON),
  timestamp INTEGER,
  retry_count INTEGER DEFAULT 0,
  status TEXT CHECK(status IN ('pending', 'syncing', 'failed'))
);
```

### 5.4 Security and Compliance

#### Security Architecture

- **Authentication:** Firebase Auth with email/password, Google Sign-In, Apple Sign-In
- **Authorization:** Firestore security rules enforce user-level and couple-level access
- **Data Encryption:** TLS 1.3 in transit, AES-256 at rest (managed by Firebase)
- **API Security:** Firebase App Check prevents unauthorized API access
- **Rate Limiting:** Cloud Functions enforce limits (100 req/min per user)

#### Compliance Framework

- **Data Storage:** Firestore multi-region (US + EU) for GDPR compliance
- **User Consent:** Explicit consent flow for calendar access and partner linking with audit log
- **Data Retention:** Events retained for 2 years, deleted events soft-deleted for 30 days
- **Right to Delete:** Users can export all data (iCal format) and request full account deletion
- **Privacy Policy:** Clear disclosure of data usage, no third-party sharing except analytics
- **Audit Trail:** All consent actions logged with timestamps

### 5.5 Scalability

- **Database Sharding:** User data partitioned by user ID (not needed until 100k+ users)
- **CDN Distribution:** Static assets served via Firebase Hosting CDN
- **Connection Management:** Firebase automatically scales WebSocket connections
- **Background Jobs:** Cloud Functions with Firestore triggers handle async work
- **Auto-Scaling:** Firebase automatically scales based on demand

---

## 6. Functional Requirements

### 6.1 MVP Feature Scope (P0 - Must Have)

#### Authentication & Account Management
- **US-001:** User can create account using email/password, Google, or Apple Sign-In
  - Email verification required for email/password signup
  - Password requirements: 8+ characters, mixed case, numbers
  - Successful signup redirects to partner connection flow
  
#### Partner Linking
- **US-002:** User can link partner's account using email invite or 6-digit code
  - Generate unique pairing code valid for 24 hours
  - Both partners must approve the connection
  - Display confirmation with partner's name and profile
  - Support unlinking with mutual consent

#### Manual Event Management
- **US-003:** User can create shift events with title, date/time, and optional notes
  - Title field required (1-200 characters)
  - Date/time picker with start and end times
  - Optional notes field (up to 1000 characters)
  - Color coding options for different shift types
  - Events immediately sync to cloud and partner's device
  
- **US-004:** User can edit or delete their shift events
  - Edit all event fields (title, time, notes, color)
  - Delete with confirmation dialog
  - Changes propagate to partner in <3 seconds
  - Option to undo recent changes (5-minute window)

#### Calendar View
- **US-005:** User can view shared week calendar showing both partners' schedules
  - Week view with 7 days visible
  - Distinct colors for each partner's events
  - Visual indication of overlapping shifts (conflict highlight)
  - Tap event to view full details
  - Smooth scrolling and touch gestures

#### iCal Integration
- **US-006:** User can connect one iCal feed URL to import work schedule
  - Input field validates HTTPS URL format
  - Test connection before saving
  - Polling interval: 15 minutes
  - Display last sync timestamp
  - Show sync errors with actionable messages

#### Offline Mode
- **US-007:** App works offline and automatically syncs when connectivity returns
  - All calendar operations work without internet
  - Changes queued in local database
  - Automatic sync when connectivity detected
  - Conflict resolution with user notification
  - Visual indicator showing online/offline status

#### Notifications
- **US-008:** User receives push notifications when partner's schedule changes
  - Notification for new events created by partner
  - Notification for modified events with change summary
  - Notification for deleted events
  - User can customize notification preferences
  - Quiet hours setting (no notifications during sleep)

#### Conflict Detection
- **US-009:** User receives automatic alerts when both partners work at same time
  - Detect overlapping work events automatically
  - Notification sent immediately when conflict detected
  - Show conflict details: date, time, event titles
  - Option to mark conflicts as acknowledged
  - Configurable advance warning (24h, 48h, 1 week)

### 6.2 Feature Priority Matrix

| Priority | Definition | Features |
|----------|-----------|----------|
| **P0 (Critical)** | Required for MVP launch. Without these, app cannot function. | Auth, partner linking, manual events, 1 iCal feed, week view, real-time sync, offline mode, basic notifications, conflict alerts |
| **P1 (High)** | Highly valuable features that significantly improve UX. Launch in Phase 2. | Month/day calendar views, free time finder, advanced notifications, event templates, multiple iCal feeds |
| **P2 (Medium)** | Nice-to-have features that add polish. Launch in Phase 3+. | AI suggestions, PDF export, advanced analytics, premium tiers, family mode, localization |

### 6.3 Out of Scope for MVP

The following features are explicitly excluded from MVP to maintain focus and timeline:

- ❌ AI-powered scheduling suggestions (requires 10k+ users for ML training)
- ❌ Advanced analytics dashboard (defer to post-monetization)
- ❌ PDF/iCal export (premium feature for Phase 3)
- ❌ Month and day calendar views (start with week view only)
- ❌ Shift templates and recurring events (P1 feature)
- ❌ Multiple premium subscription tiers (single tier initially)
- ❌ Localization beyond English (add Spanish in Phase 4)
- ❌ Advanced accessibility features (beyond basic compliance)
- ❌ Web application (mobile-first strategy)
- ❌ Desktop applications (not in roadmap)

---

## 7. Non-Functional Requirements

Non-functional requirements define system performance, reliability, and quality attributes that are critical for user trust and satisfaction. These are measurable targets with two levels: MVP targets (achievable with solid engineering) and Production targets (goals after optimization).

### 7.1 Performance Requirements

| Metric | MVP Target | Production Target | Measurement Method |
|--------|-----------|------------------|-------------------|
| **Sync Reliability** | ≥95% | ≥99.9% | Firebase Performance Monitoring |
| **Update Latency** | <3 seconds | <2 seconds | Firebase Performance Monitoring |
| **Data Loss Rate** | <0.5% | <0.1% | Firestore transaction logs |
| **App Load Time** | <3 seconds | <2 seconds | Firebase Performance Monitoring |
| **Offline Sync Success** | ≥90% | ≥95% | Custom analytics events |
| **API Response Time** | <500ms | <300ms | Cloud Functions logs |

### 7.2 Reliability Requirements

| Metric | MVP Target | Production Target | Measurement Method |
|--------|-----------|------------------|-------------------|
| **Crash-Free Sessions** | ≥99.0% | ≥99.5% | Firebase Crashlytics |
| **Uptime (Firebase)** | ≥99.5% | ≥99.9% | Firebase Status Dashboard |
| **Successful Push Delivery** | ≥95% | ≥98% | FCM/APNs analytics |
| **iCal Import Success** | ≥90% | ≥95% | Cloud Function logs |

### 7.3 Usability Requirements

- **Onboarding Completion:** >70% of new users complete setup within first session
- **Time to First Value:** User can view partner's calendar within 5 minutes of signup
- **Error Recovery:** Clear error messages with actionable next steps (no technical jargon)
- **Accessibility:** Basic compliance with iOS/Android accessibility guidelines
- **Load States:** All operations show loading indicators within 100ms

### 7.4 Security Requirements

- **Authentication:** Multi-factor authentication for sensitive operations (account deletion, partner unlinking)
- **Session Management:** JWT tokens expire after 1 hour, refresh tokens valid for 30 days
- **Data Encryption:** All data encrypted in transit (TLS 1.3) and at rest (AES-256)
- **API Rate Limiting:** Max 100 requests per minute per user
- **Penetration Testing:** Security audit before public launch

### 7.5 Compliance Requirements

- **GDPR:** Data export, deletion, and consent management
- **CCPA:** Privacy policy and opt-out mechanisms
- **App Store Guidelines:** Compliance with Apple App Store and Google Play policies
- **Data Residency:** Multi-region Firestore (US + EU) for compliance

---

## 8. Monetization Model

### 8.1 Free vs Premium Tiers

| Feature | Free Tier | Premium Tier ($3.99/month) |
|---------|-----------|---------------------------|
| **Manual Events** | ✅ Unlimited | ✅ Unlimited |
| **Partner Linking** | ✅ 1 partner (2 people) | ✅ 1 partner (2 people) |
| **Calendar View** | ✅ Week view | ✅ Week + month + day views |
| **iCal Feeds** | ✅ 1 feed per user | ✅ Unlimited feeds |
| **Real-Time Sync** | ✅ Included | ✅ Included |
| **Conflict Alerts** | ✅ Basic notifications | ✅ Advanced customization |
| **Offline Mode** | ✅ Included | ✅ Included |
| **Free Time Finder** | ❌ | ✅ Shows mutual availability |
| **Export** | ❌ | ✅ PDF & iCal export |
| **AI Suggestions** | ❌ | ✅ Coming post-10k users |

### 8.2 Pricing Strategy

**Price Point:**
- Monthly: $3.99/month per couple
- Annual: $39.99/year (~$3.33/month, 17% discount)
- Free Trial: 7 days full premium access, no credit card required

**Rationale:**
- Price aligns with productivity app market ($3-7/month range)
- Couples typically share cost, making it ~$2.00/person
- Annual discount incentivizes longer commitment and reduces churn
- Free tier provides unlimited core value; premium adds convenience

**Value Proposition:**
- Free tier promise: "Sync your shifts with your partner"
- Premium promise: "Add multiple work calendars + get smart insights"
- Clear upgrade trigger: When users need to import multiple iCal feeds

### 8.3 Conversion Strategy

**Upgrade Prompts:**
- When user attempts to add 2nd iCal feed (natural upgrade moment)
- After 30 days of active use (proven engagement)
- When tapping "Free Time Finder" feature (locked behind premium)
- Soft prompts in settings with benefits list

**A/B Testing Plan (Post-MVP):**
1. **Price Points:** Test $3.99, $4.99, $5.99 monthly pricing
2. **Trial Length:** Compare 7-day vs 14-day vs 30-day free trials
3. **Feature Gating:** Test which premium features drive most upgrades
4. **Upgrade Timing:** Test timing of upgrade prompts (day 7, 14, 30)

### 8.4 Revenue Projections

**Conservative Scenario (Year 1):**
- Month 1: 100 users (50 couples)
- Month 6: 2,000 users (1,000 couples)
- Month 12: 10,000 users (5,000 couples)
- Premium Conversion: 30%
- Monthly Recurring Revenue (MRR) at Month 12: $7,485

**Optimistic Scenario (Year 1):**
- Month 1: 200 users (100 couples)
- Month 6: 4,000 users (2,000 couples)
- Month 12: 20,000 users (10,000 couples)
- Premium Conversion: 50%
- Monthly Recurring Revenue (MRR) at Month 12: $24,950

**Assumptions:**
- 80% of users remain partnered (1 user = 0.5 couple on average)
- 5% monthly churn rate
- Annual plan adoption: 30% of premium users

---

## 9. Implementation Plan

### 9.1 Development Timeline Overview

**Total Duration:** 24 weeks (20 weeks development + 4 weeks beta testing)

- **Phase 1:** Core MVP (Weeks 1-12) - Auth, partner linking, calendar, real-time sync ✅ COMPLETE
- **Phase 2:** UX Polish (Weeks 13-16) - Notifications, conflicts, settings ✅ COMPLETE
- **Phase 3:** Advanced Features (Weeks 17-20) - Offline mode, iCal, shift management, onboarding ✅ COMPLETE
- **Phase 4:** Beta & Launch (Weeks 21-24) - Testing, Cloud Functions deployment, store submission 🔄 IN PROGRESS

**Effort Estimate:** 720 hours total (~30 hours/week for solo developer)

### 9.2 Detailed Sprint Breakdown

#### Phase 1: Core MVP Foundation (Weeks 1-8, 240 hours)

**Sprint 1-2 (Weeks 1-4): Setup & Authentication**
- Firebase project setup (Firestore, Auth, Functions, Hosting)
- Flutter project initialization with proper folder structure
- Development environment configuration (Android Studio, Xcode)
- Email/password authentication implementation
- Google Sign-In integration (iOS + Android)
- Apple Sign-In integration
- Auth state persistence
- Basic profile screen with logout

**Sprint 3-4 (Weeks 5-8): Partner Linking & Calendar UI**
- Generate unique 6-digit pairing codes (expires in 24 hours)
- Partner invite via email with deep linking
- Accept/reject partner request flows
- Unlink partner functionality with confirmation
- Week view calendar UI (7 days horizontal scroll)
- Manual shift creation form (title, start/end time, notes, color)
- Edit and delete shift functionality
- Color coding per partner (visual distinction)

#### Phase 2: Sync Engine (Weeks 9-12, 120 hours)

**Sprint 5-6 (Weeks 9-10): Real-Time Sync**
- Firestore data model implementation (users, events collections)
- Real-time listeners for partner's events
- Local SQLite database schema
- Sync queue implementation for offline changes
- Version tracking per event (optimistic locking)
- Basic conflict detection logic
- Sync status indicators in UI

**Sprint 7-8 (Weeks 11-12): iCal & Offline Mode**
- iCal feed URL input and validation
- Cloud Function for iCal polling (15-minute cron schedule)
- iCal event parsing using ical.js library
- UID and LAST-MODIFIED comparison logic
- Offline mode with airplane mode testing
- Exponential backoff retry logic (1s, 2s, 4s, 8s...)
- Conflict resolution UI (keep yours, theirs, or merge)

#### Phase 3: UX Polish (Weeks 13-16, 120 hours)

**Sprint 9-10 (Weeks 13-14): Notifications**
- Firebase Cloud Messaging (FCM) setup for Android
- Apple Push Notifications (APNs) setup for iOS
- Push notification for partner shift changes
- Conflict alert notification implementation
- Notification settings screen (enable/disable by type)
- Quiet hours configuration
- Badge counts and in-app notification history

**Sprint 11-12 (Weeks 15-16): Final Polish**
- Onboarding flow (welcome, permissions, partner invite)
- Error handling with user-friendly messages
- Loading states and skeleton screens
- Settings screen (account, notifications, privacy)
- Help section with FAQ
- Privacy policy and terms of service
- App icon and splash screen
- Performance optimization and bug fixes

#### Phase 4: Beta Testing & Launch (Weeks 17-20, 120 hours)

**Sprint 13-14 (Weeks 17-18): Beta Testing**
- Recruit 50 beta couples via Reddit, Facebook groups
- TestFlight (iOS) and Google Play Internal Testing setup
- Firebase Crashlytics and Analytics implementation
- Bug tracking spreadsheet with priorities
- Weekly feedback sessions with beta users
- Performance monitoring and optimization
- Critical bug fixes

**Sprint 15-16 (Weeks 19-20): Store Preparation**
- App Store submission (iOS)
- Google Play submission (Android)
- Privacy policy written and hosted
- Terms of service written and hosted
- Support email setup (support@shiftcalendar.app)
- Marketing website (single landing page)
- App store screenshots and descriptions
- Final QA testing
- Monitoring and alerting setup

### 9.3 Critical Path Milestones

| Milestone | Week | Criteria | Go/No-Go |
|-----------|------|----------|----------|
| **Auth Complete** | 4 | All 3 sign-in methods working on both platforms | Must pass |
| **Sync Working** | 10 | Real-time sync >95% reliable in testing | Must pass |
| **Offline Tested** | 12 | Offline mode handles 10+ queued changes | Must pass |
| **Notifications Live** | 14 | Push notifications deliver within 5 seconds | Must pass |
| **Beta Recruited** | 17 | 50 couples confirmed and onboarded | Must pass |
| **Stores Approved** | 20 | iOS + Android approved for public release | Must pass |

### 9.4 Team Composition

**MVP Phase (Solo Developer):**
- Full-stack development using Flutter + Firebase
- UI/UX design using Flutter widgets and Material/Cupertino
- AI-assisted coding with Claude Code and Cursor
- Manual testing and QA
- DevOps via Firebase managed services

**Post-MVP Scaling:**
- UI/UX Designer (contract): Professional design refinement
- Backend Engineer (full-time): Advanced sync features, scaling
- Product Manager (part-time): User research, roadmap planning
- Customer Support (contract): Email support, FAQ maintenance

### 9.5 Risk Management

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|-----------|--------|-------------------|
| **Timeline Slippage** | High | High | 20-week buffer built in, weekly milestone tracking, cut scope not deadline |
| **Sync Reliability** | Medium | Critical | Extensive testing, staged rollout (10→100→1000 users), kill switch for rollback |
| **Low User Adoption** | Medium | High | Beta program with 50 couples, target shift worker communities on Reddit/Facebook |
| **Scope Creep** | High | Medium | Hard freeze on P0 features, all new ideas go to P1/P2 backlog |
| **Firebase Costs** | Low | Medium | Monitor usage daily, optimize queries, set billing alerts at $100/month |
| **Platform Rejections** | Low | High | Follow all guidelines strictly, pre-review with checklist, appeal if rejected |

---

## 10. Success Metrics

### 10.1 Key Performance Indicators (KPIs)

| Metric | MVP Target | 6-Month Target | Measurement Source |
|--------|-----------|----------------|-------------------|
| **Sync Success Rate** | ≥95% | ≥99% | Firebase Performance |
| **Update Latency** | <3 seconds | <2 seconds | Firebase Performance |
| **Daily Active Users (DAU)** | 100 | 1,000 | Firebase Analytics |
| **Day-90 Retention** | ≥60% | ≥65% | Firebase Analytics |
| **App Store Rating** | ≥4.5 | ≥4.7 | App Store & Play Store |
| **Crash-Free Sessions** | ≥99% | ≥99.5% | Firebase Crashlytics |
| **Free→Premium Conversion** | 20% | 50% | Stripe + Firebase |
| **Monthly Churn Rate** | <10% | <5% | Stripe analytics |

### 10.2 Growth Metrics

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Onboarding Completion Rate** | >70% | Firebase Analytics funnel |
| **Partner Invite Acceptance Rate** | >40% | Custom event tracking |
| **Day-1 Retention** | >80% | Firebase Analytics |
| **Day-7 Retention** | >70% | Firebase Analytics |
| **Day-30 Retention** | >65% | Firebase Analytics |
| **iCal Feature Adoption** | >60% | Custom event tracking |
| **Average Session Duration** | 3-5 minutes | Firebase Analytics |
| **Sessions Per Day Per User** | 2-3 | Firebase Analytics |

### 10.3 Funnel Metrics

**Acquisition Funnel:**
1. App Store page view → Install: Target >20%
2. App open → Account creation: Target >80%
3. Account creation → Partner linked: Target >70%
4. Partner linked → First event created: Target >90%

**Monetization Funnel:**
1. Free user → Sees premium feature: Target >90%
2. Sees premium → Clicks upgrade: Target >40%
3. Clicks upgrade → Starts trial: Target >60%
4. Trial → Converts to paid: Target >50%

### 10.4 Measurement Methods and Tools

| Tool | Purpose | Metrics Tracked |
|------|---------|----------------|
| **Firebase Analytics** | User behavior, engagement | DAU, MAU, retention, funnels, events |
| **Firebase Performance** | App performance | Load times, network latency, sync speed |
| **Firebase Crashlytics** | Stability monitoring | Crash-free rate, error logs, stack traces |
| **Stripe Dashboard** | Revenue tracking | MRR, churn, conversion, ARPU |
| **Mixpanel** | Advanced analytics | Cohort analysis, user paths, A/B tests |
| **App Store Connect** | iOS metrics | Downloads, ratings, reviews |
| **Google Play Console** | Android metrics | Downloads, ratings, reviews |

### 10.5 Review Intervals

- **Daily:** Sync reliability, crash rate, API error rate, Firebase costs
- **Weekly:** DAU/MAU, retention cohorts, feature adoption, user feedback
- **Monthly:** Premium conversion, churn analysis, revenue metrics, store ratings
- **Quarterly:** OKR progress, market positioning, roadmap adjustments

---

## 11. Future Expansion Opportunities

*Note: These features are explicitly excluded from MVP. Only pursue after achieving product-market fit with core couple use case and reaching 1,000+ DAU.*

### 11.1 Family Mode (Post-MVP Phase 2)

**Target Users:** Parents coordinating children's activities, sports, school events

**Features:**
- Support 3-5 family members instead of 2 partners
- Color-coded calendars per family member
- Parent/child permission hierarchy (parents can edit all, children see all)
- Family-wide event categories (school, sports, medical, social)
- Shared family to-do lists

**Market Expansion:** 2-3x TAM (families with children under 18)

### 11.2 Roommate/Friend Groups

**Target Users:** College students, shared living arrangements, friend groups

**Features:**
- Group size: 2-6 people
- Shared household events (chores, bills due, guests visiting)
- Optional privacy controls per event (visible to all or specific people)
- Split billing for premium (divide cost among group)

**Market Expansion:** 4-5x TAM (students and young professionals)

### 11.3 Advanced AI Features (Post-10k Users)

*Requires sufficient historical data and user base to train ML models*

**Rule-Based → ML-Based Evolution:**
- Pattern recognition for optimal date night times based on past acceptances
- Predictive conflict warnings based on historical shift patterns
- Personalized activity suggestions for free time windows
- Smart scheduling that learns user preferences over time

**Data Requirements:**
- Minimum 10,000 active users
- 6+ months of historical data per user
- Explicit consent for ML training

### 11.4 International Expansion

**Phase 1:** English-speaking markets (UK, Canada, Australia)
**Phase 2:** Spanish localization (Spain, Latin America)
**Phase 3:** European languages (French, German, Italian)

**Requirements:**
- Full localization (UI, help docs, support)
- Regional data storage compliance
- Currency support for pricing
- Time zone handling improvements

---

## 12. Appendix

### 12.1 Glossary

| Term | Definition |
|------|-----------|
| **DAU** | Daily Active Users - unique users who open the app in a 24-hour period |
| **MAU** | Monthly Active Users - unique users who open the app in a 30-day period |
| **iCal** | Internet Calendar format (RFC 5545) used for calendar data exchange |
| **FCM** | Firebase Cloud Messaging - push notification service for Android |
| **APNs** | Apple Push Notification service - push notification service for iOS |
| **Firestore** | Google's NoSQL cloud database with real-time synchronization |
| **WebSocket** | Protocol providing full-duplex communication channels over TCP |
| **Sync Queue** | Local database of pending changes awaiting cloud synchronization |
| **Conflict Resolution** | Algorithm determining canonical state when simultaneous edits occur |
| **OAuth** | Open Authorization standard for secure API authorization |
| **MRR** | Monthly Recurring Revenue from subscriptions |
| **Churn** | Percentage of users who stop using the app or cancel subscription |
| **Retention** | Percentage of users who return to app after N days (D7, D30, D90) |
| **P0/P1/P2** | Priority levels: P0 = critical/must-have, P1 = high, P2 = nice-to-have |

### 12.2 Technical References

- **Firebase Documentation:** https://firebase.google.com/docs/flutter
- **Flutter Documentation:** https://docs.flutter.dev
- **iCalendar RFC 5545:** https://tools.ietf.org/html/rfc5545
- **GDPR Compliance:** https://gdpr.eu
- **iOS Human Interface Guidelines:** https://developer.apple.com/design/human-interface-guidelines
- **Material Design Guidelines:** https://material.io/design

### 12.3 Competitive Analysis

| Competitor | Strengths | Weaknesses | Our Advantage |
|-----------|-----------|------------|---------------|
| **Google Calendar** | Ubiquitous, free, powerful | Not couple-focused, poor cross-platform sharing | Relationship-first UX, real-time sync |
| **Apple Calendar** | Native iOS integration | iOS-only, limited Android support | True cross-platform, offline resilience |
| **Cozi** | Family-oriented, to-do lists | Cluttered UI, slow sync, ads in free tier | Clean UX, fast sync, no ads |
| **TimeTree** | Couple-focused, good UI | Unreliable sync, limited iCal support | Superior sync tech, robust iCal import |

### 12.4 Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | October 2025 | Product Team | Initial comprehensive PRD |
| 2.0 | October 2025 | Product Team | MVP-focused revision: realistic timeline (20 weeks), simplified scope, added NFRs, defined monetization, specified conflict resolution |
| 2.1 | November 2025 | Product Team | Updated with VelloShift rebrand, adjusted timeline to 24 weeks (actual), updated status to reflect Week 17-20 completion |

---

**END OF DOCUMENT**

*This PRD is a living document and will be updated as we learn from user feedback and market validation. All team members should refer to the latest version in the shared repository.*
