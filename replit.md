# Sheryan - Blood Donation App

## Overview
Sheryan is a cross-platform Flutter blood donation ecosystem connecting donors and recipients with hospital-assisted verification. It supports Arabic/English localization, role-based UI, and integrates with Firebase services.

## Tech Stack
- **Framework**: Flutter (Dart) - built as a web app
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging, Storage)
- **Cloud Functions**: Node.js (JavaScript) in `/functions/`
- **State Management**: Flutter Riverpod
- **Notifications**: OneSignal + flutter_local_notifications
- **Localization**: ARB files in `lib/l10n/`, supports Arabic & English

## Project Structure
- `lib/` - Main Flutter/Dart application code
  - `lib/main.dart` - App entry point, Firebase init
  - `lib/firebase_options.dart` - Firebase configuration (project: blood-f5990)
  - `lib/core/` - Theme, utils, enums
  - `lib/providers/` - Riverpod state providers (auth, locale, theme)
  - `lib/services/` - Firebase/auth/notification services
  - `lib/screens/` - UI screens by feature/role
  - `lib/l10n/` - Localization (ARB files + generated)
- `functions/` - Firebase Cloud Functions (Node.js)
- `web/` - Flutter web entry point (index.html)
- `build/web/` - Built web output (served in production)
- `android/`, `ios/`, `macos/`, `linux/`, `windows/` - Platform runners

## Running the App
The workflow script `run.sh` builds the Flutter web app and serves it on port 5000:
```bash
bash run.sh
```

## Build Notes
- SDK constraint set to `^3.8.0` to match Flutter 3.32.0 / Dart 3.8.0
- `flutter_local_notifications` pinned to `^20.1.0` for Dart 3.8.0 compatibility
- `shared_preferences` uses `^2.3.0` for Dart 3.8.0 compatibility
- Fixed `BottomAppBarThemeData` → `BottomAppBarTheme` for Flutter 3.32 API

## Roles
- `donor` — main blood donor experience with profile, points, rewards
- `recipient` (or `user`) — request blood, view donors
- `hospitalAdmin` — verify blood requests, register donations, verify blood groups via QR
- `superAdmin` — manage hospital admins, hospitals, cities, and sponsor organizations
- `sponsorOrg` — created by superAdmin; manages rewards; scans donor QR to redeem points

## Points & Rewards System
- **PointsService** (`lib/services/points_service.dart`): award/deduct points, tier calculation, milestone checks
- **Tiers**: Bronze (0–499), Silver (500–999), Gold (1000–1999), Platinum (2000+)
- **Firestore new collections**: `rewards/{id}`, `redemptions/{id}`, `users/{uid}/pointsHistory/{id}`
- **Donor UX**: Profile shows points card → RewardsScreen (Available Rewards + Points History tabs)
- **Sponsor UX**: SponsorDashboard with QR scanner to deduct points on reward redemption
- **SuperAdmin UX**: 4th tab in AdminDashboard to create/delete sponsor org accounts
- See `docs/points_rewards_sponsor.md` for full documentation

## Offline Mode
- Firestore offline persistence enabled in `main.dart` (unlimited cache size)
- `connectivity_plus: ^6.1.1` added for network detection
- `lib/providers/connectivity/connectivity_provider.dart` — Riverpod `NotifierProvider` watching network state
- `lib/widgets/offline_banner.dart` — animated banner shown on all screens when offline
- `lib/services/pending_actions_service.dart` — queues blood requests created while offline, auto-syncs on reconnect
- User profile, donors list, and donor profile all cached in `SharedPreferences`
- Create blood request screen queues requests offline and syncs when back online

## Deployment
- Type: Static site
- Build command: `flutter build web --release`
- Public dir: `build/web`
- Firebase project: `blood-f5990`
