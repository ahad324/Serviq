# 🗂️ Backend API Integration Specification

## 📌 Endpoint Metadata
* **Base URL**: `https://n8n-production-b9127.up.railway.app/webhook`
* **Route**: `/service-request`
* **Protocol**: HTTPS / POST
* **Payload Format**: JSON (`application/json`)
* **Encoding**: UTF-8

---

## 📥 Request JSON Schema

The Flutter client submits NLP queries along with resolved user location coordinates to initiate provider matching:

```json
{
  "query": "i need a plumber in green town around 3am",
  "test": false,
  "latitude": 31.568490,
  "longitude": 74.291660
}
```

### Request Parameter Specifications

| Parameter | Data Type | Nullability | Description | Range / Example |
| :--- | :--- | :--- | :--- | :--- |
| `query` | `String` | Non-Nullable | Unstructured natural language request in English, Urdu, or Romanized hybrid. | `"Mujhe kal AC repair chahiye"` |
| `test` | `Boolean` | Non-Nullable | Runs in production mode when `false`. Test mock configurations trigger if set to `true`. | `false` |
| `latitude` | `Double` | Non-Nullable | Precise client-side GPS latitude coordinate captured via [LocationService](./lib/core/services/location_service.dart). | `31.568490` |
| `longitude`| `Double` | Non-Nullable | Precise client-side GPS longitude coordinate captured via [LocationService](./lib/core/services/location_service.dart). | `74.291660` |

---

## 📤 Response JSON Schema (`ServiceResponse`)

Upon successful processing of the Multi-Agent n8n pipeline, the webhook returns a comprehensive matching and billing payload:

```json
{
  "success": true,
  "count": 3,
  "providers": [
    {
      "id": "ChIJ4VYxkYX_GDkRE-A0i01urHs",
      "name": "Crown sanitary electric and hardware store Bahria Town Lahore",
      "service_type": "manufacturer",
      "rating": 4.8,
      "reviews": 109,
      "phone": "0306 4600689",
      "address": "239b commercial, Tulip Extension Tulip Block Sector C Bahria Town, Lahore, 53720, Pakistan",
      "location": {
        "lat": 31.368113499999996,
        "lng": 74.1869404
      },
      "maps_url": "https://maps.google.com/?cid=8911619041986404371",
      "website": null,
      "reason_for_chosen": {
        "text": "Complete one stop shop for house hold accessories and maintenance. Good variety of electrical sanitary and hardware range. Also available home decor and lighting range modern sanitary and kitchen equipment available. Highly recommended",
        "languageCode": "en"
      }
    },
    {
      "id": "ChIJudHcgsz_GDkRvoJWQF01XD4",
      "name": "Electrical Solutions",
      "service_type": "service",
      "rating": 4.9,
      "reviews": 115,
      "phone": "0314 7542749",
      "address": "Shop#7 Al fazal market AA Block, D Aa Block Sector D Bahria Town, Lahore, 53720, Pakistan",
      "location": {
        "lat": 31.3764568,
        "lng": 74.169971
      },
      "maps_url": "https://maps.google.com/?cid=4493525202836554430",
      "website": "https://eselectrician.com/",
      "reason_for_chosen": "One of the best electrician Service in Bahria Town, they came within 5 minutes and fixed My AC"
    }
  ],
  "intent": {
    "service": "plumbing",
    "google_place_type": "plumber",
    "urgency": "normal",
    "urgency_multiplier": 1.0,
    "confidence": 0.9,
    "preferred_time": null,
    "notes": null
  }
}
```

### Response Field Specifications

#### 1. Core Metadata
| Field | Data Type | Nullability | Description |
| :--- | :--- | :--- | :--- |
| `success` | `Boolean` | Non-Nullable | Indicates if matching was successfully resolved. |
| `count` | `Integer` | Non-Nullable | Total number of matched candidates returned. |
| `providers` | `List<Map>` | Non-Nullable | Candidates matched by the geographic scoring algorithms. |
| `intent` | `Map` | Non-Nullable | The resolved intent payload parsed by the Intent Agent. |

#### 2. Provider Object (`providers[i]`)
| Field | Data Type | Nullability | Description |
| :--- | :--- | :--- | :--- |
| `id` | `String` | Non-Nullable | Unique ID of the service provider (derived from Google Places cid). |
| `name` | `String` | Non-Nullable | Registered name of the provider. |
| `service_type`| `String` | Non-Nullable | Category tagging (e.g. manufacturer, service, electrician, plumber). |
| `rating` | `Double` | Non-Nullable | Historical star rating score (0.0 to 5.0). |
| `reviews` | `Integer` | Non-Nullable | Count of registered customer reviews. |
| `phone` | `String` | Non-Nullable | Phone contact string. |
| `address` | `String` | Non-Nullable | Full registered address details. |
| `location` | `Map` | Non-Nullable | Latitude (`lat`) and Longitude (`lng`) of the provider. |
| `maps_url` | `String` | Nullable | Clickable Google Maps citation link. |
| `website` | `String` | Nullable | Primary business website link. |
| `reason_for_chosen` | `String` or `Map` | Nullable | Highly custom AI reason explaining the recommendation. Resolved in Dart parsing to support both plain strings and map structures `{ "text": "..." }`. |

#### 3. Intent Object (`intent`)
| Field | Data Type | Nullability | Description |
| :--- | :--- | :--- | :--- |
| `service` | `String` | Non-Nullable | Primary parsed service domain. |
| `google_place_type`| `String` | Non-Nullable | Google Places API mapping tag. |
| `urgency` | `String` | Non-Nullable | Urgency assessment (normal, high, critical). |
| `urgency_multiplier`| `Double` | Non-Nullable | Billing surcharge multiplier based on urgency. |
| `confidence` | `Double` | Non-Nullable | LLM confidence rating on intent mapping (0.0 to 1.0). |
| `preferred_time` | `String` | Nullable | Extracted date/time parameters requested by user. |
| `notes` | `String` | Nullable | Extracted customer requirements (e.g. tool specs). |

---

## 🚨 Error Response Schemas

When the Multi-Agent pipeline experiences query exceptions or low confidence mappings, it returns standard HTTP error codes:

### 1. Low Confidence Error (HTTP 422 Unprocessable Entity)
* **Trigger**: The Intent Agent parses a query but the confidence is under `0.5`, or the request contains gibberish.
```json
{
  "success": false,
  "error": {
    "code": "LOW_CONFIDENCE",
    "message": "AI agents were unable to confidently extract service intent from your query. Please be more specific (e.g., 'I need a plumber to fix a leak').",
    "confidence": 0.23
  }
}
```

### 2. No Providers Found (HTTP 200 OK with empty provider pool)
* **Trigger**: Query resolved successfully, but no local experts match in Google Sheets within 30km.
```json
{
  "success": true,
  "count": 0,
  "providers": [],
  "intent": {
    "service": "plumbing",
    "google_place_type": "plumber",
    "urgency": "normal",
    "urgency_multiplier": 1.0,
    "confidence": 0.88,
    "preferred_time": null,
    "notes": null
  }
}
```
