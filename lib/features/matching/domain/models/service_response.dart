/// Parses time strings like "13:00", "3:00 PM", or full ISO 8601 into a DateTime.
/// Returns null if parsing fails.
DateTime? parseFlexibleTime(String? timeStr) {
  if (timeStr == null || timeStr.isEmpty) return null;

  // Try full ISO 8601 first (e.g. "2026-05-21T13:00:00")
  try {
    return DateTime.parse(timeStr);
  } catch (_) {}

  // Try "HH:mm" or "H:mm" format (e.g. "13:00", "9:30")
  final hhmm = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(timeStr);
  if (hhmm != null) {
    final h = int.parse(hhmm.group(1)!);
    final m = int.parse(hhmm.group(2)!);
    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, h, m);
    // If the time has already passed today, schedule for tomorrow
    if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
    return dt;
  }

  // Try "h:mm AM/PM" format (e.g. "3:00 PM", "11:30 AM")
  final ampm = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false).firstMatch(timeStr);
  if (ampm != null) {
    var h = int.parse(ampm.group(1)!);
    final m = int.parse(ampm.group(2)!);
    final period = ampm.group(3)!.toUpperCase();

    if (period == 'PM' && h < 12) h += 12;
    if (period == 'AM' && h == 12) h = 0;

    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, h, m);
    if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
    return dt;
  }

  return null;
}

class ServiceResponse {
  final bool success;
  final int count;
  final List<ServiceProvider> providers;
  final ServiceIntent intent;
  final bool hasConflict;
  final String? originalPreferredTime;

  ServiceResponse({
    required this.success,
    required this.count,
    required this.providers,
    required this.intent,
    this.hasConflict = false,
    this.originalPreferredTime,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      providers: (json['providers'] as List?)
              ?.map((e) => ServiceProvider.fromJson(e))
              .toList() ??
          [],
      intent: ServiceIntent.fromJson(json['intent'] ?? {}),
      hasConflict: false,
      originalPreferredTime: null,
    );
  }
}

class ServiceProvider {
  final String id;
  final String name;
  final String serviceType;
  final List<String> factorsUsed;
  final double rating;
  final int reviews;
  final String phone;
  final String? whatsappTextLink;
  final String address;
  final Pricing pricing;
  final double lat;
  final double lng;
  final String? mapsUrl;
  final String? website;
  final String? reasonForChosen;
  final String? distanceAway;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.factorsUsed,
    required this.rating,
    required this.reviews,
    required this.phone,
    this.whatsappTextLink,
    required this.address,
    required this.pricing,
    required this.lat,
    required this.lng,
    this.mapsUrl,
    this.website,
    this.reasonForChosen,
    this.distanceAway,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    String? reason;
    if (json['reason_for_chosen'] is Map) {
      reason = json['reason_for_chosen']['text'];
    } else if (json['reason_for_chosen'] is String) {
      reason = json['reason_for_chosen'];
    }

    return ServiceProvider(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Provider',
      serviceType: json['service_type'] ?? 'service',
      factorsUsed: (json['factors_used'] as List?)?.map((e) => e as String).toList() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] ?? 0,
      phone: json['phone'] ?? '',
      whatsappTextLink: json['whatsapptextlink'],
      address: json['address'] ?? '',
      pricing: Pricing.fromJson(json['pricing'] ?? {}),
      lat: (json['location']?['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['location']?['lng'] as num?)?.toDouble() ?? 0.0,
      mapsUrl: json['maps_url'],
      website: json['website'],
      reasonForChosen: reason,
      distanceAway: json['distance_away'],
    );
  }
}

class Pricing {
  final double basePrice;
  final double distanceCost;
  final double urgencyCost;
  final double finalPrice;
  final String explanation;

  Pricing({
    required this.basePrice,
    required this.distanceCost,
    required this.urgencyCost,
    required this.finalPrice,
    required this.explanation,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      distanceCost: (json['distance_cost'] as num?)?.toDouble() ?? 0.0,
      urgencyCost: (json['urgency'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['final_price'] as num?)?.toDouble() ?? 0.0,
      explanation: json['explaination'] ?? '',
    );
  }
}

class ServiceIntent {
  final String service;
  final String googlePlaceType;
  final String urgency;
  final double urgencyMultiplier;
  final double confidence;
  final String? preferredTime;
  final String? notes;

  ServiceIntent({
    required this.service,
    required this.googlePlaceType,
    required this.urgency,
    required this.urgencyMultiplier,
    required this.confidence,
    this.preferredTime,
    this.notes,
  });

  factory ServiceIntent.fromJson(Map<String, dynamic> json) {
    return ServiceIntent(
      service: json['service'] ?? '',
      googlePlaceType: json['google_place_type'] ?? '',
      urgency: json['urgency'] ?? 'normal',
      urgencyMultiplier: (json['urgency_multiplier'] as num?)?.toDouble() ?? 1.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      preferredTime: json['preferred_time'],
      notes: json['notes'],
    );
  }
}
