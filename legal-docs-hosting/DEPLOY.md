# 5-Minute Deployment Guide 🚀

**Total Time:** 5-10 minutes
**Total Cost:** $0 (FREE)
**Solution:** GitHub Pages

---

## Step-by-Step Instructions

### 1. Create GitHub Repository (2 min)

1. Open https://github.com/new in your browser
2. Fill in:
   - **Repository name:** `velloshift-legal`
   - **Description:** `Legal documents for VelloShift app`
   - **Visibility:** ✅ **Public** (required for free GitHub Pages)
3. Click **"Create repository"**

---

### 2. Upload Files (2 min)

On your new repository page:

1. Click the link that says **"uploading an existing file"**
2. Open File Explorer and navigate to this folder:
   ```
   c:\Users\me_yo\Yoseph Vibe Coding\shift_calendar\legal-docs-hosting\
   ```
3. **Drag and drop** these 3 files into the GitHub upload area:
   - ✅ `index.html`
   - ✅ `privacy-policy.html`
   - ✅ `terms-of-service.html`
4. In "Commit message" box, type: `Initial commit: Legal documents`
5. Click **"Commit changes"** button

---

### 3. Enable GitHub Pages (1 min)

1. Click the **"Settings"** tab at the top
2. In the left sidebar, scroll down and click **"Pages"**
3. Under **"Source"** section:
   - **Branch:** Select `main` (from dropdown)
   - **Folder:** Select `/ (root)` (from dropdown)
4. Click **"Save"** button
5. **Wait 1-2 minutes** for deployment ⏱️

---

### 4. Get Your URLs ✅

After 1-2 minutes, refresh the Settings → Pages screen.

You'll see: **"Your site is live at https://YOUR-USERNAME.github.io/velloshift-legal/"**

**Your Legal Document URLs:**
```
Landing Page:    https://YOUR-USERNAME.github.io/velloshift-legal/
Privacy Policy:  https://YOUR-USERNAME.github.io/velloshift-legal/privacy-policy.html
Terms of Service: https://YOUR-USERNAME.github.io/velloshift-legal/terms-of-service.html
```

**Replace `YOUR-USERNAME` with your actual GitHub username!**

---

## What to Do with These URLs

### For App Store Submissions:

**Apple App Store:**
- Go to App Store Connect → Your App → App Information
- **Privacy Policy URL:** Paste your privacy-policy.html URL
- **Terms of Use URL:** Paste your terms-of-service.html URL

**Google Play Store:**
- Go to Play Console → Your App → Store Listing
- **Privacy Policy:** Paste your privacy-policy.html URL
- **Terms & Conditions:** Paste your terms-of-service.html URL

---

## Verify Everything Works

Open each URL in your browser and check:

- ✅ Page loads without errors
- ✅ VelloShift branding appears (teal color)
- ✅ Content is readable
- ✅ "Back to Legal Documents" link works
- ✅ HTTPS/lock icon shows in address bar
- ✅ Works on mobile (resize browser or check on phone)

---

## Need to Update Later?

**Easy Method (No Git Required):**

1. Go to your repository: `https://github.com/YOUR-USERNAME/velloshift-legal`
2. Click on the file you want to update (e.g., `privacy-policy.html`)
3. Click the **pencil icon** (top right) to edit
4. Make your changes
5. Scroll down, add commit message
6. Click "Commit changes"
7. Live in ~1 minute!

**Developer Method (If You Update Markdown):**

```bash
cd legal-docs-hosting
node convert.js
git add privacy-policy.html terms-of-service.html
git commit -m "Update legal documents"
git push
```

---

## Troubleshooting

**"404 - Page Not Found"**
- Wait 2 minutes after enabling Pages
- Check files are in `main` branch (not `master`)
- Verify Pages is enabled in Settings

**"Changes Not Showing"**
- Wait 1-2 minutes for deployment
- Clear browser cache (Ctrl+Shift+R)
- Try incognito/private browsing

**"Site Not Secure"**
- Initial SSL takes 10 minutes to provision
- Check back after 10-15 minutes

---

## Done! 🎉

You now have:
- ✅ Professional legal document hosting
- ✅ FREE forever (no monthly costs)
- ✅ HTTPS/SSL enabled
- ✅ URLs ready for App Store/Play Store

**Next:** Use your URLs in app store submissions (Week 23)

---

## Questions?

See full deployment guide: `README.md` in this folder
