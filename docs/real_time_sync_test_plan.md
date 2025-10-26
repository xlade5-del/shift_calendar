# Real-Time Sync Testing Plan

**Test Date:** October 27, 2025
**Target:** Week 12 Checkpoint - Real-time sync >95% reliable
**Latency Target:** <3 seconds

---

## Test Setup

### Prerequisites
- [ ] Two Android emulators running
  - Device A: Medium_Phone_API_36.1
  - Device B: Pixel_9
- [ ] Two test accounts logged in
  - Account A: (user1 email)
  - Account B: (user2 email)
- [ ] Both accounts linked as partners
- [ ] Both apps on CalendarScreen

---

## Test Cases

### Test 1: Basic Event Creation Sync (A → B)
**Objective:** Verify events created on Device A appear on Device B

**Steps:**
1. On Device A: Tap + button to open AddEventScreen
2. Create event:
   - Title: "Test Event A"
   - Start: Today, 9:00 AM
   - End: Today, 5:00 PM
   - Color: Blue
   - Notes: "Testing sync from A to B"
3. Tap SAVE
4. Start timer immediately after save
5. On Device B: Watch calendar screen
6. Note when event appears on Device B
7. Verify event details match (title, time, color)

**Expected Result:**
- ✅ Event appears on Device B within 3 seconds
- ✅ All details match exactly
- ✅ Event positioned correctly on calendar grid

**Actual Result:**
- Time to sync: _____ seconds
- Details match: ☐ Yes ☐ No
- Position correct: ☐ Yes ☐ No
- Notes:

---

### Test 2: Reverse Event Creation Sync (B → A)
**Objective:** Verify events created on Device B appear on Device A

**Steps:**
1. On Device B: Tap + button to open AddEventScreen
2. Create event:
   - Title: "Test Event B"
   - Start: Today, 2:00 PM
   - End: Today, 6:00 PM
   - Color: Green
   - Notes: "Testing sync from B to A"
3. Tap SAVE
4. Start timer immediately after save
5. On Device A: Watch calendar screen
6. Note when event appears on Device A

**Expected Result:**
- ✅ Event appears on Device A within 3 seconds
- ✅ All details match exactly
- ✅ Both events now visible on both devices

**Actual Result:**
- Time to sync: _____ seconds
- Both events visible: ☐ Yes ☐ No
- Notes:

---

### Test 3: Event Deletion Sync
**Objective:** Verify deleted events disappear on partner's device

**Steps:**
1. On Device A: Long-press or tap on "Test Event A"
2. If there's a delete option, delete the event
   - (Note: Delete functionality may need to be implemented)
3. Start timer
4. On Device B: Watch for event to disappear

**Expected Result:**
- ✅ Event disappears on Device B within 3 seconds
- ✅ "Test Event B" still visible on both devices

**Actual Result:**
- Time to sync: _____ seconds
- Delete worked: ☐ Yes ☐ No ☐ Feature not implemented
- Notes:

---

### Test 4: Multiple Rapid Events
**Objective:** Test sync reliability with multiple rapid changes

**Steps:**
1. On Device A: Create 3 events quickly:
   - "Morning Shift" - 8:00 AM to 12:00 PM (Orange)
   - "Afternoon Shift" - 1:00 PM to 5:00 PM (Red)
   - "Evening Shift" - 6:00 PM to 10:00 PM (Purple)
2. Create events back-to-back without waiting
3. On Device B: Count how many events appear and how long it takes

**Expected Result:**
- ✅ All 3 events appear on Device B
- ✅ All appear within 5-10 seconds total
- ✅ No events lost or duplicated

**Actual Result:**
- Events received: ___ of 3
- Time for all to sync: _____ seconds
- Issues: ☐ None ☐ Lost events ☐ Duplicates ☐ Wrong order
- Notes:

---

### Test 5: Offline → Online Sync
**Objective:** Verify events sync when device comes back online

**Steps:**
1. On Device A: Enable airplane mode (swipe down, tap airplane icon)
2. Create event: "Offline Event" - Tomorrow, 10:00 AM to 2:00 PM (Teal)
3. Verify event saved locally (appears on Device A calendar)
4. On Device B: Confirm event NOT visible yet
5. On Device A: Disable airplane mode
6. Start timer
7. On Device B: Watch for event to appear

**Expected Result:**
- ✅ Event saved locally on Device A while offline
- ✅ Event syncs to Device B within 5-10 seconds of reconnection
- ✅ Event details correct

