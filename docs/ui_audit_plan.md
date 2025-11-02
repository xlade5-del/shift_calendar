# UI Audit Plan
**Created:** November 1, 2025
**Purpose:** Systematic review of all screens before Week 17-20 implementation
**Estimated Time:** 3-5 hours for complete audit

---

## How to Use This Document

1. **Run the app** - Have the app running on a device/simulator
2. **Go through each screen** - Follow the checklist below
3. **Take screenshots** - Capture before/after images
4. **Document issues** - Note problems in the "Issues Found" section
5. **Prioritize fixes** - Mark issues as P0 (critical), P1 (important), P2 (nice-to-have)

---

## Screen Inventory

### Current Screens (from lib/screens/)

#### Auth Screens (3)
1. `auth/welcome_screen.dart` - App entry point
2. `auth/login_screen.dart` - Email sign-in
3. `auth/signup_screen.dart` - Email sign-up

#### Home Screen (1)
4. `home_screen.dart` - Month calendar view hub

#### Calendar Screens (2)
5. `calendar/calendar_screen.dart` - Week view with events
6. `calendar/free_time_finder_screen.dart` - Mutual availability finder

#### Event Screens (2)
7. `event/add_event_screen.dart` - Create new event
8. `event/edit_event_screen.dart` - Edit/delete existing event

#### Partner Screens (3)
9. `partner/partner_invite_screen.dart` - Generate partner code
10. `partner/partner_accept_screen.dart` - Accept partner code
11. `partner/partner_management_screen.dart` - View/manage partner

#### Settings Screens (1)
12. `settings/notification_settings_screen.dart` - Notification preferences

**Total: 12 screens**

---

## Audit Checklist Template

For each screen, evaluate these aspects:

### ✅ Visual Design
- [ ] Uses AppColors consistently (no hardcoded colors)
- [ ] Follows spacing system (4, 8, 16, 24, 32px)
- [ ] Typography is consistent (readable sizes, weights)
- [ ] Cards/containers have consistent border radius (16px)
- [ ] Shadows/elevation consistent across components
- [ ] Background color matches design (Color(0xFFF5F5F7) or white)

### ✅ Layout & Structure
- [ ] Content doesn't overflow on small screens (iPhone SE)
- [ ] Proper padding/margins on all edges
- [ ] Elements aligned correctly (no random positioning)
- [ ] Scrollable content works properly
- [ ] Safe area handled (notches, status bar, home indicator)
- [ ] Landscape orientation doesn't break layout

### ✅ Interactive Elements
- [ ] All buttons have minimum 44px tap target
- [ ] Buttons have consistent style (primary vs secondary)
- [ ] Form inputs have proper styling and labels
- [ ] Loading states exist (spinner or skeleton)
- [ ] Disabled states are visually distinct
- [ ] Active/pressed states provide feedback

### ✅ Navigation
- [ ] Back button works (returns to previous screen)
- [ ] Navigation path is logical (no dead ends)
- [ ] Deep linking works (if applicable)
- [ ] Bottom navigation highlighted correctly (if applicable)
- [ ] Breadcrumb/title shows current location

### ✅ Content States
- [ ] **Loading State** - Shows progress indicator
- [ ] **Empty State** - Friendly message + action button
- [ ] **Error State** - Clear message + retry option
- [ ] **Populated State** - Data displays correctly
- [ ] **Success State** - Confirmation feedback after actions

### ✅ Error Handling
- [ ] Network errors handled gracefully
- [ ] Form validation shows clear messages
- [ ] Firebase errors translated to user-friendly text
- [ ] Retry mechanisms available

### ✅ Accessibility
- [ ] Text contrast ratio ≥4.5:1
- [ ] Text sizes readable (minimum 14px)
- [ ] Tap targets ≥44px x 44px
- [ ] Text scales with system font settings
- [ ] Semantic labels for screen readers (if implemented)

### ✅ Performance
- [ ] Screen loads in <1 second
- [ ] No jank/stuttering during scrolling
- [ ] Images load efficiently (cached, compressed)
- [ ] Unnecessary rebuilds minimized (const constructors)

---

## Screen-by-Screen Audit

### 1. Welcome Screen (`auth/welcome_screen.dart`)

**Purpose:** First screen users see, introduces app

