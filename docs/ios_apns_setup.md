# iOS APNs Setup Guide

This guide covers the additional steps required to fully enable Apple Push Notifications (APNs) for the Shift Calendar app on iOS. These steps require macOS with Xcode installed.

## Current Status

✅ **Completed:**
- iOS Info.plist updated with notification permissions
- Background modes configured (fetch, remote-notification)
- Firebase Messaging package configured
- NotificationService with iOS support

⏳ **Requires macOS/Xcode:**
- APNs certificate/key generation in Apple Developer Console
- Push Notification capability enabled in Xcode
- APNs authentication key upload to Firebase Console
- Testing on physical iOS device

## Steps to Complete APNs Setup

### 1. Apple Developer Console Setup

1. Log in to [Apple Developer Console](https://developer.apple.com/account)
2. Go to **Certificates, Identifiers & Profiles**
3. Create an **APNs Authentication Key**:
   - Click on **Keys** → **+** button
   - Name it "Shift Calendar APNs Key"
   - Check **Apple Push Notifications service (APNs)**
   - Click **Continue** → **Register**
   - **Download the .p8 file** (you can only download it once!)
   - Note the **Key ID** and **Team ID**

### 2. Firebase Console Configuration

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select the project: **deb-shiftsync-7984c**
3. Go to **Project Settings** → **Cloud Messaging** tab
4. Under **Apple app configuration**:
   - Click **Upload** in the APNs Authentication Key section
   - Upload the .p8 file you downloaded
   - Enter your **Key ID** and **Team ID**
   - Click **Upload**

### 3. Xcode Project Configuration

1. Open the iOS project in Xcode:
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. Select the **Runner** target in the project navigator

3. Go to **Signing & Capabilities** tab

4. Click **+ Capability** and add:
   - **Push Notifications**
   - **Background Modes** (should already be configured via Info.plist)
     - Enable: **Remote notifications**
     - Enable: **Background fetch**

5. Ensure you're signed in with your Apple Developer account:
   - Go to Xcode → **Preferences** → **Accounts**
   - Add your Apple ID if not already added

6. Select your development team under **Signing & Capabilities**

### 4. App ID Configuration (Apple Developer)

1. In [Apple Developer Console](https://developer.apple.com/account), go to **Identifiers**
2. Find your app's identifier (e.g., `com.yourcompany.shiftcalendar`)
3. Edit the identifier and ensure **Push Notifications** is checked
4. Click **Save**

### 5. Testing APNs

#### On Physical iOS Device (Required)

**Note:** APNs does NOT work on iOS Simulator. You must use a physical device.

1. Connect your iPhone/iPad to your Mac
2. In Xcode, select your device from the device dropdown
3. Run the app: `flutter run` or via Xcode
4. Grant notification permissions when prompted
5. Check the debug console for the FCM token

#### Send Test Notification

**Option 1: Firebase Console**
1. Go to Firebase Console → **Cloud Messaging** → **Send your first message**
2. Enter notification title and text
3. Click **Send test message**
4. Paste your device's FCM token
5. Click **Test**

**Option 2: Using curl (APNs HTTP/2)**
```bash
curl -v \
  -H "apns-topic: com.yourcompany.shiftcalendar" \
  -H "apns-push-type: alert" \
  -H "apns-priority: 10" \
  --http2 \
  --cert YourAPNsCertificate.pem \
  -d '{"aps":{"alert":"Test Notification","sound":"default"}}' \
  https://api.sandbox.push.apple.com/3/device/DEVICE_TOKEN_HERE
```

### 6. Verify Background Notifications

1. Send yourself an event change notification while the app is in background
2. Verify the notification appears on the lock screen
3. Tap the notification and verify it opens the app
4. Check that the NotificationService handles the notification correctly

## Troubleshooting

### No FCM Token Generated
- Ensure Push Notifications capability is enabled in Xcode
- Check that you're running on a **physical device** (not simulator)
- Verify APNs key is uploaded to Firebase Console
- Check for errors in Xcode console

### Notifications Not Received
- Verify the device is **not** in Do Not Disturb mode
- Ensure notification permissions are granted: Settings → Shift Calendar → Notifications
- Check Firebase Console logs for delivery status
- Verify APNs certificate is valid and not expired

### Background Notifications Not Working
- Ensure **Background Modes** capability is enabled with **Remote notifications** checked
- Verify `UIBackgroundModes` is in Info.plist with `remote-notification`
- Check that notification payload includes `content-available: 1`

### Certificate Issues
- Ensure you're using the correct provisioning profile
- Verify the App ID in Apple Developer matches the bundle identifier
- Check that APNs is enabled for the App ID

## Additional Resources

- [Firebase Cloud Messaging for iOS](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Apple Push Notification Service](https://developer.apple.com/documentation/usernotifications)
- [FlutterFire Messaging Documentation](https://firebase.flutter.dev/docs/messaging/overview)

## Implementation Checklist

- [ ] Generate APNs Authentication Key (.p8 file)
- [ ] Upload APNs key to Firebase Console
- [ ] Enable Push Notifications capability in Xcode
- [ ] Configure Background Modes in Xcode
- [ ] Update App ID in Apple Developer Console
- [ ] Test notifications on physical iOS device
- [ ] Verify foreground notifications work
- [ ] Verify background notifications work
- [ ] Test notification tap handling
- [ ] Test with app in terminated state

## Notes

- APNs requires a **paid Apple Developer account** ($99/year)
- Testing **must** be done on a **physical iOS device** (simulators don't support APNs)
- The notification service code is already implemented and will work once APNs is configured
- Background notification handling is implemented in `notification_service.dart`
