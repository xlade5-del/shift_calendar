# VelloShift Privacy Policy

**Last Updated:** November 8, 2025
**Effective Date:** November 8, 2025

## 1. Introduction

Welcome to VelloShift ("we," "our," or "us"). We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application VelloShift (the "App").

By using VelloShift, you agree to the collection and use of information in accordance with this Privacy Policy. If you do not agree with our policies and practices, please do not use the App.

## 2. Information We Collect

### 2.1 Personal Information You Provide

When you create an account and use VelloShift, we collect the following information:

- **Account Information:**
  - Email address
  - Display name
  - Password (encrypted and stored securely via Firebase Authentication)
  - Profile picture/avatar (optional)

- **Calendar and Event Data:**
  - Shift/event titles, dates, times, and notes
  - Event colors and customization preferences
  - iCal feed URLs you provide for calendar import
  - Workplace names and shift templates

- **Partner Connection Information:**
  - Partner linking codes (6-digit codes, valid for 24 hours)
  - Partner's user ID (once connection is established)

- **Communication Preferences:**
  - Notification settings (partner changes, conflicts, free time alerts)
  - Quiet hours preferences
  - Theme preferences (light/dark mode)

### 2.2 Information Collected Automatically

When you use the App, we automatically collect certain information:

- **Device Information:**
  - Device type, model, and operating system version
  - Unique device identifiers
  - Mobile network information
  - Time zone settings

- **Usage Data:**
  - App features used and frequency of use
  - Session duration and frequency
  - Error logs and crash reports (via Firebase Crashlytics)
  - Performance metrics (app load times, sync latency)

- **Location Information:**
  - We do NOT collect precise location data
  - Time zone information is used only for accurate event display

### 2.3 Information from Third-Party Services

If you choose to sign in using third-party authentication:

- **Google Sign-In:** We receive your name, email address, and profile picture from Google
- **Apple Sign-In:** We receive your name and email (or private relay email if you choose to hide your email)

We do NOT access your Google Calendar or Apple Calendar data unless you explicitly provide an iCal feed URL.

## 3. How We Use Your Information

We use the information we collect for the following purposes:

### 3.1 Core App Functionality
- Create and manage your user account
- Synchronize calendar events in real-time with your partner
- Import events from external iCal feeds you provide
- Detect schedule conflicts automatically
- Send push notifications about partner schedule changes
- Enable offline access to your calendar data

### 3.2 Service Improvement
- Monitor app performance and fix bugs
- Analyze usage patterns to improve features
- Conduct A/B testing for feature optimization
- Provide customer support and respond to inquiries

### 3.3 Legal and Security
- Enforce our Terms of Service
- Prevent fraud and abuse
- Comply with legal obligations
- Protect the rights and safety of our users

### 3.4 Communications
- Send important service updates and security alerts
- Respond to your support requests
- Notify you about new features (you can opt out)

**We will NEVER:**
- Sell your personal information to third parties
- Use your calendar data for advertising purposes
- Share your schedule information with anyone except your linked partner
- Train AI models on your data without explicit consent

## 4. How We Share Your Information

### 4.1 With Your Partner

When you link your account with a partner:
- Your partner can view all events you create or import
- Your partner can see your display name and profile picture
- Real-time updates of your schedule changes are shared automatically

**You control this sharing:** You can unlink your partner at any time from the app settings, which immediately stops all data sharing.

### 4.2 With Service Providers

We use trusted third-party service providers to operate our App:

- **Firebase (Google Cloud):** Database hosting, authentication, cloud functions, analytics, crash reporting
- **Apple Push Notification Service (APNs):** iOS push notifications
- **Firebase Cloud Messaging (FCM):** Android push notifications

These providers have access to your information only to perform services on our behalf and are obligated to protect it.

### 4.3 For Legal Reasons

We may disclose your information if required by law or if we believe in good faith that such action is necessary to:
- Comply with legal processes (subpoenas, court orders)
- Enforce our Terms of Service
- Protect the rights, property, or safety of VelloShift, our users, or the public
- Investigate fraud or security issues

### 4.4 Business Transfers

If VelloShift is involved in a merger, acquisition, or sale of assets, your information may be transferred. We will provide notice before your information becomes subject to a different privacy policy.

## 5. Data Storage and Security

### 5.1 Where We Store Your Data

Your data is stored in Firebase Cloud Firestore with multi-region replication:
- **Primary Region:** United States (us-central1)
- **Backup Regions:** Europe (for GDPR compliance)

Your data is also cached locally on your device using SQLite for offline access.

### 5.2 How We Protect Your Data

We implement industry-standard security measures:

- **Encryption in Transit:** All data transmitted between your device and our servers uses TLS 1.3 encryption
- **Encryption at Rest:** All data stored in Firebase Firestore is encrypted using AES-256
- **Authentication Security:** Passwords are hashed using bcrypt; we never store plain-text passwords
- **Access Controls:** Firebase security rules restrict data access to authorized users only
- **Regular Audits:** We conduct security reviews and monitor for suspicious activity