**User Journey:**
- New user opens app → sees Welcome
- Taps "Login" → goes to Login Screen
- Taps "Sign Up" → goes to Signup Screen

**Audit Checklist:**
- [ ] Visual Design - Colors, spacing, typography
- [ ] Layout - Proper padding, centered content
- [ ] Buttons - "Login" and "Sign Up" buttons styled correctly
- [ ] Navigation - Routes to login/signup screens
- [ ] Empty State - N/A (always has content)
- [ ] Error State - N/A (no data loading)
- [ ] Accessibility - Logo has semantic label, buttons tappable

**Screenshots:**
- [ ] Default state

**Issues Found:**
```
Priority | Issue | Solution
---------|-------|----------
         |       |
```

---

### 2. Login Screen (`auth/login_screen.dart`)

**Purpose:** Email/password sign-in

**User Journey:**
- User enters email + password → taps "Login"
- Success → navigates to Home Screen
- Error → shows error message

**Audit Checklist:**
- [ ] Visual Design
- [ ] Layout - Form centered, keyboard doesn't obscure fields
- [ ] Form Inputs - Email and password fields styled
- [ ] Buttons - "Login" button (primary style)
- [ ] Loading State - Shows spinner while authenticating
- [ ] Error State - Shows Firebase errors in friendly way
- [ ] Success State - Navigates to Home on success
- [ ] Navigation - "Back" returns to Welcome, "Sign Up" link works
- [ ] Accessibility - Labels for email/password fields

**Screenshots:**
- [ ] Default state
- [ ] Loading state (during sign-in)
- [ ] Error state (wrong password)

**Issues Found:**
```
Priority | Issue | Solution
---------|-------|----------
         |       |
```

---

### 3. Signup Screen (`auth/signup_screen.dart`)

**Purpose:** Email/password registration

**User Journey:**
- User enters name, email, password → taps "Sign Up"
- Success → navigates to Home Screen
- Error → shows validation errors

**Audit Checklist:**
- [ ] Visual Design
- [ ] Layout - Form fields stacked properly
- [ ] Form Inputs - Name, email, password fields
- [ ] Validation - Email format, password strength
- [ ] Buttons - "Sign Up" button (primary style)
- [ ] Loading State - Spinner during account creation
- [ ] Error State - Clear validation messages
- [ ] Success State - Navigates to Home
- [ ] Navigation - "Back" to Welcome, "Login" link works
- [ ] Accessibility

**Screenshots:**
- [ ] Default state
- [ ] Validation error state
- [ ] Loading state

**Issues Found:**
```
Priority | Issue | Solution
---------|-------|----------
         |       |
```

---

### 4. Home Screen (`home_screen.dart`)

**Purpose:** Main hub with month calendar view

**User Journey:**
- User sees current month calendar
- Taps workplace dropdown → selects workplace
- Taps day → opens event list modal
- Navigates via bottom nav (Paint/Edit/Shifts)
- Taps tabs (Month/Year/Summary)

**Audit Checklist:**
- [ ] Visual Design - Month grid, header, navigation
- [ ] Layout - Calendar grid aligned, responsive
- [ ] Month Grid - Accurate dates, current day highlighted
- [ ] Workplace Dropdown - Functions correctly
- [ ] Tab Navigation - Month/Year/Summary tabs work
- [ ] Bottom Navigation - Paint/Edit/Shifts buttons work
- [ ] Day Selection - Modal shows events for selected day
- [ ] Loading State - While fetching events
- [ ] Empty State - No events this month
- [ ] Event Display - Events shown on correct dates
- [ ] Navigation - To Calendar, Partner screens
- [ ] Accessibility - Day buttons tappable (≥44px)

**Screenshots:**
- [ ] Default state (with events)
- [ ] Empty state (no events)
- [ ] Day selection modal
- [ ] Loading state

**Issues Found:**
```
Priority | Issue | Solution
---------|-------|----------
         |       |
```

---

### 5. Calendar Screen (`calendar/calendar_screen.dart`)

**Purpose:** Week view with both partners' events

**User Journey:**
- User sees current week (7 days, 24-hour grid)
- Swipes left/right or taps arrows → navigate weeks
- Taps "Today" → returns to current week
- Taps event → opens event details dialog
- Taps FAB → opens Add Event Screen
- Conflict badge shown if overlapping events exist

