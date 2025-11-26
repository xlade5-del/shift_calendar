# Custom Domain Setup Troubleshooting - www.velloshift.com

## ❌ Error Encountered

```
One or more of Hosting's HTTP GET requests for the ACME challenge failed:
103.42.108.46: Request failed
```

## 🔍 What This Error Means

Firebase is trying to verify you own `www.velloshift.com` by:
1. Asking you to point DNS records to Firebase servers
2. Making an HTTP request to your domain to verify ownership (ACME challenge)
3. **The HTTP request is failing** - Firebase can't reach your domain

**Root Cause:** DNS records haven't propagated yet, or DNS is configured incorrectly.

---

## ✅ Solution: Step-by-Step Fix

### Step 1: Verify Domain Purchase

**First, confirm you own the domain:**

**Question:** Have you purchased `velloshift.com` from a domain registrar?

- ❌ **NO** → You need to buy the domain first
- ✅ **YES** → Continue to Step 2

**Where to buy (if not purchased):**
- **Google Domains** - https://domains.google.com (Recommended, $12/year)
- **Namecheap** - https://www.namecheap.com (~$10/year)
- **Cloudflare Registrar** - https://www.cloudflare.com/products/registrar/ (~$9/year)

---

### Step 2: Check Current DNS Records

**In Firebase Console:**
1. Go to: https://console.firebase.google.com/project/deb-shiftsync-7984c/hosting
2. Click **"Add custom domain"**
3. Enter: `www.velloshift.com`
4. Firebase will show you **required DNS records**

**Expected records Firebase will ask for:**

#### A. For Root Domain (velloshift.com):
```
Type: A
Name: @ (or root)
Value: 151.101.1.195
       151.101.65.195
```

#### B. For WWW Subdomain (www.velloshift.com):
```
Type: A
Name: www
Value: 151.101.1.195
       151.101.65.195
```

**Note:** IP addresses may vary. Use the exact IPs Firebase provides in the console.

---

### Step 3: Add DNS Records to Your Domain Registrar

**Where to add DNS records:**
- **Google Domains:** DNS → Custom records
- **Namecheap:** Advanced DNS → Host Records
- **GoDaddy:** DNS Management → Records
- **Cloudflare:** DNS → Records

**How to add A records:**

#### Option A: Using Google Domains
1. Go to: https://domains.google.com/registrar/velloshift.com/dns
2. Scroll to **"Custom records"**
3. Click **"Create new record"**
4. Add these records:

```
Host name: @
Type: A
TTL: 1 hour
Data: 151.101.1.195
```

Click **"Add"**, then add second A record:
```
Host name: @
Type: A
TTL: 1 hour
Data: 151.101.65.195
```

Then add WWW records:
```
Host name: www
Type: A
TTL: 1 hour
Data: 151.101.1.195
```

```
Host name: www
Type: A
TTL: 1 hour
Data: 151.101.65.195
```

#### Option B: Using Namecheap
1. Login → Domain List → Manage → Advanced DNS
2. Add new record:
   - **Type:** A Record
   - **Host:** @
   - **Value:** 151.101.1.195
   - **TTL:** 1 min

3. Add second A record:
   - **Type:** A Record
   - **Host:** @
   - **Value:** 151.101.65.195
   - **TTL:** 1 min

4. Add WWW A records:
   - **Type:** A Record
   - **Host:** www
   - **Value:** 151.101.1.195
   - **TTL:** 1 min

   - **Type:** A Record
   - **Host:** www
   - **Value:** 151.101.65.195
   - **TTL:** 1 min

---

### Step 4: Wait for DNS Propagation

**DNS changes take time to propagate globally:**
- Minimum: 5-10 minutes
- Average: 1-2 hours
- Maximum: 24-48 hours (rare)

**Why it takes time:**
- DNS servers worldwide need to update
- TTL (Time To Live) settings affect speed
- Old DNS records are cached

---

### Step 5: Check DNS Propagation Status

**Use these tools to verify DNS is propagating:**

