# Play Console handoff

When a friend with a Google Play Console account publishes Calora:

1. Create app listing: name **Calora**, category Health & Fitness.
2. Generate upload keystore (keep offline backup):

```bash
keytool -genkey -v -keystore calora-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias calora
```

3. Configure `android/key.properties` (gitignored) and signing in `android/app/build.gradle.kts`.
4. Build: `flutter build appbundle --release --dart-define=API_BASE_URL=https://...`
5. Attach privacy policy URL (use `docs/PRIVACY.md` hosted anywhere).
6. Declare Health Connect / activity recognition / camera permissions with in-app rationale.
