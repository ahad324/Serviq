import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracking_state.freezed.dart';

enum TrackingStatus {
  confirmed,
  enRoute,
  arrived,
  working,
  completed,
}

@freezed
class TrackingState with _$TrackingState {
  const factory TrackingState({
    required TrackingStatus status,
    required String providerName,
    required String providerImage,
    required String estimatedArrivalTime,
    required double progress, // 0.0 to 1.0
  }) = _TrackingState;
}
