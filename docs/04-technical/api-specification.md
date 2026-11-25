---
title: Third Party API and API Specification
document_id: SRS-002
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
last_updated: 2026-11-25
related_documents:
- architecture.md
- ../00-overview/brainstorm-and-decisions.md
- ../05-quality/acceptance-criteria.md
---

# RajaOngkir API

Implementasi mengikuti kontrak Shipping Cost RajaOngkir yang saat ini didokumentasikan pada `https://rajaongkir.komerce.id/api/v1`. Saat uji dengan akun pemilik project, status akses dan respons aktual tetap perlu diverifikasi.

## Location search

```text
GET /destination/domestic-destination?search={query}&limit={limit}&offset={offset}
Header: key: {API_KEY}
```

Adapter menyimpan provider ID dari hasil pencarian.

## Domestic cost

```text
POST /calculate/domestic-cost
Header: key: {API_KEY}
Header: Content-Type: application/x-www-form-urlencoded
Body: origin={originId}&destination={destinationId}&weight={weightInGram}&courier={courierCode}&price=lowest
```

## Response

```json
{
  "meta": {"message": "...", "code": 200, "status": "success"},
  "data": [{"name": "...", "code": "...", "service": "...", "description": "...", "cost": 0, "etd": "..."}]
}
```

| Status | App mapping |
|---|---|
| 200 | success atau empty |
| 400 | request invalid atau no service |
| 401 | key invalid atau missing |
| 404 | resource tidak ditemukan |
| 422 | courier atau parameter invalid |
| 500 | provider failure |
| timeout | network failure |

Contract aktual menggantikan contoh di atas sebelum implementasi.

