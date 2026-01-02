# Firebase Setup - Quick Start Commands

Follow these steps IN ORDER to set up Firebase for your Sargon app.

## ⚠️ Your Firebase Project

**Project ID:** `sargon-25f65`
**Project Name:** sargon

---

## Prerequisites

Make sure you have Node.js installed. Check with: `node --version`

---

## Step 1: Install Firebase CLI (if not installed)

```bash
npm install -g firebase-tools
```

## Step 2: Login to Firebase (if not logged in)

```bash
firebase login
```

## Step 3: Fix xcodeproj Error (Optional - for iOS)

If you need iOS support, install the xcodeproj gem:

```bash
sudo gem install xcodeproj
```

## Step 4: Configure Flutter App

```bash
# Install/Update FlutterFire CLI
dart pub global activate flutterfire_cli

# Ensure dart pub is in PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Configure Firebase with YOUR project ID
cd /Users/anuragdhunna/Downloads/Workspaces/sargon_app
flutterfire configure --project=sargon-25f65
```

**If iOS fails**, you can configure for web/android only:
```bash
flutterfire configure --project=sargon-25f65 --platforms=android,web
```

## Step 5: Enable Firebase Services in Console

Go to [Firebase Console](https://console.firebase.google.com/project/sargon-25f65):

### Authentication:
1. Go to **Authentication** > **Sign-in method**
2. Click on **Email/Password**
3. Toggle **Enable** to ON
4. Click **Save**

### Realtime Database:
1. Go to **Realtime Database**
2. Click **Create Database**
3. Choose location (us-central1 recommended)
4. Start in **Test mode** (we'll add rules later)
5. Click **Enable**

## Step 6: Deploy Database Rules

```bash
firebase deploy --only database --project=sargon-25f65
```

## Step 7: Run the App

```bash
# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome
```

---

## Deploying to Firebase Hosting

### First-time setup:

```bash
# Initialize Firebase Hosting
firebase init hosting --project=sargon-25f65

# When prompted:
# - Public directory: build/web
# - Single-page app: Yes
# - Automatic builds: No
```

### Build and Deploy:

```bash
# Build Flutter web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting --project=sargon-25f65
```

Your app will be live at: `https://sargon-25f65.web.app`

---

## Test Credentials (Development Mode)

When Firebase Auth is not fully configured, you can use persona login:

| Email Pattern | Role |
|---------------|------|
| owner@test.com | Owner |
| manager@test.com | Manager |
| chef@test.com | Chef |
| waiter@test.com | Waiter |
| housekeeping@test.com | Housekeeping |
| frontdesk@test.com | Front Desk |

Any password works in development mode.

---

## Troubleshooting

### "firebase: command not found"
```bash
npm install -g firebase-tools
# Restart terminal
```

### "flutterfire: command not found"
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
source ~/.zshrc
```

### "cannot load such file -- xcodeproj"
```bash
# Install xcodeproj gem (requires sudo)
sudo gem install xcodeproj

# OR skip iOS and configure only android/web
flutterfire configure --project=sargon-25f65 --platforms=android,web
```

### "Build failed with web"
```bash
flutter clean
flutter pub get
flutter build web --release
```

---

## Firebase Console Links

- **Project Overview:** https://console.firebase.google.com/project/sargon-25f65
- **Authentication:** https://console.firebase.google.com/project/sargon-25f65/authentication
- **Realtime Database:** https://console.firebase.google.com/project/sargon-25f65/database
- **Hosting:** https://console.firebase.google.com/project/sargon-25f65/hosting
