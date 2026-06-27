# hotel_manager

A comprehensive hotel and restaurant management system built with Flutter.

## Features

### Staff-Facing Modules
- **Authentication & Authorization**: Secure login with role-based access control
- **Dashboard**: Overview of key metrics and performance indicators
- **Order Management**: 
  - Order taking with table assignment
  - Kitchen Display System (KDS) for real-time order tracking
  - Order history and reporting
  - Course-based firing (starters, mains, desserts, drinks)
- **Table Management**: Table status tracking, occupancy management
- **Billing & Payments**: Multiple payment methods, split billing, payment tracking
- **Inventory Management**: Stock tracking, low stock alerts, purchase orders
- **Loyalty Program**: Customer points, rewards, tier-based benefits
- **Offers & Promotions**: Happy hour management, discount configurations
- **Event Management**: Hall bookings, event planning, billing
- **Staff Management**: Employee records, roles, attendance, performance
- **Room Management**: Hotel room bookings, housekeeping, maintenance
- **Attendance Tracking**: Staff check-in/out, leave management
- **Checklists & Audits**: Quality control, safety inspections
- **Incident Management**: Issue reporting and resolution tracking
- **Settings Configuration**: Menu items, taxes, payment methods, system preferences

### Customer-Facing Modules
- **QR Code Menu & Self-Ordering**: 
  - Customers can scan QR codes to access digital menus
  - Browse menu items by category with images and descriptions
  - Add items to cart with special instructions and course selection
  - Apply happy hour discounts automatically
  - Place orders directly to kitchen without waiter intervention
  - Order confirmation with order number and estimated preparation time
  - Table-specific ordering (when QR code is table-linked) or walk-in/takeaway options

## Architecture

The application follows Clean Architecture principles with:
- **Presentation Layer**: Flutter widgets, Cubits for state management
- **Domain Layer**: Business logic, use cases, repository interfaces
- **Data Layer**: Repositories, data sources, API integration

State management is implemented using the Bloc/Cubit pattern for predictable state transitions.

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Firebase project configured for authentication and Firestore

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase:
   - For Android: Place `google-services.json` in `android/app/`
   - For iOS: Place `GoogleService-Info.plist` in `ios/Runner/`
4. Run `flutter run` to start the application

### Firebase Setup
The application uses Firebase Firestore as the primary database. Ensure you have:
1. Created a Firebase project
2. Enabled Firestore Database
3. Configured authentication methods (email/password, phone)
4. Added your app to the Firebase project and downloaded config files

## Supported Platforms
- Android
- iOS
- Web (responsive design)

## Architecture Documentation
See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture overview.

## Testing
Run `flutter test` to execute the test suite.

## License
This project is proprietary software.
