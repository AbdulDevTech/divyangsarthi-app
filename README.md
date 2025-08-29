# Divyangsarthi - Flutter app (initial scaffold)

This repository is an initial Flutter scaffold for the Divyangsarthi app (Android, iOS, Web).

Quick start
1. Copy .env.sample to .env and set API_BASE_URL or provide API_BASE_URL in your CI.
2. flutter pub get
3. flutter run -d <device>

Project structure highlights
- lib/src/screens: UI screens (splash, login, home).
- lib/src/shared: services, small providers and utilities.
- .github/workflows/ci.yml: basic CI for analysis and tests.

Notes
- Auth header used by the API client: x-access-token
- Tokens should be stored in flutter_secure_storage and refreshed via backend endpoints.
- Do NOT commit production secrets or keystores to the repo.