**Audit Checklist:**
- [ ] Visual Design - Grid lines, time labels, day headers
- [ ] Layout - 24-hour slots, events positioned correctly
- [ ] Week Navigation - Previous/Next week, Today button
- [ ] Day Headers - Current day highlighted
- [ ] Event Rendering - Colored blocks with titles
- [ ] Event Overlap - Stacked properly, still readable
- [ ] Event Tap - Opens details dialog
- [ ] Conflict Badge - Shows when partners overlap
- [ ] FAB - Add event button positioned correctly
- [ ] Loading State - Skeleton or spinner while loading
- [ ] Empty State - "No events this week" message
- [ ] Real-time Updates - Events appear immediately after creation
- [ ] Accessibility - Time slots readable, events tappable

**Screenshots:**
- [ ] Week view with events
- [ ] Empty week view
- [ ] Overlapping events
- [ ] Conflict badge visible
- [ ] Event details dialog
- [ ] Loading state

**Issues Found:**
```
Priority | Issue | Solution
---------|-------|----------
         |       |
```

---

### 6. Free Time Finder Screen (`calendar/free_time_finder_screen.dart`)

**Purpose:** Find mutual free time between partners

**User Journey:**
- User opens screen
- Sees list of time blocks when both are free
- Taps time block → option to create event (future feature)

**Audit Checklist:**
- [ ] Visual Design
- [ ] Layout - List of free time blocks
- [ ] Free Time Display - Clear start/end times
- [ ] Date Grouping - Organized by day
- [ ] Loading State - While analyzing schedules
- [ ] Empty State - "No mutual free time found" message
- [ ] Populated State - Shows multiple free blocks
- [ ] Navigation - Back to previous screen
- [ ] Accessibility

**Screenshots:**
- [ ] Free time results
- [ ] Empty state (no free time)
- [ ] Loading state

**Issues Found:**
```
Priority | Issue | Solution
---------|-------|----------
         |       |
```

---

### 7. Add Event Screen (`event/add_event_screen.dart`)

**Purpose:** Create new calendar event/shift

**User Journey:**
- User fills form: title, start date/time, end date/time, color, notes
- Taps "Save" → event created, returns to Calendar
- Taps "Cancel" → returns without saving

**Audit Checklist:**
- [ ] Visual Design - Form layout, color picker
- [ ] Layout - Fields stacked properly
- [ ] Form Fields - Title, date/time pickers, color, notes
- [ ] Date/Time Pickers - Easy to use, default to current time
- [ ] Color Picker - 8 colors displayed clearly
- [ ] Validation - Required fields enforced
- [ ] Buttons - "Save" (primary), "Cancel" (secondary)
- [ ] Loading State - Saving event
- [ ] Error State - Save failure with retry
- [ ] Success State - Confirmation, navigates back
- [ ] Navigation - Back/Cancel returns to Calendar
- [ ] Accessibility - All inputs labeled

**Screenshots:**
- [ ] Empty form
- [ ] Filled form
- [ ] Color picker
- [ ] Date/time picker
- [ ] Validation error
- [ ] Loading state

**Issues Found:**
```
Priority | Issue | Solution
---------|-------|----------
         |       |
```

---

### 8. Edit Event Screen (`event/edit_event_screen.dart`)

**Purpose:** Edit or delete existing event

**User Journey:**
- User opens event from Calendar
- Modifies fields → taps "Save"
- Or taps "Delete" → confirms deletion

**Audit Checklist:**
- [ ] Visual Design
- [ ] Layout - Similar to Add Event Screen
- [ ] Form Pre-fill - Existing data loaded correctly
- [ ] Edit Functionality - Changes save properly
- [ ] Delete Button - Clearly visible, distinct style
- [ ] Delete Confirmation - "Are you sure?" dialog
- [ ] Loading State - Saving changes or deleting
- [ ] Error State - Update/delete failures
- [ ] Success State - Confirmation, navigates back
- [ ] Navigation - Cancel returns without changes
- [ ] Accessibility

**Screenshots:**
- [ ] Pre-filled form
- [ ] Delete confirmation dialog
- [ ] Loading state

