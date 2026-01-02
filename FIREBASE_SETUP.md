# Firebase Setup Guide for Sargon App

> **Last Updated:** 2025-12-11
> **Purpose:** Complete Firebase integration with Realtime Database, Authentication, and Hosting

---

## 1. Overview

This document outlines the complete Firebase integration for the Sargon Hotel Management App:

- **Firebase Realtime Database** - Real-time data sync (Free Tier: 1GB storage, 10GB/month download)
- **Firebase Authentication** - Email/Password auth using `createUserWithEmailAndPassword`
- **Firebase Hosting** - Host the Flutter Web app (Free Tier: 10GB storage, 360MB/day bandwidth)

---

## 2. Terminal Commands to Run

### Step 1: Install Firebase CLI (if not installed)
```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login
```

### Step 2: Install FlutterFire CLI
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### Step 3: Create Firebase Project (via Firebase Console)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing: **sargon-25f65**
3. **Disable Google Analytics** (optional, saves quota)

### Step 4: Configure Flutter App with Firebase
```bash
# Navigate to project directory
cd /Users/anuragdhunna/Downloads/Workspaces/sargon_app

# Configure Firebase for your Flutter app
flutterfire configure --project=sargon-25f65

# If iOS fails due to xcodeproj gem, use:
flutterfire configure --project=sargon-25f65 --platforms=android,web
```

### Step 5: Enable Firebase Services in Console
1. **Authentication:**
   - Go to Firebase Console > Authentication > Sign-in method
   - Enable "Email/Password" provider