**Actual Result:**
- Saved locally: ☐ Yes ☐ No
- Synced after reconnect: ☐ Yes ☐ No
- Time to sync: _____ seconds
- Notes:

---

### Test 6: Simultaneous Event Creation (Conflict Test)
**Objective:** Test how system handles simultaneous edits

**Steps:**
1. On both devices: Have AddEventScreen open
2. On Device A: Create "Conflict Test A" - 3:00 PM to 4:00 PM (Pink)
3. On Device B: Create "Conflict Test B" - 3:30 PM to 4:30 PM (Amber)
4. Save both at roughly the same time (within 1-2 seconds)
5. Wait 10 seconds
6. Check both devices

**Expected Result:**
- ✅ Both events appear on both devices
- ✅ No data loss
- ✅ Events may overlap (conflict detection is future feature)

**Actual Result:**
- Both events visible: ☐ Yes ☐ No
- Data loss: ☐ None ☐ One event lost
- Notes:

---

### Test 7: Background/Foreground Sync
**Objective:** Verify sync works when app is in background

**Steps:**
1. On Device B: Press home button (app goes to background)
2. On Device A: Create "Background Test" - Tomorrow, 9:00 AM to 5:00 PM (Blue)
3. Wait 5 seconds
4. On Device B: Open app from recent apps
5. Check if "Background Test" event is visible

**Expected Result:**
- ✅ Event appears when app returns to foreground
- ✅ Calendar refreshes automatically

**Actual Result:**
- Event visible: ☐ Yes ☐ No
- Auto-refresh: ☐ Yes ☐ Required manual refresh
- Notes:

---

### Test 8: Partner Visibility Test
**Objective:** Verify both partners' events are visible with color distinction

**Steps:**
1. Ensure both devices have multiple events from each user
2. On Device A: Review calendar
   - Can you tell which events are yours vs partner's?
   - Are colors consistent?
3. Tap on partner's event
4. Verify event details dialog shows partner's event correctly

**Expected Result:**
- ✅ Clear visual distinction between user and partner events
- ✅ Tapping partner events shows correct details
- ✅ All events positioned correctly without overlap issues

**Actual Result:**
- Visual distinction: ☐ Clear ☐ Unclear ☐ No distinction
- Partner event details: ☐ Correct ☐ Incorrect
- Notes:

---

## Performance Summary

| Metric | Target | Result | Pass/Fail |
|--------|--------|--------|-----------|
| Average sync latency | <3 sec | _____ sec | ☐ Pass ☐ Fail |
| Sync success rate | >95% | _____ % | ☐ Pass ☐ Fail |
| Events created | - | _____ | - |
| Events successfully synced | - | _____ | - |
| Data loss incidents | 0 | _____ | ☐ Pass ☐ Fail |
| Offline sync success | Yes | ☐ Yes ☐ No | ☐ Pass ☐ Fail |

---

## Issues Found

| Issue # | Description | Severity | Device | Steps to Reproduce |
|---------|-------------|----------|--------|-------------------|
| 1 | | ☐ Critical ☐ High ☐ Medium ☐ Low | | |
| 2 | | ☐ Critical ☐ High ☐ Medium ☐ Low | | |
| 3 | | ☐ Critical ☐ High ☐ Medium ☐ Low | | |

---

## Test Accounts Used

**Account A:**
- Email: _______________________
- Device: Medium_Phone_API_36.1
- Partner: Account B

**Account B:**
- Email: _______________________
- Device: Pixel_9
- Partner: Account A

---

## Firestore Console Verification

To verify sync at database level:
1. Open Firebase Console: https://console.firebase.google.com/project/deb-shiftsync-7984c
2. Go to Firestore Database → events collection
3. Watch for real-time updates as you create events
4. Verify document structure matches EventModel schema

---

## Next Steps Based on Results

**If sync is working (>95% success, <3s latency):**
- ✅ Mark Week 12 Checkpoint as PASSED
- ✅ Move to Week 13-16: Notifications & Conflict Detection
- ✅ Update project_summary.md with test results

**If sync has issues:**
- 🔧 Debug Firestore listeners in calendar_screen.dart
- 🔧 Check Firestore security rules
- 🔧 Add verbose logging to sync operations
- 🔧 Test with Firebase Local Emulator for debugging

---

## Notes

- Event edit functionality not yet implemented (Week 13)
- Event delete functionality not yet implemented (Week 13)
- Conflict detection is visual only (alerts coming in Week 13-16)
- Offline mode partially tested (full implementation in Week 17-20)
