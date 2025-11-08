# Email Unification Summary

**Date:** November 8, 2025
**Change:** Simplified from 4 separate emails to 1 unified email

## What Changed

### Before (4 Separate Emails):
- support@velloshift.com - General support
- privacy@velloshift.com - Privacy requests
- legal@velloshift.com - Legal notices
- optout@velloshift.com - Arbitration opt-out

### After (1 Unified Email):
- **support@velloshift.com** - ALL communications

Differentiated by subject line:
- "Privacy Rights Request" - GDPR/CCPA requests
- "Legal Notice" - Legal communications
- "Arbitration Opt-Out" - Arbitration opt-outs
- Any other subject - General support

## Files Updated

### Legal Documents (Markdown)
1. **docs/privacy_policy.md** - Updated contact section (line 275-287)
2. **docs/terms_of_service.md** - Updated 3 sections:
   - Arbitration opt-out (line 405-410)
   - Legal notices (line 459-463)
   - Contact information (line 483-496)

### Legal Documents (Plain Text)
3. **assets/legal/privacy_policy.txt** - Updated contact section
4. **assets/legal/terms_of_service.txt** - Updated 2 sections:
   - Arbitration opt-out (line 131)
   - Contact information (line 143-154)

### UI Components
5. **lib/screens/settings/legal_document_screen.dart** - Updated contact footer to show:
   - "Contact us at support@velloshift.com"
   - Subject line guidance based on document type

### Documentation
6. **docs/legal_documents_summary.md** - Updated:
   - Next steps section to reflect unified approach
   - Contact information section with benefits
7. **docs/email_setup_guide.md** - NEW comprehensive setup guide

## Benefits of Unified Approach

✅ **Operational Simplicity:**
- Only 1 inbox to monitor
- Only 1 email account to set up
- Only 1 set of credentials to manage

✅ **Cost Savings:**
- $6/month instead of $24/month (Google Workspace)
- $1/month instead of $4/month (Zoho Mail)

✅ **Faster Response:**
- No need to check multiple inboxes
- All communications in one place
- Better continuity of conversation

✅ **Still Compliant:**
- Meets all GDPR/CCPA requirements
- Clear contact point for users
- Subject lines enable request categorization

✅ **Easier to Scale:**
- When hiring support staff, everything is centralized
- Gmail filters automatically categorize requests
- Easy handoff with labels and organization

## Subject Line Organization

Users are instructed to use these subject lines:

| Subject Line | Use Case | Response Priority |
|--------------|----------|-------------------|
| "Privacy Rights Request" | GDPR/CCPA data export/deletion | High (30-day legal deadline) |
| "Legal Notice" | DMCA, subpoenas, legal demands | Urgent (immediate attorney consultation) |
| "Arbitration Opt-Out" | Opting out of arbitration clause | High (30-day window) |
| Any other subject | General support, bug reports, questions | Normal (48h / 24h premium) |

## Gmail Filter Setup

Once support@velloshift.com is created, set up these filters:

**Filter 1: Privacy Requests**
- Subject: "Privacy Rights Request"
- Actions: Apply label "Privacy Requests", Star, Mark important

**Filter 2: Legal Notices**
- Subject: "Legal Notice"
- Actions: Apply label "Legal Notices", Star, Mark important

**Filter 3: Arbitration Opt-Outs**
- Subject: "Arbitration Opt-Out"
- Actions: Apply label "Arbitration Opt-Outs", Star, Mark important

**Filter 4: Premium Users (Optional)**
- From: (premium user email addresses)
- Actions: Apply label "Premium", Mark important
- Helps prioritize 24-hour response commitment

## Next Steps

