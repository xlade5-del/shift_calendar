# Security Incident Response: Exposed Firebase API Key

**Date:** December 3, 2025
**Severity:** HIGH
**Status:** IN PROGRESS

## Summary

Google Cloud Platform detected a publicly exposed Firebase API key in the GitHub repository at:
- **File:** `functions/verify-email-simple.js`
- **Commit:** `769dc370ffc22a9e3cc19b4c06ca83818dd627bc`
- **Exposed Key:** `AIzaSyDoGqZCaHeBBlQNOTz90Zh7OQ3V6fw_eOI`
- **Project:** VelloShift (deb-shiftsync-7984c)

## Immediate Actions Required

### ✅ Step 1: Code Fix (COMPLETED)
- [x] Removed hardcoded API key from `verify-email-simple.js`
- [x] Updated script to require environment variable
- [x] Added validation and error messages

### ⏳ Step 2: Regenerate API Key (MANUAL - DO THIS NOW)

**Critical: You must do this in Google Cloud Console**

1. Go to https://console.cloud.google.com/
2. Select project **VelloShift** (deb-shiftsync-7984c)
3. Navigate to **APIs & Services → Credentials**
4. Find the API key: `AIzaSyDoGqZCaHeBBlQNOTz90Zh7OQ3V6fw_eOI`
5. Click the **Edit** button (pencil icon)
6. Click **Regenerate Key** button
7. **COPY THE NEW KEY** - save it securely
8. Click **Save**

### Step 3: Update Firebase Configuration Files

After regenerating the key, update these files with your new API key:

**A. Update `lib/firebase_options.dart`:**
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_NEW_API_KEY_HERE',  // Replace this
  appId: '1:707073038773:android:7c3cef02e1deb4e1e16ea1',
  messagingSenderId: '707073038773',
  projectId: 'deb-shiftsync-7984c',
  storageBucket: 'deb-shiftsync-7984c.firebasestorage.app',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_NEW_API_KEY_HERE',  // Replace this
  appId: '1:707073038773:ios:c4ba66e2e65eb9d5e16ea1',
  messagingSenderId: '707073038773',
  projectId: 'deb-shiftsync-7984c',
  storageBucket: 'deb-shiftsync-7984c.firebasestorage.app',
  // ... rest of config
);
```

**B. Update `android/app/google-services.json`:**
Download a fresh copy from Firebase Console:
1. Go to Firebase Console → Project Settings
2. Under "Your apps" → Android app
3. Click "Download google-services.json"
4. Replace `android/app/google-services.json`

**C. Update `ios/Runner/GoogleService-Info.plist`:**
Download a fresh copy from Firebase Console:
1. Go to Firebase Console → Project Settings
2. Under "Your apps" → iOS app
3. Click "Download GoogleService-Info.plist"
4. Replace `ios/Runner/GoogleService-Info.plist`

### Step 4: Add API Key Restrictions

In Google Cloud Console, configure the new API key with restrictions:

**Application Restrictions:**
- Select: **Android apps**
- Add package name: `com.velloshift.shift_calendar`
- Add SHA-1 certificate fingerprints (get from your keystore)

**API Restrictions:**
- Select: **Restrict key**
- Enable only these APIs:
  - ✅ Identity Toolkit API
  - ✅ Cloud Firestore API
  - ✅ Firebase Cloud Messaging API
  - ✅ Cloud Storage for Firebase API
  - ✅ Firebase Installations API

**For iOS:**
- Create a separate iOS API key
- Add bundle ID: `com.velloshift.shiftCalendar`
- Restrict to iOS apps only

### Step 5: Clean Git History

The exposed key is in your git history. You have two options:

#### Option A: Git Filter-Branch (Recommended for small repos)

```bash
# Backup your repo first
git clone https://github.com/xlade5-del/shift_calendar.git shift_calendar_backup

# Navigate to your repo
cd shift_calendar

# Remove the exposed key from all commits
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch functions/verify-email-simple.js" \
  --prune-empty --tag-name-filter cat -- --all

# Force push to GitHub (WARNING: This rewrites history)
git push origin --force --all
git push origin --force --tags
```

#### Option B: BFG Repo-Cleaner (Better for large repos)

```bash
# Install BFG (requires Java)
# Download from: https://rufflewind.com/bfg-repo-cleaner/

# Backup first
git clone https://github.com/xlade5-del/shift_calendar.git shift_calendar_backup

# Clone a fresh copy
git clone --mirror https://github.com/xlade5-del/shift_calendar.git

# Replace the exposed key in all commits
java -jar bfg.jar --replace-text replacements.txt shift_calendar.git

# Create replacements.txt with:
# AIzaSyDoGqZCaHeBBlQNOTz90Zh7OQ3V6fw_eOI==>***REMOVED***

# Push cleaned history
cd shift_calendar.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push
```

**⚠️ WARNING:** Force pushing rewrites history. Coordinate with any collaborators.

### Step 6: Verify Security

After completing all steps:

1. **Check for remaining instances:**
   ```bash
   git grep -i "AIzaSyDoGqZCaHeBBlQNOTz90Zh7OQ3V6fw_eOI"
   # Should return nothing
   ```

2. **Verify Firebase works with new key:**
   ```bash
   flutter run
   # Test authentication and Firestore access
   ```

3. **Monitor Firebase usage:**
   - Check Firebase Console → Usage for unexpected activity
   - Check Cloud Console → Billing for unusual charges

4. **Review access logs:**
   - Firebase Console → Authentication → Users
   - Look for unauthorized sign-ups or access

### Step 7: Prevent Future Incidents

1. **Enable GitHub Secret Scanning:**
   - Already configured in `.github/secret_scanning.yml`
   - Verify it's active in repo settings

2. **Use environment variables for all secrets:**
   ```bash
   # Example usage of verify-email-simple.js
   FIREBASE_API_KEY=your_new_key node functions/verify-email-simple.js email@test.com password
   ```

3. **Create `.env.example` for documentation:**
   ```bash
   # .env.example (safe to commit)
   FIREBASE_API_KEY=your_firebase_api_key_here
   ```

4. **Regular security audits:**
   - Run `git secrets --scan` periodically
   - Review dependencies for vulnerabilities: `npm audit`
   - Check Firebase security rules monthly

## Post-Incident Review

### Root Cause
- Developer utility script included hardcoded API key for convenience
- File committed to public repository without review
- Secret scanning didn't catch it initially (GitHub alert came late)

### Lessons Learned
1. Never hardcode API keys, even in utility scripts
2. Use environment variables exclusively for credentials
3. Add pre-commit hooks to scan for secrets
4. Review all files before committing to public repos

### Prevention Measures
1. ✅ Updated script to require env vars
2. ⏳ Set up pre-commit hooks (git-secrets or detect-secrets)
3. ⏳ Add to developer onboarding documentation
4. ⏳ Schedule quarterly security reviews

## Contact Information

**Google Cloud Security:** abuse@google.com
**Project Owner:** [Your email]
**Emergency Response:** Check Firebase Console for billing alerts

## Status Tracking

- [ ] API key regenerated
- [ ] Firebase config files updated
- [ ] API restrictions configured
- [ ] Git history cleaned
- [ ] Changes force-pushed to GitHub
- [ ] New key tested and working
- [ ] Usage monitored for 48 hours
- [ ] No unauthorized access detected
- [ ] Incident closed

---

**Next Update:** After completing API key regeneration
**Incident Lead:** Project Owner
