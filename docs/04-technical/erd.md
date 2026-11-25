---
title: Entity Relationship and Data Model
document_id: SRS-003
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
last_updated: 2026-11-25
related_documents:
- architecture.md
- ../02-product/product-requirements.md
---

# Entity Relationship and Data Model

MVP tidak memakai database server. ERD ini mendokumentasikan objek lokal, request, dan response agar boundary data tetap jelas.

```mermaid
erDiagram
    API_CREDENTIAL ||--o| CALCULATION_REQUEST : authorizes
    CALCULATION_REQUEST ||--o{ SHIPPING_OPTION : returns
    LOCATION_REFERENCE ||--o{ CALCULATION_REQUEST : origin
    LOCATION_REFERENCE ||--o{ CALCULATION_REQUEST : destination
    API_CREDENTIAL {
      string id PK
      string provider
      string secret_value
      datetime updated_at
    }
    LOCATION_REFERENCE {
      int provider_id PK
      string name
      string hierarchy_label
      string type
    }
    CALCULATION_REQUEST {
      string id PK
      int origin_id FK
      int destination_id FK
      int weight_grams
      string courier_code
      datetime requested_at
    }
    SHIPPING_OPTION {
      string id PK
      string calculation_id FK
      string courier_name
      string service
      int cost
      string etd
      boolean is_cheapest
    }
```

`API_CREDENTIAL` berada di secure storage. Objek lain bersifat runtime. Riwayat permanen bukan bagian MVP.