2. **Realtime Database:**
   - Go to Firebase Console > Realtime Database
   - Click "Create Database"
   - Select location (e.g., `us-central1`)
   - Start in **Test Mode** (we'll add rules later)

### Step 6: Update Dependencies
```bash
# Get updated packages
flutter pub get
```

### Step 7: Initialize Firebase Hosting
```bash
# Initialize Firebase Hosting
firebase init hosting

# When prompted:
# - Select your Firebase project (sargon)
# - Set public directory to: build/web
# - Configure as single-page app: Yes
# - Set up automatic builds: No
```

### Step 8: Build and Deploy to Firebase Hosting
```bash
# Build Flutter web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

---

## 3. Firebase Realtime Database Rules

Create the following rules in Firebase Console > Realtime Database > Rules:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid || root.child('users').child(auth.uid).child('role').val() === 'owner' || root.child('users').child(auth.uid).child('role').val() === 'manager'",
        ".write": "$uid === auth.uid || root.child('users').child(auth.uid).child('role').val() === 'owner'"
      }
    },
    "orders": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "rooms": {
      ".read": "auth != null",
      ".write": "root.child('users').child(auth.uid).child('role').val() === 'owner' || root.child('users').child(auth.uid).child('role').val() === 'manager' || root.child('users').child(auth.uid).child('role').val() === 'frontDesk'"
    },
    "inventory": {
      ".read": "auth != null",
      ".write": "root.child('users').child(auth.uid).child('role').val() === 'owner' || root.child('users').child(auth.uid).child('role').val() === 'manager'"
    },
    "checklists": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "incidents": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "attendance": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "vendors": {
      ".read": "auth != null",
      ".write": "root.child('users').child(auth.uid).child('role').val() === 'owner' || root.child('users').child(auth.uid).child('role').val() === 'manager'"
    },
    "purchaseOrders": {
      ".read": "auth != null",
      ".write": "root.child('users').child(auth.uid).child('role').val() === 'owner' || root.child('users').child(auth.uid).child('role').val() === 'manager'"
    },
    "goodsReceipts": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "menuItems": {
      ".read": "auth != null",
      ".write": "root.child('users').child(auth.uid).child('role').val() === 'owner' || root.child('users').child(auth.uid).child('role').val() === 'manager'"
    }
  }
}
```

---

## 4. Database Schema

```
sargon/
├── users/
│   └── {uid}/
│       ├── id: string
│       ├── email: string
│       ├── name: string
│       ├── phoneNumber: string
│       ├── role: string (enum)
│       ├── status: string (enum)
│       ├── paymentType: string
│       ├── dailyWage: number?
│       ├── monthlySalary: number?
│       ├── avatarUrl: string?
│       └── createdAt: timestamp
│
├── orders/
│   └── {orderId}/
│       ├── id: string
│       ├── tableNumber: string
│       ├── items: [MenuItem]
│       ├── status: string (enum)
│       ├── timestamp: timestamp
│       ├── orderNotes: string?
│       └── createdBy: string (uid)
│
├── rooms/
│   └── {roomId}/
│       ├── id: string
│       ├── roomNumber: string
│       ├── type: string (enum)
│       ├── status: string (enum)
│       ├── pricePerNight: number
│       ├── floor: number
│       ├── capacity: number
│       └── amenities: [string]
│
├── bookings/
│   └── {bookingId}/
│       ├── id: string
│       ├── guestName: string
│       ├── guestPhone: string
│       ├── guestEmail: string?
│       ├── roomId: string
│       ├── checkIn: timestamp
│       ├── checkOut: timestamp
│       ├── totalAmount: number
│       ├── status: string (enum)
│       ├── bookedBy: string (uid)
│       └── createdAt: timestamp
│
├── inventory/
│   └── {itemId}/
│       ├── id: string
│       ├── name: string
│       ├── category: string (enum)
│       ├── quantity: number
│       ├── minQuantity: number
│       ├── unit: string (enum)
│       ├── pricePerUnit: number
│       └── imageUrl: string?
│
├── vendors/
│   └── {vendorId}/
│       └── ... (see vendor_model.dart)
│
├── purchaseOrders/
│   └── {poId}/
│       └── ... (see purchase_order_model.dart)
│
├── goodsReceipts/
│   └── {grnId}/
│       └── ... (see goods_receipt_model.dart)
│
├── checklists/
│   └── {checklistId}/
│       └── ... (see checklist_model.dart)
│
├── incidents/
│   └── {incidentId}/
│       └── ... (see incident_model.dart)
│
├── attendance/
│   └── {userId}/
│       └── {date}/
│           ├── checkIn: timestamp
│           ├── checkOut: timestamp?
│           └── status: string
│
└── menuItems/
    └── {menuItemId}/
        └── ... (see menu_item_model.dart)
```

---

## 5. Free Tier Limits (Keep in Mind)

| Service | Free Tier Limit |
|---------|-----------------|
| **Realtime Database** | 1 GB storage, 10 GB/month download |
| **Authentication** | Unlimited users, 10K verifications/month |
| **Hosting** | 10 GB storage, 360 MB/day bandwidth |

### Optimization Tips:
1. Use `.indexOn` rules for frequently queried paths
2. Keep data shallow - avoid deep nesting
3. Use pagination for large lists
4. Compress images before upload
5. Cache data locally with `SharedPreferences`

---

## 6. Files Modified/Created

### New Files Created:
- `lib/core/models/` - Centralized models directory
- `lib/core/services/firebase_service.dart` - Firebase initialization
- `lib/core/services/auth_service.dart` - Firebase Auth service
- `lib/core/services/database_service.dart` - Realtime Database service
- `lib/core/services/migration_service.dart` - Data migration utilities

### Files Updated:
- `pubspec.yaml` - Updated Firebase dependencies
- `lib/main.dart` - Firebase initialization
- `lib/features/auth/logic/auth_cubit.dart` - Use Firebase Auth
- `web/index.html` - Firebase SDK scripts

---

## 7. Migration Strategy

When models change:
1. Update model in `lib/core/models/`
2. Add migration logic in `migration_service.dart`
3. Run migration on app startup (one-time migrations tracked by version)
4. Old data is transformed to new schema automatically

---

## 8. Quick Start Checklist

- [ ] Install Firebase CLI: `npm install -g firebase-tools`
- [ ] Login: `firebase login`
- [ ] Create Firebase project in Console
- [ ] Install FlutterFire: `dart pub global activate flutterfire_cli`
- [ ] Configure: `flutterfire configure --project=YOUR_PROJECT_ID`
- [ ] Enable Email/Password auth in Console
- [ ] Create Realtime Database in Console
- [ ] Run: `flutter pub get`
- [ ] Test locally: `flutter run -d chrome`
- [ ] Init hosting: `firebase init hosting`
- [ ] Build: `flutter build web --release`
- [ ] Deploy: `firebase deploy --only hosting`

---
