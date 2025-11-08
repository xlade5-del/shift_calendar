# VelloShift Email Setup Guide

**Date:** November 8, 2025
**Status:** Simplified Single-Email System

## Overview

VelloShift uses a **single unified email address** for all communications to simplify operations and improve response time:

**Email:** support@velloshift.com

All inquiries (privacy, legal, support, arbitration opt-out) go to this one address, differentiated by subject line.

## Why Single Email?

### Benefits:
✅ **Simpler Setup** - Only one email inbox to manage
✅ **Faster Response** - No need to check multiple inboxes
✅ **Lower Cost** - Only need one email account
✅ **Better Tracking** - All communications in one place
✅ **Easier Handoff** - If you hire support staff, everything is centralized
✅ **Compliance Ready** - Meets GDPR/CCPA requirements for contact point

### Subject Line Organization:
Users are instructed to use specific subject lines for different types of inquiries:
- **"Privacy Rights Request"** - GDPR/CCPA data requests (export, delete, access)
- **"Legal Notice"** - Legal communications, DMCA, subpoenas
- **"Arbitration Opt-Out"** - Users opting out of arbitration clause (30-day window)
- **General Support** - Any other subject line for regular support

## Email Provider Options

### Option 1: Google Workspace (Recommended)
**Cost:** $6/month per user
**Pros:**
- Professional @velloshift.com address
- Reliable delivery and spam filtering
- Integration with Gmail, Calendar, Drive
- Mobile app support
- 30GB storage
- 99.9% uptime guarantee

**Setup Steps:**
1. Go to workspace.google.com
2. Enter domain: velloshift.com
3. Verify domain ownership (add TXT record to DNS)
4. Create user: support@velloshift.com
5. Set up MX records for email routing
6. Configure SPF/DKIM for email authentication

**Estimated Setup Time:** 30 minutes

### Option 2: Zoho Mail (Budget-Friendly)
**Cost:** $1/month per user
**Pros:**
- Very affordable
- Professional features
- Good spam filtering
- Mobile apps

**Cons:**
- Less familiar interface than Gmail
- Fewer integrations

**Setup Steps:**
1. Go to zoho.com/mail
2. Sign up for business email
3. Add domain velloshift.com
4. Verify domain ownership
5. Create support@velloshift.com
6. Configure DNS records

**Estimated Setup Time:** 30 minutes

### Option 3: ProtonMail (Privacy-Focused)
**Cost:** $5/month per user
**Pros:**
- End-to-end encryption
- Privacy-focused company
- Based in Switzerland (strong privacy laws)
- Professional appearance

**Cons:**
- More expensive than alternatives
- Fewer third-party integrations

**Estimated Setup Time:** 30 minutes

### Option 4: Email Forwarding (Temporary Solution)
**Cost:** $0 (if you already have Gmail/Outlook)
**Pros:**
- Quick setup
- No additional cost
- Good for early testing

**Cons:**
- Less professional (replies show your personal email)
- Not suitable for long-term production use
- May have deliverability issues

**Setup Steps:**
1. Register domain velloshift.com (if not already done)
2. Go to domain registrar (Namecheap, GoDaddy, etc.)
3. Add email forwarding rule:
   - From: support@velloshift.com
   - To: your.personal.email@gmail.com
4. Test by sending email to support@velloshift.com

**Estimated Setup Time:** 10 minutes

## Recommended Setup for Beta Phase

**Use Google Workspace** for the following reasons:
1. **Reliability** - Critical for beta user support
2. **Professional** - support@velloshift.com builds trust
3. **Scalability** - Easy to add team members later
4. **Integration** - Works with App Store/Play Store notifications
5. **Search** - Gmail search is excellent for finding old conversations

**Cost:** $6/month (~$72/year) - worthwhile investment for professional operations

## Step-by-Step: Google Workspace Setup

### Prerequisites:
- Domain registered (velloshift.com)
- Access to domain DNS settings

### Steps:

#### 1. Sign Up for Google Workspace
1. Go to workspace.google.com
2. Click "Get Started"
3. Enter business name: "VelloShift"
4. Number of employees: "Just you"
5. Region: United States (or your location)
6. Current email: (your personal email for account setup)

#### 2. Choose Domain
1. Select "Yes, I have one I can use"
2. Enter: velloshift.com
3. Click "Next"

#### 3. Create Admin Account
1. First name: (Your name)
2. Last name: (Your name)
3. Email username: admin (creates admin@velloshift.com)
4. Password: (strong password)
5. Click "Next"

#### 4. Verify Domain Ownership
1. Google provides a TXT record
2. Go to your domain registrar (Namecheap, GoDaddy, etc.)
3. Add TXT record to DNS:
   - Host: @
   - Value: google-site-verification=ABC123... (from Google)
   - TTL: Automatic or 3600
