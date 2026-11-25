---
title: Design System and UX Specification
document_id: UX-001
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
last_updated: 2026-11-25
related_documents:
- user-flows.md
- ui-state-matrix.md
- ../04-technical/architecture.md
---

# Design System

Ongkirin memakai visual logistik yang tenang dan fungsional. Fokus berada pada rute, berat, harga, dan tindakan berikutnya. Preview visual awal menampilkan home, loading, hasil, dan invalid API key.

## Tokens

| Token | Value | Usage |
|---|---|---|
| Navy 900 | `#0F172A` | header dan teks kuat |
| Teal 700 | `#0F766E` | primary action dan selected |
| Teal 500 | `#14B8A6` | progress dan ikon aktif |
| Amber 500 | `#F59E0B` | termurah dan perhatian |
| Coral 600 | `#DC2626` | error |
| Slate 500 | `#64748B` | teks sekunder |
| Slate 200 | `#E2E8F0` | border |
| Slate 50 | `#F8FAFC` | background |

Font utama Inter atau Plus Jakarta Sans. Display 28sp, heading 20sp, body 14–16sp, caption 12sp, harga 24sp. Basis spacing 8dp dengan nilai 8, 12, 16, 24, dan 32dp. Radius field 12dp, card 16dp, button 12dp.

Target sentuh minimal 44dp. Warna bukan satu-satunya penanda status. Field memiliki label, helper, error text, dan focus outline. Motion 180–240ms, singkat, dan tidak wajib untuk memahami status.

## Component guidelines

| Component | Variants | States |
|---|---|---|
| Primary button | filled, full width | default, pressed, disabled, loading |
| Location field | empty, selected | focused, disabled, error |
| Weight field | kg, gram | empty, valid, invalid |
| Courier selector | empty, selected | loading, empty, error |
| Result card | regular, cheapest | default, selected |
| Alert | info, warning, error | visible, dismissed |
| Empty state | no result, no tariff | action available |

Komponen UI menerima data dan callback. Komponen tidak memanggil HTTP service langsung.

