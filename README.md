# Calora Mobile (Flutter · Android)

Peaceful AI calorie tracker for personal / portfolio use.

## Features

- Today diary with macro ring, meals, net calories
- Open Food Facts search + barcode scan
- AI text & photo meal parse (confirm before save)
- Health Connect steps + sensor fallback (source badge)
- Workouts (MET), water, weight, insights & streaks
- Themes: Sage Mist, Dawn Cream, Harbor Calm
- Offline Hive sync queue for diary entries

## Setup

1. Install Flutter 3.24+ and Android SDK.
2. Point the API base URL at your Fastify backend:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
# physical device: use your LAN IP, e.g. http://192.168.x.x:4000
```

3. Grant Health Connect / activity / camera permissions on first use.

## Release APK (friends / portfolio)

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR-API.up.railway.app
```

APK: `build/app/outputs/flutter-apk/app-release.apk`

For Play Console (friend’s account): `flutter build appbundle --release ...` and upload the AAB. Create a release keystore and keep it private — see `docs/PLAY_HANDOFF.md`.

## Architecture

Feature-first folders, Riverpod, go_router, Dio + secure token refresh, repository pattern.