4. Wait 15-30 minutes for DNS propagation
5. Click "Verify" in Google Workspace

#### 5. Set Up MX Records
1. Remove existing MX records (if any)
2. Add Google's MX records (provided by Google):
   ```
   Priority 1:  ASPMX.L.GOOGLE.COM
   Priority 5:  ALT1.ASPMX.L.GOOGLE.COM
   Priority 5:  ALT2.ASPMX.L.GOOGLE.COM
   Priority 10: ALT3.ASPMX.L.GOOGLE.COM
   Priority 10: ALT4.ASPMX.L.GOOGLE.COM
   ```
3. Wait 24-48 hours for full propagation (usually faster)

#### 6. Create support@velloshift.com User
1. Go to Google Workspace Admin console
2. Navigate to Users
3. Click "Add new user"
4. First name: Support
5. Last name: Team
6. Email: support@velloshift.com
7. Password: (strong password)
8. Uncheck "Ask user to change password"
9. Click "Add New User"

#### 7. Set Up Email Authentication (SPF, DKIM)
**SPF Record:**
1. Add TXT record to DNS:
   - Host: @
   - Value: v=spf1 include:_spf.google.com ~all
   - TTL: 3600

**DKIM Record:**
1. In Google Workspace Admin:
   - Apps → Google Workspace → Gmail → Authenticate email
   - Click "Generate new record"
2. Copy the DKIM record provided
3. Add TXT record to DNS:
   - Host: google._domainkey
   - Value: (paste DKIM value from Google)
   - TTL: 3600

#### 8. Test Email Delivery
1. Send test email to support@velloshift.com
2. Log into support@velloshift.com via Gmail
3. Verify email arrived
4. Reply to test email
5. Verify reply delivered successfully

#### 9. Set Up Email Filters (Optional but Recommended)
**Create filters to auto-label incoming emails:**

**Privacy Requests Filter:**
1. In Gmail, click Settings → Filters
2. Create filter:
   - Subject: "Privacy Rights Request"
   - Label: "Privacy Requests" (auto-create)
   - Star the message
   - Mark as important

**Legal Notices Filter:**
1. Subject: "Legal Notice"
2. Label: "Legal Notices"
3. Star the message
4. Mark as important

**Arbitration Opt-Out Filter:**
1. Subject: "Arbitration Opt-Out"
2. Label: "Arbitration Opt-Outs"
3. Star the message
4. Mark as important

This makes it easy to prioritize and track different types of requests.

#### 10. Set Up Mobile Access
1. Download Gmail app on iOS/Android
2. Add account: support@velloshift.com
3. Enable notifications for important emails
4. Test receiving emails on mobile

#### 11. Configure Auto-Reply (Optional - for beta launch)
If you need time to respond during busy periods:
1. Gmail → Settings → General
2. Scroll to "Vacation responder"
3. Enable and set message:
   ```
   Thank you for contacting VelloShift support. We have received your message
   and will respond within 48 hours (24 hours for premium subscribers).

   For urgent issues, please include "URGENT" in your subject line.

   - The VelloShift Team
   ```

## Email Signature Setup

Set up a professional signature for all outgoing emails:

```
Best regards,
VelloShift Support Team

Email: support@velloshift.com
Website: https://velloshift.com
Help Center: https://velloshift.com/help

VelloShift - Helping couples find more time together
```

**How to add in Gmail:**
1. Gmail → Settings → General
2. Scroll to "Signature"
3. Create new signature: "VelloShift Support"
4. Paste signature text above
5. Set as default for new emails and replies

## Response Time Commitments

Based on your legal documents, you've committed to:
- **Regular users:** 48 hours
- **Premium users:** 24 hours

**Tips to meet commitments:**
1. Check email at least twice daily (morning/evening)
2. Use Gmail labels to prioritize urgent requests
3. Set up mobile notifications for starred/important emails
4. Use canned responses for common questions
5. Consider Zendesk or similar if volume grows >50 emails/day

## Email Volume Estimates

**Beta Phase (50 couples = 100 users):**
- Expected: 5-10 emails/day
- Manageable with manual responses

**Post-Launch (1,000 users):**
- Expected: 20-50 emails/day
- Still manageable with Gmail + labels

**Growth Phase (10,000+ users):**
- Expected: 100+ emails/day
- Consider helpdesk software (Zendesk, Intercom, Help Scout)
- May need dedicated support person

## Privacy & GDPR Compliance

### Data Request Handling Process

**When you receive "Privacy Rights Request" email:**

1. **Verify Identity:**
   - Confirm email matches registered account email
   - If different email, ask for verification (account email + last 4 digits of phone if applicable)

