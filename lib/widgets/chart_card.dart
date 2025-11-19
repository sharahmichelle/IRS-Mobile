// widgets/graphs_screen/chart_card.dart
import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';
import 'package:upm_drrm_irs_mobile/widgets/bar_graph_builder.dart';
import 'package:upm_drrm_irs_mobile/widgets/pie_chart_builder.dart';

class ChartCard extends StatelessWidget {
  final Event currentEvent;
  final EventTotal currentEventTotal;
  final Color surfaceColor;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color Function(String) getStatusColor;
  final String chartType;

  const ChartCard({
    super.key,
    required this.currentEvent,
    required this.currentEventTotal,
    required this.surfaceColor,
    required this.primaryColor,
    required this.backgroundColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.getStatusColor,
    required this.chartType,
  });

  @override
  Widget build(BuildContext context) {
    final responseRate = currentEventTotal.expectedData > 0
        ? (currentEventTotal.receivedData /
              currentEventTotal.expectedData *
              100)
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.pie_chart_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${currentEvent.category} Distribution",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${currentEvent.name} - ${currentEvent.timeStampStart.year}",
                        style: TextStyle(fontSize: 12, color: textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(currentEvent.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: getStatusColor(currentEvent.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currentEvent.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: getStatusColor(currentEvent.status),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: Color(0xFFE2E8F0)),

          // Chart Area
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              padding: const EdgeInsets.all(8),
              child: currentEventTotal.receivedData > 0
                  ? chartType == 'Demographics'
                        ? PieChartBuilder(
                            key: ValueKey('pie_chart_${currentEvent.eventId}'),
                            eventTotalData: currentEventTotal,
                            eventData: currentEvent,
                            isTop3: true,
                          )
                        : BarGraphBuilder(
                            key: ValueKey('bar_graph_${currentEvent.eventId}'),
                            eventData: currentEvent,
                            eventTotal: currentEventTotal,
                            isTop3: true,
                          )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          size: 60,
                          color: textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No Data Available",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Data will be available after the event",
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
            ),
          ),

          // Chart Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFooterItem(
                  "Participants",
                  "${currentEventTotal.receivedData}",
                ),
                _buildFooterItem(
                  "Response",
                  "${responseRate.toStringAsFixed(1)}%",
                ),
                _buildFooterItem("Category", currentEvent.category),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
