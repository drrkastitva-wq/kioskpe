# Advocate Connect Download & Status

## Download the latest build

The Android APK/AAB is built through GitHub Actions.

1. Open the GitHub Actions page:
   https://github.com/drrkastitva-wq/kioskpe/actions/workflows/build-apk.yml
2. Click the newest successful run.
3. Under "Artifacts", download the file named:
   advocate-connect-release-artifacts
4. The artifact contains:
   - app-release.apk
   - app-release.aab

If you want to test the web version locally, the current build output is in:
- apps/mobile/build/web

## Current status

### Mobile app
- Branding update: ✅ Completed
- Flutter widget test: ✅ Passed
- Web release build: ✅ Passed
- Android APK/AAB build: ⚠️ Requires the GitHub runner and Android SDK; workflow is configured and ready

### Backend API
- TypeScript build: ⚠️ Not fully passing
- Errors found:
  - missing route file import in src/index.ts
  - strict type error in src/routes/calendar.ts

## Verified commands

These were checked successfully in the current workspace:

- cd /workspaces/kioskpe/apps/mobile && /tmp/flutter/bin/flutter test test/widget_test.dart
- cd /workspaces/kioskpe/apps/mobile && /tmp/flutter/bin/flutter build web --release

This backend build still fails in the current repo state:

- cd /workspaces/kioskpe/apps/backend && npm install && npm run build

## Known blockers before final production release

- Fix the missing library route import in the backend entry point.
- Fix the date typing issue in the calendar route.
- If you want a direct Android release from this environment, install Android SDK and run the Android build locally or on GitHub.

## App name

Advocate Connect
