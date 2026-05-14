import 'dart:convert';
import '../domain/models/booking_model.dart';

class MockData {
  static const String bookingJsonResponse = '''
{
    "success": true,
    "booking_id": "BK-1778757212545-AGJ3ZC",
    "service": "plumbing",
    "provider": {
        "id": "PRV001",
        "name": "Ali Repairs",
        "rating": 4.8,
        "distance_km": 2.1,
        "basefees": 500
    },
    "scheduling": {
        "requested": "2026-05-14T20:00:00.000Z",
        "had_conflict": false,
        "alternative_offered": null
    },
    "pricing": {
        "grand_total": 585,
        "currency": "PKR",
        "breakdown": [{
            "label": "Base service fee",
            "amount": 500
        }, {
            "label": "Distance cost",
            "amount": 42
        }, {
            "label": "Urgency (×1)",
            "amount": 0
        }, {
            "label": "Discount",
            "amount": 0
        }, {
            "label": "Platform fee (8%)",
            "amount": 43
        }]
    },
    "lifecycle": {
        "confirmed": {
            "stage": "confirmed",
            "at": "2026-05-14T11:13:33.762Z",
            "message": "Booking confirmed. Provider notified."
        },
        "en_route": {
            "stage": "en_route",
            "eta": "2026-05-14T11:43:33.762Z",
            "message": "Ali Repairs is on the way."
        },
        "arrival": {
            "stage": "arrival",
            "eta": "2026-05-14T11:58:33.762Z",
            "message": "Provider will arrive in ~45 min."
        },
        "in_progress": {
            "stage": "in_progress",
            "eta": "2026-05-14T12:13:33.762Z",
            "message": "Service in progress."
        },
        "completion": {
            "stage": "completion",
            "eta": "2026-05-14T13:13:33.762Z",
            "message": "Service completed."
        },
        "feedback": {
            "stage": "feedback",
            "eta": "2026-05-14T13:18:33.762Z",
            "message": "Please rate your experience."
        }
    },
    "decision_reasoning": {
        "selected_because": "Ali Repairs has the highest score (0.9275), the highest rating (4.8), and is the closest provider at 2.1 km, making them the most reliable choice for a same-day 20:00 appointment.",
        "rejections": [{
            "provider_id": "PRV003",
            "reason": "Lower rating (4.6) and higher distance (3.8 km) compared to PRV001, with a higher base fee of 550."
        }, {
            "provider_id": "PRV002",
            "reason": "Lower rating (4.2) and greatest distance (5.5 km) among the candidates, despite the lower base fee."
        }]
    },
    "meta": {
        "confidence": 0.95,
        "processed_at": "2026-05-14T11:13:33.765Z"
    }
}
''';

  static Booking get mockBooking => Booking.fromJson(jsonDecode(bookingJsonResponse));
}