**Issues Found:**
```
Priority | Issue | Solution
---------|-------|----------
         |       |
```

---

### 9. Partner Invite Screen (`partner/partner_invite_screen.dart`)

**Purpose:** Generate 6-digit code for partner to link

**User Journey:**
- User opens screen → code auto-generated
- Code displayed with expiration time (24 hours)
- User shares code with partner
- Taps "Generate New Code" → refreshes code

**Audit Checklist:**
- [ ] Visual Design - Code prominently displayed
- [ ] Layout - Code centered, easy to read
- [ ] Code Display - Large, copyable text
- [ ] Expiration Timer - Shows countdown
- [ ] Refresh Button - Generate new code
- [ ] Copy Button - Copy code to clipboard (future)
- [ ] Loading State - Generating code
- [ ] Error State - Code generation failure
- [ ] Navigation - Back to Home/Partner Management
- [ ] Accessibility - Code readable (large font)

**Screenshots:**
- [ ] Generated code
- [ ] Loading state

**Issues Found:**
```
Priority | Issue | Solution
---------|-------|----------
         |       |
```

---

### 10. Partner Accept Screen (`partner/partner_accept_screen.dart`)

**Purpose:** Enter partner's code to link accounts

**User Journey:**
- User enters 6-digit code
- Taps "Link Partner"
- Success → partners linked, navigates to Home
- Error → shows "Invalid code" or "Code expired"

**Audit Checklist:**
- [ ] Visual Design
- [ ] Layout - Code input field centered
- [ ] Code Input - 6 digits, auto-formatted
- [ ] Validation - Code format validation
- [ ] Buttons - "Link Partner" button
- [ ] Loading State - Validating code
- [ ] Error State - Invalid/expired code messages
- [ ] Success State - "Linked successfully!" confirmation
- [ ] Navigation - Back to previous screen
- [ ] Accessibility

**Screenshots:**
- [ ] Empty input
- [ ] Entering code
- [ ] Loading state
- [ ] Error state (invalid code)
- [ ] Success state

**Issues Found:**
```
Priority | Issue | Solution
---------|-------|----------
         |       |
```

---

### 11. Partner Management Screen (`partner/partner_management_screen.dart`)

**Purpose:** View linked partner info and unlink if needed

**User Journey:**
- User sees partner's name and email
- Taps "Unlink Partner" → confirmation dialog → partners unlinked

**Audit Checklist:**
- [ ] Visual Design - Partner info card
- [ ] Layout - Name, email displayed clearly
- [ ] Partner Info - Accurate data from Firestore
- [ ] Unlink Button - Distinct, destructive style (red)
- [ ] Unlink Confirmation - "Are you sure?" dialog
- [ ] Loading State - Unlinking partner
- [ ] Error State - Unlink failure
- [ ] Success State - Confirmation, navigates back
- [ ] Empty State - No partner linked (show invite option)
- [ ] Navigation
- [ ] Accessibility

**Screenshots:**
- [ ] Partner linked state
- [ ] No partner state
- [ ] Unlink confirmation dialog

**Issues Found:**
```
Priority | Issue | Solution
---------|-------|----------
         |       |
```

---

### 12. Notification Settings Screen (`settings/notification_settings_screen.dart`)

**Purpose:** Configure notification preferences

**User Journey:**
- User sees toggle switches for:
  - Partner schedule changes
  - Conflict alerts
  - Free time notifications
- Toggles settings → auto-saved to Firestore

**Audit Checklist:**
- [ ] Visual Design - Settings list with toggles
- [ ] Layout - Each setting has label + description
- [ ] Toggle Switches - Work correctly, show current state
- [ ] Auto-Save - Changes saved immediately
- [ ] Loading State - While loading preferences
- [ ] Error State - Save failure with retry
- [ ] Success State - Subtle confirmation (toast or checkmark)
- [ ] Navigation - Back to Home/Settings
- [ ] Accessibility - Toggle labels clear

**Screenshots:**
- [ ] Settings loaded
- [ ] Loading state

**Issues Found:**
```
Priority | Issue | Solution
---------|-------|----------
         |       |
```

---

## Cross-Screen Consistency Check

After auditing individual screens, verify consistency across all screens:

