class Booking {
  final String id;
  final String service;
  final Provider provider;
  final Scheduling scheduling;
  final Pricing pricing;
  final Lifecycle lifecycle;
  final DecisionReasoning decisionReasoning;
  final Meta meta;

  Booking({
    required this.id,
    required this.service,
    required this.provider,
    required this.scheduling,
    required this.pricing,
    required this.lifecycle,
    required this.decisionReasoning,
    required this.meta,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['booking_id'],
      service: json['service'],
      provider: Provider.fromJson(json['provider']),
      scheduling: Scheduling.fromJson(json['scheduling']),
      pricing: Pricing.fromJson(json['pricing']),
      lifecycle: Lifecycle.fromJson(json['lifecycle']),
      decisionReasoning: DecisionReasoning.fromJson(json['decision_reasoning']),
      meta: Meta.fromJson(json['meta']),
    );
  }
}

class Provider {
  final String id;
  final String name;
  final double rating;
  final double distanceKm;
  final double baseFees;

  Provider({
    required this.id,
    required this.name,
    required this.rating,
    required this.distanceKm,
    required this.baseFees,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'],
      name: json['name'],
      rating: (json['rating'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      baseFees: (json['basefees'] as num).toDouble(),
    );
  }
}

class Scheduling {
  final DateTime requested;
  final bool hadConflict;
  final String? alternativeOffered;

  Scheduling({
    required this.requested,
    required this.hadConflict,
    this.alternativeOffered,
  });

  factory Scheduling.fromJson(Map<String, dynamic> json) {
    return Scheduling(
      requested: DateTime.parse(json['requested']),
      hadConflict: json['had_conflict'],
      alternativeOffered: json['alternative_offered'],
    );
  }
}

class Pricing {
  final double grandTotal;
  final String currency;
  final List<PriceBreakdown> breakdown;

  Pricing({
    required this.grandTotal,
    required this.currency,
    required this.breakdown,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      grandTotal: (json['grand_total'] as num).toDouble(),
      currency: json['currency'],
      breakdown: (json['breakdown'] as List)
          .map((e) => PriceBreakdown.fromJson(e))
          .toList(),
    );
  }
}

class PriceBreakdown {
  final String label;
  final double amount;

  PriceBreakdown({
    required this.label,
    required this.amount,
  });

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) {
    return PriceBreakdown(
      label: json['label'],
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

class Lifecycle {
  final StageInfo confirmed;
  final StageInfo enRoute;
  final StageInfo arrival;
  final StageInfo inProgress;
  final StageInfo completion;
  final StageInfo feedback;

  Lifecycle({
    required this.confirmed,
    required this.enRoute,
    required this.arrival,
    required this.inProgress,
    required this.completion,
    required this.feedback,
  });

  factory Lifecycle.fromJson(Map<String, dynamic> json) {
    return Lifecycle(
      confirmed: StageInfo.fromJson(json['confirmed']),
      enRoute: StageInfo.fromJson(json['en_route']),
      arrival: StageInfo.fromJson(json['arrival']),
      inProgress: StageInfo.fromJson(json['in_progress']),
      completion: StageInfo.fromJson(json['completion']),
      feedback: StageInfo.fromJson(json['feedback']),
    );
  }
}

class StageInfo {
  final String stage;
  final String? message;
  final DateTime? at;
  final DateTime? eta;

  StageInfo({
    required this.stage,
    this.message,
    this.at,
    this.eta,
  });

  factory StageInfo.fromJson(Map<String, dynamic> json) {
    return StageInfo(
      stage: json['stage'],
      message: json['message'],
      at: json['at'] != null ? DateTime.parse(json['at']) : null,
      eta: json['eta'] != null ? DateTime.parse(json['eta']) : null,
    );
  }
}

class DecisionReasoning {
  final String selectedBecause;
  final List<Rejection> rejections;

  DecisionReasoning({
    required this.selectedBecause,
    required this.rejections,
  });

  factory DecisionReasoning.fromJson(Map<String, dynamic> json) {
    return DecisionReasoning(
      selectedBecause: json['selected_because'],
      rejections: (json['rejections'] as List)
          .map((e) => Rejection.fromJson(e))
          .toList(),
    );
  }
}

class Rejection {
  final String providerId;
  final String reason;

  Rejection({
    required this.providerId,
    required this.reason,
  });

  factory Rejection.fromJson(Map<String, dynamic> json) {
    return Rejection(
      providerId: json['provider_id'],
      reason: json['reason'],
    );
  }
}

class Meta {
  final double confidence;
  final DateTime processedAt;

  Meta({
    required this.confidence,
    required this.processedAt,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      confidence: (json['confidence'] as num).toDouble(),
      processedAt: DateTime.parse(json['processed_at']),
    );
  }
}
