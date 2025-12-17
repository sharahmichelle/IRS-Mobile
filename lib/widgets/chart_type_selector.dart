// widgets/graphs_screen/chart_type_selector.dart
import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/widgets/navigation_button.dart';

class ChartTypeSelector extends StatelessWidget {
  final String currentChartType;
  final int currentEventIndex;
  final int totalEvents;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Color surfaceColor;
  final Color primaryColor;
  final Color textSecondary;

  const ChartTypeSelector({
    super.key,
    required this.currentChartType,
    required this.currentEventIndex,
    required this.totalEvents,
    required this.onPrevious,
    required this.onNext,
    required this.surfaceColor,
    required this.primaryColor,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
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
          // Previous Button
          NavigationButton(
            icon: Icons.chevron_left_rounded,
            onPressed: onPrevious,
            primaryColor: primaryColor,
          ),
          
          // Chart Type Label
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentChartType,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Incident ${currentEventIndex + 1} of $totalEvents',
                    style: TextStyle(
                      fontSize: 10,
                      color: textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          
          // Next Button
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