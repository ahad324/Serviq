import 'package:flutter/foundation.dart';

enum TrackingStatus {
  confirmed,
  enRoute,
  arrived,
  working,
  completed,
}

@immutable
class TrackingState {
  final TrackingStatus status;
  final String providerName;
  final String providerImage;
  final String estimatedArrivalTime;
  final double progress; // 0.0 to 1.0

  const TrackingState({
    required this.status,
    required this.providerName,
    required this.providerImage,
    required this.estimatedArrivalTime,
    required this.progress,
  });

  TrackingState copyWith({
    TrackingStatus? status,
    String? providerName,
    String? providerImage,
    String? estimatedArrivalTime,
    double? progress,
  }) {
    return TrackingState(
      status: status ?? this.status,
      providerName: providerName ?? this.providerName,
      providerImage: providerImage ?? this.providerImage,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      progress: progress ?? this.progress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          providerName == other.providerName &&
          providerImage == other.providerImage &&
          estimatedArrivalTime == other.estimatedArrivalTime &&
          progress == other.progress;

  @override
  int get hashCode =>
      status.hashCode ^
      providerName.hashCode ^
      providerImage.hashCode ^
      estimatedArrivalTime.hashCode ^
      progress.hashCode;
}
