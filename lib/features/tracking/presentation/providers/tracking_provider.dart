import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tracking_state.dart';

final trackingProvider = NotifierProvider<TrackingNotifier, TrackingState>(TrackingNotifier.new);

class TrackingNotifier extends Notifier<TrackingState> {
  @override
  TrackingState build() {
    _startSimulation();
    return const TrackingState(
      status: TrackingStatus.confirmed,
      providerName: 'Asif Khan',
      providerImage: 'https://i.pravatar.cc/150?u=asif',
      estimatedArrivalTime: '12:45 PM',
      progress: 0.2,
    );
  }

  void _startSimulation() {
    // Simulate progression over time
    Timer(const Duration(seconds: 5), () {
      state = state.copyWith(
        status: TrackingStatus.enRoute,
        progress: 0.4,
        estimatedArrivalTime: '12:40 PM',
      );
    });

    Timer(const Duration(seconds: 12), () {
      state = state.copyWith(
        status: TrackingStatus.arrived,
        progress: 0.6,
      );
    });

    Timer(const Duration(seconds: 20), () {
      state = state.copyWith(
        status: TrackingStatus.working,
        progress: 0.8,
      );
    });

    Timer(const Duration(seconds: 30), () {
      state = state.copyWith(
        status: TrackingStatus.completed,
        progress: 1.0,
      );
    });
  }
}
