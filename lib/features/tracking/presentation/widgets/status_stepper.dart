import 'package:flutter/material.dart';
import '../providers/tracking_state.dart';

class StatusStepper extends StatelessWidget {
  final TrackingStatus currentStatus;

  const StatusStepper({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStep(
          context,
          'Booking Confirmed',
          'Service provider has accepted your request',
          TrackingStatus.confirmed,
          isFirst: true,
        ),
        _buildStep(
          context,
          'En Route',
          'Provider is on the way to your location',
          TrackingStatus.enRoute,
        ),
        _buildStep(
          context,
          'Arrived',
          'Provider has reached the destination',
          TrackingStatus.arrived,
        ),
        _buildStep(
          context,
          'Working',
          'Service is currently in progress',
          TrackingStatus.working,
        ),
        _buildStep(
          context,
          'Completed',
          'Service has been finished successfully',
          TrackingStatus.completed,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildStep(
    BuildContext context,
    String title,
    String subtitle,
    TrackingStatus stepStatus, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final bool isCompleted = _isCompleted(stepStatus);
    final bool isActive = currentStatus == stepStatus;
    final Color color = isCompleted || isActive ? Theme.of(context).primaryColor : Colors.grey.shade300;

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _isCompleted(stepStatus) ? Theme.of(context).primaryColor : Colors.grey.shade300,
                    ),
                  ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: 2,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : isActive
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _isNextCompleted(stepStatus) ? Theme.of(context).primaryColor : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: isFirst ? 0 : 8,
                bottom: isLast ? 0 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isCompleted(TrackingStatus step) {
    return currentStatus.index > step.index;
  }

  bool _isNextCompleted(TrackingStatus step) {
    return currentStatus.index > step.index;
  }
}
