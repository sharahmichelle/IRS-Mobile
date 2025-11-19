// widgets/graphs_screen/event_selector.dart
import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/widgets/navigation_button.dart';

class EventSelector extends StatelessWidget {
  final Event currentEvent;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color primaryColor;

  const EventSelector({
    super.key,
    required this.currentEvent,
    required this.onPrevious,
    required this.onNext,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Event Button
          NavigationButton(
            icon: Icons.chevron_left_rounded,
            onPressed: onPrevious,
            primaryColor: primaryColor,
          ),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentEvent.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${currentEvent.timeStampStart.day}/${currentEvent.timeStampStart.month}/${currentEvent.timeStampStart.year}',
                    style: TextStyle(
                      fontSize: 10,
                      color: textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          ),
          
          // Next Event Button
          NavigationButton(
            icon: Icons.chevron_right_rounded,
            onPressed: onNext,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }
}