# VelloShift App Store Preparation Guide

**Date:** November 9, 2025
**Status:** Ready to Start
**Estimated Time:** 30-40 hours
**Priority:** P0 Critical for Launch

---

## Overview

This guide covers everything needed to submit VelloShift to both Apple App Store and Google Play Store.

**Current Status:**
- ✅ App fully functional
- ✅ Legal documents ready
- ✅ Support email set up (support@velloshift.com via Zoho)
- ✅ Basic app icons exist (Flutter defaults)
- ⏳ Store-ready assets needed
- ⏳ Store listings needed
- ⏳ Developer accounts needed

---

## Part 1: Developer Accounts

### Apple Developer Account
**Cost:** $99/year
**URL:** https://developer.apple.com/programs/enroll/

**Steps:**
1. Create Apple ID (if don't have one)
2. Go to https://developer.apple.com/account
3. Click "Enroll" in Apple Developer Program
4. Choose "Individual" (or "Organization" if you have a company)
5. Provide:
   - Legal name
   - Phone number
   - Address
   - Payment method (credit card)
6. Review and accept terms
7. Pay $99
8. Wait 24-48 hours for approval

**What You Get:**
- Ability to publish iOS apps
- TestFlight beta testing
- APNs push notification certificates
- App analytics

---

### Google Play Developer Account
**Cost:** $25 one-time
**URL:** https://play.google.com/console/signup

**Steps:**
1. Sign in with Google account
2. Go to https://play.google.com/console/signup
3. Accept Developer Distribution Agreement
4. Pay $25 registration fee
5. Complete account details:
   - Developer name: "VelloShift" or your name
   - Email address
   - Website (optional for now)
6. Account ready immediately after payment

**What You Get:**
- Ability to publish Android apps
- Internal/closed/open testing tracks
- Google Play Console analytics
- User reviews and ratings

**Total Cost:** $124 ($99 + $25)

---

## Part 2: App Store Assets

### Required Assets Checklist

#### App Icon
- ✅ **iOS:** 1024x1024px PNG (no transparency)
  - Location: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
  - Status: Default Flutter icon exists, needs branding
- ✅ **Android:** 512x512px PNG
  - Location: `android/app/src/main/res/mipmap-*/ic_launcher.png`
  - Status: Default Flutter icon exists, needs branding

**TODO:** Create branded VelloShift icon
- Teal (#2B7A78) background
- White calendar/couple icon
- Simple, recognizable design
- Tools: Figma (free), Canva Pro, Adobe Illustrator

---

#### iOS Screenshots
**Required Sizes:**
- 6.7" (iPhone 14 Pro Max, 15 Pro Max): 1290x2796px
- 6.5" (iPhone 11 Pro Max, XS Max): 1242x2688px
- 5.5" (iPhone 8 Plus): 1242x2208px (optional, still supported)

**Number Required:** 3-10 screenshots per size

**Best Practices:**
- Show key features (calendar view, partner linking, notifications)
- Add text overlays explaining features
- Use device frames for professional look
- First screenshot is most important (conversion driver)

**Screenshot Ideas:**
1. **Home Screen** - "See your schedules together at a glance"
2. **Partner Linking** - "Connect with your partner in seconds"
3. **Event Creation** - "Add shifts with just a few taps"
4. **Conflict Detection** - "Automatic overlap detection"
5. **Free Time Finder** - "Find time together effortlessly"

**Tools:**
- Flutter screenshot package: `flutter_driver` or manual
- Design: Figma, Canva, Photoshop
- Device frames: https://www.screely.com/ or https://mockuphone.com/

---

#### Android Screenshots
**Required Sizes:**
- Phone: 1080x1920px (16:9) minimum
- 7" Tablet: 1920x1200px (optional)
- 10" Tablet: 2560x1600px (optional)

**Number Required:** 2-8 screenshots

**Same content as iOS**, just different dimensions.

---

#### Feature Graphic (Android Only)
**Size:** 1024x500px PNG or JPEG
**Purpose:** Shown at top of Play Store listing

**Design Suggestions:**
- VelloShift logo + tagline: "Find more time together"
- Show couple + calendar visual
- Teal brand colors (#2B7A78)
- Clean, professional design

**Tools:** Canva (has Play Store templates), Figma, Photoshop

---

### Optional but Recommended Assets

#### Promo Video (App Preview)
**iOS:** Up to 30 seconds, MP4 or MOV
**Android:** Up to 30 seconds, MP4

**Content Ideas:**
- Quick app tour (10 seconds)
- Show partner linking (5 seconds)
- Show conflict detection (5 seconds)
- Call to action (5 seconds)

**Tools:**
- Screen recording: iOS Screen Recording, Android ADB
- Editing: iMovie (Mac), DaVinci Resolve (free), CapCut

**Priority:** P2 (nice to have, not required)

---

## Part 3: App Store Listings

### Apple App Store Listing

#### App Information
**App Name:** VelloShift (max 30 characters)
**Subtitle:** Shift calendar for couples (max 30 characters)

**Category:**
- Primary: Productivity
- Secondary: Lifestyle

**Privacy Policy URL:**
`https://YOUR-GITHUB-USERNAME.github.io/velloshift-legal/privacy-policy.html`

**Terms of Use URL:**
`https://YOUR-GITHUB-USERNAME.github.io/velloshift-legal/terms-of-service.html`

**Support URL:**
Option 1: `https://YOUR-GITHUB-USERNAME.github.io/velloshift-legal/` (use legal docs landing page for now)
Option 2: Create simple support page with FAQs

**Marketing URL (Optional):**
Leave blank for MVP, add landing page later

---

#### App Description
**Format:** Plain text, max 4,000 characters

**Template:**

```
VelloShift: The Shift Calendar Built for Couples

Tired of "When are you off?" texts? VelloShift helps couples with rotating schedules find more time together.

MADE FOR SHIFT WORKERS
Whether you're in healthcare, emergency services, retail, or any job with irregular hours, VelloShift keeps you and your partner in sync.

KEY FEATURES
✓ Real-Time Sync – Your partner sees your schedule instantly
✓ Conflict Detection – Automatic alerts when you're both working
✓ Free Time Finder – Quickly spot days you're both off
✓ Import iCal Feeds – Sync with work calendars automatically
✓ Works Offline – Add shifts without internet, syncs later
✓ Push Notifications – Get notified of partner's schedule changes
✓ Color-Coded Events – Easy visual distinction

NO MORE SCHEDULING CHAOS
• Share shifts with one partner (privacy-first design)
• See each other's schedules at a glance
• Plan date nights when you're both free
• Reduce "Are you working?" texts by 100%

DESIGNED FOR REAL RELATIONSHIPS
Built by someone who understands the challenges of coordinating two busy schedules. Simple, reliable, and focused on what matters: spending time together.

PREMIUM FEATURES (Coming Soon)
• Unlimited iCal feeds
• Advanced availability finder
• PDF/iCal export
• Priority support

FREE TIER INCLUDES
• Unlimited manual events
• 1 iCal feed per person
• Real-time sync
• Conflict detection
• Basic notifications

PRIVACY & SECURITY
• Your data is yours – never sold or shared
• End-to-end encryption for all calendar data
• GDPR and CCPA compliant
• Delete your account anytime

SUPPORT
Have questions? Email us: support@velloshift.com
We typically respond within 24 hours.

---

VelloShift requires iOS 13.0 or later.
Some features require an internet connection.
Push notifications require iOS 14.0+.

© 2025 VelloShift. All rights reserved.
```

**Character Count:** ~1,700 characters (plenty of room to expand)

---

#### Keywords (iOS Only)
**Max:** 100 characters, comma-separated

**Suggested Keywords:**
```
shift calendar,couple calendar,schedule sync,shift work,rotating schedule,calendar share,work schedule,partner calendar,conflict detection,free time finder,healthcare schedule,nursing schedule,relationship calendar,calendar couple,sync schedules
```

**Tips:**
- No spaces after commas (saves characters)
- Don't repeat app name (waste of space)
- Focus on search intent ("shift calendar" not "calendar shift")
- Use App Store Connect's keyword suggestion tool

---

#### What's New (Version 1.0.0)
```
🎉 Introducing VelloShift v1.0!

The shift calendar built for couples is here. Never miss time together again.

✨ LAUNCH FEATURES
• Real-time calendar sync
• Partner linking in seconds
• Automatic conflict detection
• iCal feed imports
• Offline mode
• Push notifications
• Free time finder

📱 GETTING STARTED
1. Create your account
2. Share your partner code
3. Add your shifts
4. Find more time together

💬 FEEDBACK
We'd love to hear from you! Email support@velloshift.com

Thank you for being an early user! 🙏
```

---

### Google Play Store Listing

#### App Details
**App Name:** VelloShift
**Short Description:** (max 80 characters)
```
Shift calendar for couples. Find more time together.
```

**Full Description:** (max 4,000 characters)
Use the same description as iOS (copy-paste the template above)

**Category:** Productivity
**Tags:** Calendar, Productivity, Lifestyle, Scheduling

**Content Rating:**
- Everyone
- No ads
- No in-app purchases (for MVP)
- Contains user-generated content

**Privacy Policy URL:**
`https://YOUR-GITHUB-USERNAME.github.io/velloshift-legal/privacy-policy.html`

**Developer Contact:**
- Email: support@velloshift.com
- Website: (optional) `https://YOUR-GITHUB-USERNAME.github.io/velloshift-legal/`

---

## Part 4: App Privacy Details (Apple)

**Apple requires detailed privacy "nutrition labels" since iOS 14.**

### Data Types Collected

#### Contact Info
- ✅ Email Address
  - Purpose: Account creation, support
  - Linked to user: Yes
  - Used for tracking: No

- ✅ Name
  - Purpose: Profile display
  - Linked to user: Yes
  - Used for tracking: No

#### User Content
- ✅ Calendar Events
  - Purpose: Core app functionality
  - Linked to user: Yes
  - Used for tracking: No

- ✅ Photos/Videos (Optional)
  - Purpose: Profile avatar
  - Linked to user: Yes
  - Used for tracking: No

#### Identifiers
- ✅ User ID
  - Purpose: Account management, sync
  - Linked to user: Yes
  - Used for tracking: No

- ✅ Device ID
  - Purpose: Push notifications
  - Linked to user: Yes
  - Used for tracking: No

#### Diagnostics
- ✅ Crash Data
  - Purpose: Bug fixing
  - Linked to user: No
  - Used for tracking: No

- ✅ Performance Data
  - Purpose: App optimization
  - Linked to user: No
  - Used for tracking: No

### Data Not Collected
- ❌ Precise Location
- ❌ Browsing History
- ❌ Search History
- ❌ Purchase History
- ❌ Financial Info
- ❌ Health Data
- ❌ Contacts List

---

## Part 5: Build & Submit

### iOS Build & Upload

**Prerequisites:**
- ✅ Apple Developer Account ($99, approved)
- ✅ macOS computer or cloud Mac (MacStadium, MacInCloud)
- ✅ Xcode installed (latest version)
- ✅ App signing certificates configured

**Steps:**

1. **Update Version & Build Number**
   ```bash
   # Edit pubspec.yaml
   version: 1.0.0+1  # version+build number
   ```

2. **Build iOS Release**
   ```bash
   cd shift_calendar
   flutter build ios --release
   ```

3. **Open in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```

4. **Configure Signing**
   - Select Runner target
   - Go to "Signing & Capabilities"
   - Select your Apple Developer Team
   - Xcode will auto-generate provisioning profile

5. **Archive Build**
   - Product → Archive
   - Wait for build to complete (5-10 minutes)
   - Organizer window will open

6. **Upload to App Store Connect**
   - Click "Distribute App"
   - Select "App Store Connect"
   - Click "Upload"
   - Wait for processing (10-30 minutes)

7. **Create App Store Listing**
   - Go to https://appstoreconnect.apple.com
   - Click "My Apps" → "+" → "New App"
   - Fill in all required fields
   - Upload screenshots
   - Add app description
   - Submit for review

**Review Time:** 24-48 hours typically

---

### Android Build & Upload

**Prerequisites:**
- ✅ Google Play Developer Account ($25, active)
- ✅ Signing key generated
- ✅ Flutter SDK installed

**Steps:**

1. **Generate Upload Key** (First Time Only)
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   - Enter password (save it!)
   - Enter your name, organization, location

2. **Configure Signing**
   Create `android/key.properties`:
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

3. **Update Version**
   ```yaml
   # pubspec.yaml
   version: 1.0.0+1
   ```

4. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`

5. **Create App in Play Console**
   - Go to https://play.google.com/console
   - Click "Create app"
   - Fill in app details
   - Set up store listing

6. **Upload App Bundle**
   - Go to "Release" → "Production"
   - Click "Create new release"
   - Upload `app-release.aab`
   - Add release notes
   - Submit for review

**Review Time:** Few hours to 7 days (typically 1-3 days)

---

## Part 6: TestFlight & Beta Testing

### iOS TestFlight

**Purpose:** Invite beta testers before public launch

**Steps:**
1. After uploading build to App Store Connect
2. Go to "TestFlight" tab
3. Add "Internal Group" (up to 100 testers, no review needed)
4. Add "External Group" (unlimited testers, requires Apple review)
5. Share invite link with testers
6. Testers download TestFlight app and join

**Benefits:**
- Test with real users before launch
- Collect crash reports automatically
- Get feedback via TestFlight app

---

### Google Play Internal Testing

**Purpose:** Test with small group before open beta

**Steps:**
1. In Play Console, go to "Release" → "Testing" → "Internal testing"
2. Create release
3. Upload app bundle
4. Add testers by email
5. Share opt-in link

**Then move to:**
- Closed testing (larger group, up to 100,000)
- Open testing (public beta)

---

## Part 7: Post-Launch Checklist

### Week 1 After Launch
- [ ] Monitor crash reports (Firebase Crashlytics, App Store Connect, Play Console)
- [ ] Respond to user reviews within 24 hours
- [ ] Check analytics (downloads, retention, crashes)
- [ ] Fix critical bugs (P0) immediately
- [ ] Collect user feedback

### Week 2-4
- [ ] Analyze user behavior (which features used most?)
- [ ] Plan v1.1.0 updates based on feedback
- [ ] Optimize app store listing (A/B test screenshots)
- [ ] Respond to all support emails

---

## Part 8: Estimated Timeline

### Assuming Starting Now (November 9, 2025)

| Task | Time | Completion Date |
|------|------|----------------|
| Register developer accounts | 1 day | Nov 10 |
| Create app icon & assets | 8 hours | Nov 11-12 |
| Take & edit screenshots | 6 hours | Nov 12-13 |
| Write store listings | 3 hours | Nov 13 |
| Configure privacy details | 2 hours | Nov 13 |
| iOS build & upload | 3 hours | Nov 14 |
| Android build & upload | 2 hours | Nov 14 |
| TestFlight beta (optional) | 1 week | Nov 14-21 |
| **App Store review** | **1-2 days** | Nov 15-16 |
| **Play Store review** | **1-3 days** | Nov 15-17 |
| **PUBLIC LAUNCH** | | **Nov 17, 2025** 🎉 |

**Total Active Work:** ~30 hours
**Total Calendar Time:** 8-10 days (including review times)

---

## Part 9: Tools & Resources

### Design Tools
- **Figma** (free): https://figma.com - Best for app icon, screenshots
- **Canva** (free tier): https://canva.com - Templates for Play Store assets
- **Photoshop** (paid): Industry standard, overkill for simple assets

### Screenshot Tools
- **Fastlane Snapshot** (free): Automate screenshot generation
- **MockUPhone** (free): https://mockuphone.com - Add device frames
- **Screely** (free): https://screely.com - Beautiful browser mockups

### Icon Generators
- **App Icon Generator** (free): https://appicon.co
- **MakeAppIcon** (free): https://makeappicon.com
- Generates all required sizes from one 1024x1024 image

### Video Recording
- **iOS:** Built-in screen recording (Control Center)
- **Android:** ADB screen recording or apps like AZ Screen Recorder
- **Editing:** DaVinci Resolve (free), iMovie (Mac), CapCut (mobile)

### Useful Links
- **Apple Human Interface Guidelines:** https://developer.apple.com/design/human-interface-guidelines/
- **Google Material Design:** https://material.io/design
- **App Store Connect:** https://appstoreconnect.apple.com
- **Google Play Console:** https://play.google.com/console

---

## Part 10: Quick Wins (Do These First)

### Priority 1 (Do Today/Tomorrow)
1. ✅ Register Apple Developer Account ($99)
2. ✅ Register Google Play Developer Account ($25)
3. ✅ Create GitHub repository for legal docs
4. ✅ Upload legal docs HTML files
5. ✅ Get public URLs for Privacy Policy & Terms

### Priority 2 (This Week)
6. Create branded app icon (1024x1024)
7. Generate all app icon sizes using online tool
8. Write App Store description (use template above)
9. Write Play Store description (same content)
10. Research keywords for iOS

### Priority 3 (Next Week)
11. Take screenshots on emulator/device
12. Add text overlays to screenshots
13. Create Play Store feature graphic
14. Test iOS build locally
15. Test Android build locally
16. Upload to stores!

---

## Summary

**What You Need:**
- 💵 $124 ($99 Apple + $25 Google)
- ⏰ 30 hours of work
- 🗓️ 8-10 days calendar time
- 💻 Mac for iOS build (or MacInCloud $30/month)

**What You'll Get:**
- 📱 VelloShift on App Store
- 🤖 VelloShift on Play Store
- 👥 Beta testing capability
- 📊 App analytics
- ⭐ User reviews & ratings

**Recommended Next Steps:**
1. Register for both developer accounts TODAY
2. Start working on app icon this week
3. Plan for 3-4 hours/day for next week
4. Target launch: November 17-20, 2025

---

**Need Help?**
- Apple Developer Support: https://developer.apple.com/support/
- Google Play Support: https://support.google.com/googleplay/android-developer/

**Let's ship this! 🚀**
