# Running FindItKIET iOS App in Xcode - Step by Step Guide

## ⚠️ Important Note
The iOS app files have been created, but we need to set up an Xcode project to build them. Follow these steps:

## Option 1: Create New Xcode Project (Recommended)

### Step 1: Open Xcode
1. Open **Xcode** from your Applications folder
2. Or use Spotlight: Press `Cmd + Space`, type "Xcode"

### Step 2: Create New Project
1. Click **"Create New Project"** or go to `File > New > Project`
2. Select **iOS** tab at the top
3. Choose **App** template
4. Click **Next**

### Step 3: Configure Project
Fill in the following details:
- **Product Name**: `FindItKIET`
- **Team**: Select your Apple Developer Team (or leave as "None" for simulator only)
- **Organization Identifier**: `com.kiet` (or your preferred identifier)
- **Bundle Identifier**: Will auto-fill as `com.kiet.FindItKIET`
- **Interface**: Select **SwiftUI**
- **Language**: Select **Swift**
- **Storage**: Leave as **None**
- Uncheck "Include Tests" for now

Click **Next**

### Step 4: Save Project
1. Navigate to: `/Users/pulkitverma/Documents/FindItKIET/FindItKIET/ios-app/`
2. Name it: `FindItKIET`
3. **IMPORTANT**: Uncheck "Create Git repository on my Mac"
4. Click **Create**

### Step 5: Replace Default Files
Now we need to replace the default files with our implementation:

1. In Xcode's left sidebar (Navigator), you'll see the `FindItKIET` folder
2. **Delete** the default `ContentView.swift` file (right-click > Delete > Move to Trash)
3. Keep `FindItKIETApp.swift` - we'll replace its contents

### Step 6: Add Our Files

#### Method A: Drag and Drop (Easier)
1. Open Finder and navigate to: `/Users/pulkitverma/Documents/FindItKIET/FindItKIET/ios-app/FindItApp/`
2. Select ALL the folders (Core, Features, Components, Models, Navigation)
3. Drag them into Xcode's Navigator under the `FindItKIET` group
4. In the dialog that appears:
   - ✅ Check "Copy items if needed"
   - ✅ Check "Create groups"
   - ✅ Select `FindItKIET` target
   - Click **Finish**

#### Method B: Add Files (More organized)
1. Right-click on `FindItKIET` folder in Xcode
2. Select **Add Files to "FindItKIET"...**
3. Navigate to `/Users/pulkitverma/Documents/FindItKIET/FindItKIET/ios-app/FindItApp/`
4. Select all folders and files
5. Make sure these are checked:
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ Add to targets: FindItKIET
6. Click **Add**

### Step 7: Replace App Entry Point
1. Open `FindItKIETApp.swift` (double-click in Navigator)
2. Replace ALL its contents with our version:

```swift
//
//  FindItKIETApp.swift
//  FindItKIET
//
//  Production-ready campus lost-and-found iOS app
//

import SwiftUI

@main
struct FindItKIETApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(appState)
        }
    }
}
```

3. Save: `Cmd + S`

### Step 8: Configure Backend URL
1. In Navigator, find and open: `Core > Networking > APIClient.swift`
2. Verify the DEBUG baseURL points to your local backend:
   ```swift
   #if DEBUG
   baseURL = "http://localhost:3000/api/v1"
   ```
3. Save if you made changes

### Step 9: Select Simulator
1. At the top of Xcode window, click the device dropdown (next to the Play button)
2. Select **iPhone 15 Pro** (or any iPhone with iOS 15.0+)
3. If you don't see simulators, go to `Xcode > Settings > Platforms` and download iOS Simulator

### Step 10: Build and Run! 🚀
1. Click the **Play button** (▶️) at top left, or press `Cmd + R`
2. Wait for Xcode to build (first build takes 1-2 minutes)
3. The iOS Simulator will launch automatically
4. The app should appear!

---

## Option 2: Quick Terminal Method (If Xcode gives issues)

If you have Xcode Command Line Tools:

```bash
cd /Users/pulkitverma/Documents/FindItKIET/FindItKIET/ios-app
swift package init --type executable --name FindItKIET
```

Then follow Option 1 from Step 5.

---

## Testing the App

### First Time Setup:
1. **App launches** → You should see the login screen with FindItKIET logo
2. **Login** with:
   - Email: `test@kiet.edu`
   - Password: `password123`
3. If login succeeds, you'll see the main tab bar interface

### Navigation Test:
1. **Home Tab**: Browse items (will be empty initially)
2. **Report Tab**: Placeholder screen for reporting items
3. **My Claims Tab**: View your claims
4. **Profile Tab**: See user info and logout button

### Create Test Data:
To see items in the app, create some via the backend:

```bash
# In a new terminal
cd /Users/pulkitverma/Documents/FindItKIET/FindItKIET/backend
./test-api.sh
```

This will create test items you can view in the app.

---

## Troubleshooting

### "No such module 'SwiftUI'"
- Make sure iOS Deployment Target is set to iOS 15.0+
- Go to Project Settings > General > Deployment Info

### "Cannot find 'AppState' in scope"
- Make sure all files were added to the project
- Check in Navigator that Core/State/AppState.swift exists
- Try cleaning build: `Cmd + Shift + K`, then rebuild

### "Command CodeSign failed"
- For simulator testing, you don't need signing
- Go to Project Settings > Signing & Capabilities
- Uncheck "Automatically manage signing"
- Set Team to "None"

### Simulator doesn't launch
- Quit Simulator app
- In Xcode: `Xcode > Settings > Locations`
- Verify Command Line Tools is selected
- Try different simulator device

### Backend connection fails
- Make sure backend is running: Check terminal with `npm run dev`
- Verify URL in APIClient.swift is `http://localhost:3000/api/v1`
- Check that simulator can reach localhost (should work by default)

---

## Expected First Run Experience

1. ✅ App launches → Login screen appears
2. ✅ Enter credentials → Loading indicator shows
3. ✅ Login succeeds → Tab bar interface appears
4. ✅ Tap tabs → Different screens load
5. ✅ Items tab → Empty state (until you add items via backend)

---

## Next Steps After App Runs

1. Create test items via backend API or test script
2. Test item browsing and search
3. Test item detail view
4. Test claim submission
5. Test logout and login again

Good luck! 🍀
