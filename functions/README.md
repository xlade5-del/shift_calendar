# VelloShift Cloud Functions

## Overview

This directory contains Firebase Cloud Functions for the VelloShift app:

1. **pollIcalFeeds** - Scheduled function to import external calendar feeds
2. **onEventCreated/Updated/Deleted** - Notification triggers for partner events

## Development Utilities

### verify-email-simple.js

A utility script to manually verify test account emails during development.

**Security Notice:** This script requires a Firebase API key via environment variable.

#### Setup

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your Firebase API key:
   ```
   FIREBASE_API_KEY=your_actual_api_key_here
   ```

3. **NEVER commit `.env` to version control!** (already in .gitignore)

#### Usage

```bash
# Set environment variable (Linux/Mac)
export FIREBASE_API_KEY=your_key
node verify-email-simple.js test@example.com password123

# Or use .env file with dotenv
npm install dotenv
node -r dotenv/config verify-email-simple.js test@example.com password123

# Windows PowerShell
$env:FIREBASE_API_KEY="your_key"
node verify-email-simple.js test@example.com password123

# Windows Command Prompt
set FIREBASE_API_KEY=your_key
node verify-email-simple.js test@example.com password123
```

#### Security Best Practices

- ✅ Use environment variables for all API keys
- ✅ Never hardcode credentials in source files
- ✅ Keep `.env` files in `.gitignore`
- ✅ Use API key restrictions in Google Cloud Console
- ✅ Rotate keys immediately if exposed
- ✅ Use separate keys for development and production

## Cloud Functions Deployment

```bash
# Install dependencies
npm install

# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:pollIcalFeeds

# View logs
firebase functions:log
```

## Environment Variables for Production

Production Cloud Functions automatically use Firebase Admin SDK with service account credentials. No API key needed.

For local testing with Firebase Emulator:
```bash
firebase emulators:start
```

## Security

- All API keys must be environment variables
- Use Firebase Admin SDK for server-side operations
- Implement proper error handling
- Never log sensitive information
- Follow principle of least privilege for function permissions

## Support

For issues or questions, contact: support@velloshift.com