2. **Types of Requests:**

   **Access Request (GDPR Article 15):**
   - User wants to know what data you have
   - Response time: 30 days (45 days if complex)
   - Export their data from Firestore
   - Send as JSON file via email

   **Deletion Request (GDPR Article 17):**
   - User wants account deleted
   - Response time: 30 days
   - Delete from Firestore, Firebase Auth, Firebase Storage
   - Send confirmation email when complete

   **Correction Request (GDPR Article 16):**
   - User wants to update incorrect data
   - They can do this in-app (Profile Edit)
   - Guide them to Settings → Profile

   **Portability Request (GDPR Article 20):**
   - User wants data in machine-readable format
   - Export calendar as iCal file
   - Export profile data as JSON
   - Email both files

3. **Response Template:**
   ```
   Dear [User Name],

   We have received your privacy rights request dated [Date].

   [For Access Request:]
   Your account data is attached as a JSON file. This includes your profile
   information, calendar events, and notification preferences.

   [For Deletion Request:]
   Your account has been scheduled for deletion. All data will be permanently
   removed within 30 days. You will receive a confirmation email when complete.

   [For Portability Request:]
   Your calendar data is attached in iCal format, and your profile data is
   attached as JSON. You can import the iCal file to any calendar application.

   If you have any questions, please reply to this email.

   Best regards,
   VelloShift Support Team
   ```

4. **Keep Records:**
   - Create Google Sheet to track privacy requests
   - Columns: Date, User Email, Request Type, Status, Completion Date
   - Required for GDPR compliance audits

## Legal Notice Handling

**When you receive "Legal Notice" email:**

Common types:
1. **DMCA Takedown** - Copyright infringement claim
2. **Subpoena** - Court order for user data
3. **Cease and Desist** - Legal demand to stop something
4. **Terms Violation Report** - User reporting another user

**Immediate Actions:**
1. Do NOT ignore - legal notices have deadlines
2. Forward to your attorney (if you have one)
3. Acknowledge receipt within 24 hours
4. If subpoena/court order: Consult attorney IMMEDIATELY
5. Document everything in a separate "Legal" folder

**Response Template:**
```
Dear [Sender],

We have received your legal notice dated [Date] regarding [Issue].

We take all legal matters seriously and are reviewing your request. We will
respond substantively within [X business days / as required by applicable law].

If you have an attorney representing you, please have them contact us directly
at this email address.

Best regards,
VelloShift Legal Department
support@velloshift.com
```

## Cost Summary

| Email Solution | Monthly | Annual | Best For |
|----------------|---------|--------|----------|
| Google Workspace | $6 | $72 | **Recommended for production** |
| Zoho Mail | $1 | $12 | Budget-conscious early stage |
| ProtonMail | $5 | $60 | Privacy-focused positioning |
| Email Forwarding | $0 | $0 | Temporary testing only |

**Recommendation:** Start with Google Workspace ($72/year) for professional, reliable operations.

## Next Steps Checklist

### Before Beta Launch (Week 21-22):
- [ ] Set up Google Workspace account
- [ ] Create support@velloshift.com email
- [ ] Configure MX records and wait for propagation
- [ ] Set up SPF and DKIM for email authentication
- [ ] Create Gmail filters for different request types
- [ ] Set up email signature
- [ ] Test sending and receiving emails
- [ ] Set up mobile access
- [ ] Create privacy request tracking spreadsheet
- [ ] Write canned responses for common questions

### Before Public Launch (Week 23-24):
- [ ] Verify email delivery is working reliably
- [ ] Test response time for sample requests
- [ ] Ensure legal document links point to support@velloshift.com
- [ ] Update any remaining references to old email addresses
- [ ] Set up auto-reply for vacation/high volume periods
- [ ] Document email handling procedures for future team members

## FAQ

**Q: Do I need separate emails for privacy@, legal@, optout@?**
A: No. Using subject lines with a single inbox is simpler and compliant with GDPR/CCPA.

**Q: What if email volume gets too high?**
A: Upgrade to helpdesk software like Zendesk ($19/month) or Help Scout ($20/month) when you exceed 50 emails/day.

**Q: Can I use my personal Gmail for now?**
A: For testing only. For beta and production, use a professional @velloshift.com address.

**Q: How do I handle spam?**
A: Google Workspace has excellent spam filtering. Review spam folder weekly to catch false positives.

**Q: What if someone requests data deletion?**
A: You have 30 days to comply. Delete from Firestore, Firebase Auth, and Firebase Storage. Send confirmation.

**Q: Do I need to respond to every email?**
A: Yes, to maintain your committed response times (48h regular, 24h premium). Use canned responses for common questions.

## Support Resources

- **Google Workspace Help:** support.google.com/a
- **Email Deliverability Testing:** mail-tester.com
- **SPF Record Checker:** mxtoolbox.com/spf.aspx
- **DKIM Validator:** dmarcian.com/dkim-inspector

---

**Document Version:** 1.0
**Last Updated:** November 8, 2025
**Next Review:** Before Public Launch

For questions about this setup, consult with your development team or email infrastructure provider.