### Before Beta Launch (Week 21-22):
- [ ] Sign up for Google Workspace ($6/month recommended)
- [ ] Create support@velloshift.com email
- [ ] Configure MX records and wait for DNS propagation
- [ ] Set up SPF and DKIM for email authentication
- [ ] Create Gmail filters for request categorization
- [ ] Set up email signature
- [ ] Test email delivery (send test to support@velloshift.com)
- [ ] Set up mobile access (Gmail app)
- [ ] Create privacy request tracking spreadsheet
- [ ] Test the entire flow end-to-end

### Estimated Setup Time:
- Google Workspace signup: 10 minutes
- DNS configuration: 5 minutes (propagation: 24-48 hours)
- Email filters and signature: 15 minutes
- Testing: 10 minutes
- **Total active time:** ~40 minutes

### Cost:
- **Google Workspace:** $6/month = $72/year (RECOMMENDED)
- **Zoho Mail:** $1/month = $12/year (budget option)
- **Email Forwarding:** $0 (temporary testing only)

## Documentation Reference

**Comprehensive Setup Guide:** See `docs/email_setup_guide.md` for:
- Step-by-step Google Workspace setup
- DNS configuration instructions
- Email filter templates
- Privacy request handling procedures
- Response time management
- Email volume estimates
- Legal notice handling
- Cost comparisons
- FAQ

## Verification Checklist

After setup, verify:
- [ ] Can receive emails at support@velloshift.com
- [ ] Can send emails from support@velloshift.com
- [ ] Emails don't go to spam (check with mail-tester.com)
- [ ] SPF/DKIM configured correctly
- [ ] Gmail filters are working
- [ ] Mobile app receives notifications
- [ ] Email signature appears correctly
- [ ] Legal documents show correct email
- [ ] App UI shows correct email

## Compatibility with Legal Requirements

### GDPR (EU Privacy Law)
✅ **Article 13:** Clear contact point for users → support@velloshift.com
✅ **Article 15-22:** User rights requests → "Privacy Rights Request" subject line
✅ **Article 30:** Processing records → Gmail filters enable tracking

### CCPA (California Privacy Law)
✅ **Section 1798.130:** Contact for privacy requests → support@velloshift.com
✅ **Section 1798.105:** Deletion requests → "Privacy Rights Request" subject line

### App Store Requirements
✅ Privacy Policy contact → support@velloshift.com ✅
✅ Support email for users → support@velloshift.com ✅
✅ Clear communication channel → ✅

### Google Play Requirements
✅ Support email for privacy → support@velloshift.com ✅
✅ Developer contact → support@velloshift.com ✅

## Rollback Plan (If Needed)

If you later decide to separate emails:
1. Create additional Google Workspace users (privacy@, legal@, optout@)
2. Set up email forwarding from old emails to new ones
3. Update legal documents (can be done anytime)
4. Redeploy app with updated UI
5. No user-facing changes needed (old emails still work via forwarding)

**Recommendation:** Stick with unified approach. It's simpler and meets all requirements.

## Questions?

**Q: Is one email really enough?**
A: Yes! Even large companies often use one support email with internal routing. Gmail filters make categorization easy.

**Q: What if email volume gets too high?**
A: You'll know when it's time to upgrade (usually >50 emails/day). At that point, consider helpdesk software like Zendesk ($19/month) which can still use support@velloshift.com.

**Q: Will users be confused?**
A: No. Most users expect support@domain.com for everything. Subject line guidance in legal documents is clear.

**Q: Can I add more emails later?**
A: Yes, easily. But you likely won't need to. Most successful apps use 1-2 email addresses max.

## Conclusion

**Status:** All legal documents, UI components, and documentation updated to use support@velloshift.com

**Recommendation:** Proceed with Google Workspace setup ($6/month) using the comprehensive guide in `docs/email_setup_guide.md`

**Timeline:** 40 minutes active setup time + 24-48 hours DNS propagation

**Cost:** $72/year (Google Workspace) - worthwhile investment for professional operations

---

**Updated by:** AI Assistant (Claude Code)
**Date:** November 8, 2025
**Files Modified:** 7
**Documentation Created:** 2