### Colors
- [ ] All screens use AppColors (no random hardcoded colors)
- [ ] Primary color consistent everywhere
- [ ] Background color consistent (0xFFF5F5F7)
- [ ] Error color consistent (red[700])

### Typography
- [ ] Heading sizes consistent (24px, 20px, 18px)
- [ ] Body text 16px everywhere
- [ ] Font weights consistent (bold for H1, w600 for H2, normal for body)

### Spacing
- [ ] Screen padding consistent (16-24px)
- [ ] Card padding consistent (16px)
- [ ] Spacing between elements follows system (8, 16, 24px)

### Components
- [ ] All primary buttons same style (height, radius, color)
- [ ] All secondary buttons same style
- [ ] All cards same border radius (16px) and shadow
- [ ] All text inputs same height (48px) and styling

### Navigation
- [ ] Back button behavior consistent (top-left on iOS, hardware on Android)
- [ ] Navigation transitions smooth
- [ ] No navigation dead ends

---

## Device Testing Matrix

Test on multiple screen sizes to catch layout issues:

| Device | Screen Size | Orientation | Status |
|--------|-------------|-------------|--------|
| iPhone SE | 4.7" (375x667) | Portrait | ⏳ |
| iPhone 14 Pro | 6.1" (393x852) | Portrait | ⏳ |
| iPhone 14 Pro Max | 6.7" (430x932) | Portrait | ⏳ |
| iPhone SE | 4.7" | Landscape | ⏳ |
| Android Pixel 5 | 6.0" (393x851) | Portrait | ⏳ |
| Android Galaxy S21+ | 6.7" (412x915) | Portrait | ⏳ |

**How to test:**
```bash
# iOS Simulators
flutter run -d "iPhone SE"
flutter run -d "iPhone 14 Pro"

# Android Emulators
flutter run -d emulator-5554
```

---

## Priority Issue Tracking

As you audit, categorize issues by priority:

### P0 - Critical (Must Fix Before Week 17-20)
These break core functionality or make the app unusable:
- App crashes
- Major navigation broken
- Forms don't submit
- Data not saving
- Critical visual bugs (overlapping text, unreadable content)

**P0 Issues:**
```
Screen | Issue | Fix
-------|-------|----
       |       |
```

### P1 - Important (Should Fix)
These significantly impact user experience:
- Inconsistent colors/spacing
- Missing loading states
- Missing empty states
- Confusing error messages
- Poor accessibility (contrast, tap targets)

**P1 Issues:**
```
Screen | Issue | Fix
-------|-------|----
       |       |
```

### P2 - Nice-to-Have (Can Defer)
These are polish items but don't block functionality:
- Subtle animations
- Micro-interactions
- Advanced accessibility features
- Visual flourishes

**P2 Issues:**
```
Screen | Issue | Fix
-------|-------|----
       |       |
```

---

## Audit Summary

**Date Completed:** _____________

**Total Screens Audited:** 12

**Issues Found:**
- P0 (Critical): ___
- P1 (Important): ___
- P2 (Nice-to-Have): ___

**Estimated Fix Time:**
- P0: ___ hours
- P1: ___ hours
- P2: ___ hours

**Next Steps:**
1. Fix all P0 issues
2. Fix P1 issues (target 80%+ completion)
3. Defer P2 issues or tackle if time permits
4. Re-test all screens after fixes
5. Update CLAUDE.md with UI Polish Phase completion
6. Proceed to Week 17-20

---

## Audit Tips

1. **Be systematic** - Don't skip screens or checklists
2. **Take screenshots** - Visual documentation is invaluable
3. **Test edge cases** - Long text, empty states, slow network
4. **Think like a new user** - Is anything confusing?
5. **Compare to popular apps** - What do Google Calendar, Notion, Slack do?
6. **Get feedback** - Show to a friend, watch them use it
7. **Document everything** - Future you will thank present you

---

## Resources

- **Material Design Guidelines:** https://m3.material.io/
- **iOS Human Interface Guidelines:** https://developer.apple.com/design/human-interface-guidelines/
- **WebAIM Contrast Checker:** https://webaim.org/resources/contrastchecker/
- **Flutter Widget Catalog:** https://docs.flutter.dev/ui/widgets

---

**Status:** Ready to begin audit
**Next:** Start with Welcome Screen, work through all 12 screens
