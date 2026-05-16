class ServiceResponse {
  final bool success;
  final int count;
  final List<ServiceProvider> providers;
  final ServiceIntent intent;

  ServiceResponse({
    required this.success,
    required this.count,
    required this.providers,
    required this.intent,
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
    );
  }
}

class ServiceProvider {
  final String id;
  final String name;
  final String serviceType;
  final double rating;
  final int reviews;
  final String phone;
  final String address;
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
    required this.rating,
    required this.reviews,
    required this.phone,
    required this.address,
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
    } else if (json['reason_for_choosen'] is String) { // Handle typo in previous schema
      reason = json['reason_for_choosen'];
    }

    return ServiceProvider(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Provider',
      serviceType: json['service_type'] ?? 'service',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] ?? 0,
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      lat: (json['location']?['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['location']?['lng'] as num?)?.toDouble() ?? 0.0,
      mapsUrl: json['maps_url'],
      website: json['website'],
      reasonForChosen: reason,
      distanceAway: json['distance_away'],
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