#### A. DNS Checker (Global)
https://dnschecker.org/#A/www.velloshift.com

**What to check:**
- Enter: `www.velloshift.com`
- Type: `A`
- Click **"Search"**

**Expected result:**
- Green checkmarks showing `151.101.1.195` or `151.101.65.195`
- If showing red X or different IPs → DNS not propagated yet

#### B. Google DNS Lookup
```bash
nslookup www.velloshift.com 8.8.8.8
```

**Expected output:**
```
Non-authoritative answer:
Name: www.velloshift.com
Address: 151.101.1.195
Address: 151.101.65.195
```

#### C. Direct DNS Query
```bash
dig www.velloshift.com +short
```

**Expected output:**
```
151.101.1.195
151.101.65.195
```

---

### Step 6: Retry Firebase Setup

**Once DNS propagates (check with tools above):**

1. Go back to Firebase Console
2. Click **"Continue"** or **"Verify"**
3. Firebase will retry the ACME challenge
4. If DNS is correct → ✅ **Domain verified!**
5. SSL certificate will be provisioned (takes 10-30 minutes)

**If still failing:**
- Wait another hour and try again
- DNS might not be fully propagated
- Check DNS records are exactly correct (no typos)

---

## 🚨 Alternative Solution: Use Firebase Subdomain First

**If domain setup is urgent, use the Firebase URL for now:**

**Current working URL:** https://deb-shiftsync-7984c.web.app

**Benefits:**
- ✅ Already working (SSL, CDN, etc.)
- ✅ No DNS setup needed
- ✅ Can add custom domain later

**When to use:**
- You need to launch immediately
- Custom domain purchase/setup can wait
- Testing landing page performance first

**Later:** Add custom domain once purchased and DNS propagated.

---

## 🔧 Common Mistakes & Fixes

### Mistake 1: Wrong DNS Record Type
❌ **CNAME record for root domain (@)**
```
Type: CNAME
Name: @
Value: deb-shiftsync-7984c.web.app
```

✅ **Correct: A records for root domain**
```
Type: A
Name: @
Value: 151.101.1.195 (and 151.101.65.195)
```

**Why:** Root domains cannot use CNAME records (DNS limitation). Use A records instead.

---

### Mistake 2: Using Old IP Addresses
❌ **Using generic Firebase IPs from Google search**

✅ **Use EXACT IPs from Firebase Console**
- Firebase shows project-specific IPs
- IPs can vary by region/project
- Always get IPs from your Firebase Console

---

### Mistake 3: Not Waiting for DNS Propagation
❌ **Retrying immediately after adding DNS records**

✅ **Wait at least 1 hour before retrying**
- DNS propagation isn't instant
- Retrying too soon = same error
- Use dnschecker.org to confirm propagation

---

### Mistake 4: Missing WWW Records
❌ **Only adding root domain (@) records**

✅ **Add both root AND www records**
```
@ → 151.101.1.195, 151.101.65.195
www → 151.101.1.195, 151.101.65.195
```

**Why:** Users might visit `velloshift.com` OR `www.velloshift.com`. Both should work.

---

## 🎯 Recommended Approach (If Domain Not Yet Purchased)

### Option A: Buy Domain Through Google Domains (Easiest)

**Why Google Domains:**
- ✅ Integrates seamlessly with Firebase
- ✅ DNS changes propagate faster (usually 10-30 minutes)
- ✅ Simple UI for DNS management
- ✅ Free privacy protection (WHOIS)
- 💰 $12/year

**Steps:**
1. Buy domain: https://domains.google.com
2. Search: `velloshift.com`
3. Purchase ($12/year)
4. Wait 5 minutes for domain activation
5. Firebase will auto-detect Google Domains ownership
6. DNS setup is **automatic** in most cases

---

### Option B: Use Cloudflare (Advanced, but Free SSL)

**Why Cloudflare:**
- ✅ Faster DNS propagation (minutes instead of hours)
- ✅ Free SSL certificate (additional layer)
- ✅ DDoS protection
- ✅ Analytics included
- 💰 Free tier available

