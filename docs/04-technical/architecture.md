---
title: Technical Requirements and Architecture
document_id: SRS-001
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
last_updated: 2026-11-25
related_documents:
- api-specification.md
- erd.md
- ../03-design/design-system.md
---

# Architecture

```text
Flutter UI
  ↓
Feature controller or view model
  ↓
Repository
  ↓
RajaOngkir API service
  ↓
HTTPS RajaOngkir
```

Suggested structure:

```text
lib/
├── app/                 # app and router
├── core/                # config, errors, theme, utils
├── data/                # models, services, repositories
└── features/            # api_setup, location_search, calculator, result
```

Controller memvalidasi input. Repository meminta data. Service menambahkan header key, mengirim request, memetakan JSON dan status HTTP. UI hanya merender state.

Dependency awal adalah `http`, `flutter_secure_storage`, `intl`, `flutter_lints`, dan `flutter_test`. Versi dikunci setelah proyek dibuat.

MVP menggunakan API key runtime dalam secure storage. `.env.example` hanya berisi nama variabel atau base URL tanpa secret. Production publik membutuhkan backend proxy sebagai perubahan scope.

