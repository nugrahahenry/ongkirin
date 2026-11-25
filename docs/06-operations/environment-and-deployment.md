---
title: Environment and Deployment
document_id: OPS-001
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
last_updated: 2026-11-25
related_documents:
- ../04-technical/architecture.md
- ../07-user-guides/getting-started.md
---

# Environment and Deployment

Development menjalankan `flutter pub get`, `flutter analyze`, `flutter test`, lalu `flutter run`. Android demo dapat dibuat dengan `flutter build apk --debug`.

`.env.example` boleh berisi base URL tanpa secret. API key dimasukkan melalui secure storage atau input runtime. File `.env`, fixture key, dan log rahasia masuk `.gitignore`.

Sebelum handover, pastikan contract API, key Shipping Cost, endpoint location search, endpoint domestic cost, dan courier demo sudah terkonfirmasi. Key aktual diberikan lewat kanal privat dan tidak dikirim melalui repository.