**Steps:**
1. Buy domain anywhere (Namecheap, GoDaddy, etc.)
2. Add domain to Cloudflare (free): https://www.cloudflare.com
3. Point domain nameservers to Cloudflare
4. Add A records in Cloudflare dashboard
5. Set SSL mode to "Full"
6. DNS propagates in 2-15 minutes

---

## 📊 Verification Checklist

Before retrying Firebase custom domain setup:

- [ ] **Domain purchased** from registrar
- [ ] **DNS A records added** (both @ and www)
- [ ] **IP addresses match** Firebase Console exactly
- [ ] **DNS propagation confirmed** (dnschecker.org shows green)
- [ ] **Waited at least 1 hour** since adding DNS records
- [ ] **No CNAME on root domain** (only A records)
- [ ] **TTL set to 1 hour or less** (faster propagation)

---

## 🆘 Still Not Working? Try This

### 1. Delete and Re-add DNS Records
Sometimes registrars have stale cache:
- Delete existing A records
- Wait 5 minutes
- Add fresh A records with exact IPs from Firebase
- Wait 1 hour

### 2. Use Different DNS Records (CNAME for WWW only)
If A records keep failing, try CNAME for WWW:

```
Type: CNAME
Name: www
Value: deb-shiftsync-7984c.web.app
TTL: 1 hour
```

**Note:** This only works for `www.velloshift.com`, not root `velloshift.com`.

### 3. Contact Firebase Support
If issue persists after 48 hours:
- Firebase Console → Help → Contact Support
- Describe error message
- Provide domain name: `www.velloshift.com`
- Include DNS records screenshot

---

## ⚡ Quick Start While Waiting

**Don't let DNS block your progress!**

**Use this URL for now:**
https://deb-shiftsync-7984c.web.app

**You can:**
- ✅ Share with beta users
- ✅ Test analytics tracking
- ✅ Run A/B tests
- ✅ Collect feedback
- ✅ Launch marketing campaigns

**Later:** Once DNS propagates, add custom domain and redirect old URL.

---

## 🎓 Learning: How ACME Challenges Work

**ACME = Automatic Certificate Management Environment**

**Process:**
1. You tell Firebase: "I own www.velloshift.com"
2. Firebase asks Let's Encrypt for SSL certificate
3. Let's Encrypt challenges: "Prove you own it"
4. **HTTP-01 Challenge:** Let's Encrypt visits `http://www.velloshift.com/.well-known/acme-challenge/TOKEN`
5. Firebase serves the token from your domain
6. Let's Encrypt verifies token → Issues SSL certificate
7. **Your error = Step 4 failed** (domain not reachable)

**Why it fails:**
- DNS doesn't point to Firebase yet
- DNS propagation incomplete
- Domain doesn't exist

**Fix:** Correct DNS + wait for propagation

---

## 📞 Need Help?

**Resources:**
- **Firebase Hosting Docs:** https://firebase.google.com/docs/hosting/custom-domain
- **DNS Propagation Checker:** https://dnschecker.org
- **Google Domains DNS Help:** https://support.google.com/domains/answer/3290309
- **Namecheap DNS Guide:** https://www.namecheap.com/support/knowledgebase/article.aspx/319/2237/how-can-i-set-up-an-a-address-record-for-my-domain/

**Questions?**
- Check Firebase Console for exact DNS records needed
- Use dnschecker.org to verify propagation status
- Wait at least 1 hour before retrying

---

## ✅ Expected Timeline

| Step | Time Required |
|------|---------------|
| Purchase domain | 5 minutes |
| Add DNS records | 5 minutes |
| DNS propagation | **1-24 hours** |
| Firebase verification | 30 seconds |
| SSL certificate provisioning | 10-30 minutes |
| **Total:** | **~2-25 hours** |

**Patience is key!** DNS propagation is the bottleneck, not Firebase.

---

**🚀 Once DNS propagates, your custom domain will work perfectly!**

*Last updated: November 23, 2025*
