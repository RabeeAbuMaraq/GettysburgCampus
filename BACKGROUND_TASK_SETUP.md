# Background Task Setup Instructions

## Issue Fixed
The console error "Registration rejected; com.gettysburgcampus.eventrefresh is not advertised in the application's Info.plist" can be resolved by adding the background task identifier to your Xcode project settings.

## How to Fix in Xcode

### Method 1: Using Xcode Target Settings (Recommended)

1. **Open your project in Xcode**

2. **Select your app target** (Gettysburg Campus App) in the project navigator

3. **Go to the "Info" tab**

4. **Add Background Modes:**
   - Find or add a key called `UIBackgroundModes` (or "Required background modes")
   - Click the "+" button to add array items
   - Add two string values:
     - `fetch`
     - `processing`

5. **Add Background Task Identifier:**
   - Find or add a key called `BGTaskSchedulerPermittedIdentifiers` (or "Permitted background task scheduler identifiers")
   - Click the "+" button to add array items
   - Add this string value: `com.gettysburgcampus.eventrefresh`

### Method 2: Using Info Plist Source Code

1. **Right-click on the Info section** in your target settings
2. **Select "Show Raw Keys/Values"**
3. **Add these entries:**

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.gettysburgcampus.eventrefresh</string>
</array>
```

## Verification

After making these changes:
1. Clean your build folder (Cmd+Shift+K)
2. Build the project (Cmd+B)
3. Run the app
4. The background task registration error should be gone!

## Note

Modern SwiftUI apps don't typically have a separate Info.plist file in the source directory. All Info.plist settings are managed through Xcode's target configuration interface. This is why we removed the separate Info.plist file that was causing the build conflict.