### 5.3 Data Retention

- **Active Accounts:** We retain your data as long as your account is active
- **Deleted Events:** Soft-deleted for 30 days, then permanently removed
- **Account Deletion:** When you delete your account, all data is permanently removed within 30 days
- **Inactive Accounts:** Accounts inactive for 2+ years may be deleted after email notification

## 6. Your Privacy Rights

### 6.1 Access and Portability (GDPR Article 15, 20)

You have the right to:
- Access all personal data we hold about you
- Export your calendar data in iCal format (premium feature)
- Request a complete data download

**How to exercise:** Go to Settings → Account → Export My Data

### 6.2 Correction and Update (GDPR Article 16)

You have the right to:
- Update your display name and profile picture
- Correct inaccurate information
- Modify or delete calendar events

**How to exercise:** Edit your profile and events directly in the app

### 6.3 Deletion (GDPR Article 17 "Right to be Forgotten")

You have the right to:
- Delete your account and all associated data
- Request removal of specific information

**How to exercise:** Go to Settings → Account → Delete My Account

**What happens:**
- All your events are permanently deleted
- Your partner link is immediately severed
- Your profile is removed from our systems within 30 days
- Backup copies are purged within 90 days

### 6.4 Restriction and Objection (GDPR Articles 18, 21)

You have the right to:
- Restrict certain data processing activities
- Object to automated decision-making (we don't use this currently)
- Opt out of marketing communications

**How to exercise:** Contact us at privacy@velloshift.com

### 6.5 California Privacy Rights (CCPA)

If you are a California resident, you have additional rights:

- **Right to Know:** Request disclosure of personal information collected in the past 12 months
- **Right to Delete:** Request deletion of your personal information
- **Right to Opt-Out:** We do NOT sell your personal information, so no opt-out is needed
- **Right to Non-Discrimination:** We will not discriminate against you for exercising your rights

**How to exercise:** Email privacy@velloshift.com with subject "CCPA Request"

We will respond to verified requests within 45 days.

## 7. Children's Privacy

VelloShift is NOT intended for users under the age of 13 (or 16 in the European Economic Area). We do not knowingly collect personal information from children.

If we discover that we have collected information from a child without parental consent, we will delete that information immediately.

If you believe a child has provided us with personal information, please contact us at privacy@velloshift.com.

## 8. International Data Transfers

If you are located outside the United States, your information will be transferred to and processed in the United States where our servers are located.

For users in the European Economic Area (EEA):
- We rely on Firebase's EU-US Data Privacy Framework certification
- Data is replicated to European regions for compliance
- We implement Standard Contractual Clauses (SCCs) where applicable

## 9. Cookies and Tracking Technologies

### 9.1 What We Use

VelloShift uses minimal tracking technologies:

- **Authentication Tokens:** JWT tokens to keep you logged in (stored securely on device)
- **Analytics Identifiers:** Anonymous usage tracking via Firebase Analytics
- **Crash Reporting:** Firebase Crashlytics to identify and fix bugs

### 9.2 Third-Party Analytics

We use Firebase Analytics to understand how users interact with the App. This includes:
- Screen views and navigation patterns
- Feature usage frequency
- Session duration and frequency

**You can opt out:** Go to Settings → Privacy → Analytics Sharing (toggle off)

### 9.3 Advertising

We do NOT use advertising tracking or display third-party ads in VelloShift.

## 10. Changes to This Privacy Policy

We may update this Privacy Policy from time to time to reflect:
- Changes in our practices
- Legal or regulatory requirements
- New features or services

**How we notify you:**
- In-app notification when policy changes
- Email to registered users (for material changes)
- Updated "Last Updated" date at the top of this document

**Your continued use** of VelloShift after changes means you accept the updated policy.

We encourage you to review this Privacy Policy periodically.

## 11. Contact Us

If you have questions, concerns, or requests regarding this Privacy Policy or your personal data:

**Email:** support@velloshift.com
**Response Time:** We aim to respond within 48 hours

For GDPR/CCPA requests, please use subject line "Privacy Rights Request" and include:
- Your registered email address
- Description of your request
- Proof of identity (we may ask for verification)

All privacy inquiries, legal notices, and general support go to the same email for faster response.

## 12. Consent

By creating an account and using VelloShift, you consent to:
- The collection and use of information as described in this Privacy Policy
- The transfer of your data to the United States and other jurisdictions
- Real-time sharing of your calendar with your linked partner

**You can withdraw consent** at any time by:
- Unlinking your partner (stops calendar sharing)
- Disabling notifications (stops push notifications)
- Deleting your account (stops all data collection)

---

**Governing Law:** This Privacy Policy is governed by the laws of the United States and the State of California, without regard to conflict of law principles.

**Last Reviewed:** November 8, 2025

© 2025 VelloShift. All rights reserved.
