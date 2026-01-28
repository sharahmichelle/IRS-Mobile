import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';
import 'package:upm_drrm_irs_mobile/screens/add_report_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/detailed_view_screen.dart';

class PieChartBuilder extends StatefulWidget {
  final Event eventData;
  final EventTotal eventTotalData;
  final bool isTop3;
  const PieChartBuilder({
    super.key,
    required this.eventTotalData,
    required this.eventData,
    required this.isTop3,
  });

  @override
  State<PieChartBuilder> createState() => _PieChartBuilderState();
}

class _PieChartBuilderState extends State<PieChartBuilder> {
  Map<String, int> demographics = {};
  Map<String, double> top3Percentages = {};
  int totalCount = 0;
  bool _isLoading = true;
  final Color primaryColor = Color.fromARGB(255, 161, 29, 28);

  void _processData() {
    setState(() => _isLoading = true);

    demographics.clear();
    totalCount = 0;
    demographics['Faculty'] = widget.eventTotalData.totalFaculty;
    demographics['Students'] = widget.eventTotalData.totalStudents;
    demographics['Admin Members'] = widget.eventTotalData.totalAdminMembers;
    demographics['Reps Members'] = widget.eventTotalData.totalRepsMembers;
    demographics['Custodians'] = widget.eventTotalData.totalCustodians;
    demographics['JoCos Members'] = widget.eventTotalData.totalJoCosMembers;
    demographics['Security'] = widget.eventTotalData.totalSecurity;
    demographics['Construction Workers'] =
        widget.eventTotalData.totalConstructionWorkers;
    demographics['Health Workers'] = widget.eventTotalData.totalHealthWorkers;
    demographics['Guests'] = widget.eventTotalData.totalGuests;
    demographics['Patients'] = widget.eventTotalData.totalPatients;
    demographics['Missing Persons'] = widget.eventTotalData.totalMissingPersons;
    demographics['Casualties'] = widget.eventTotalData.totalCasualties;

    for (var value in demographics.values) {
      totalCount += value;
    }

    final sortedEntries = demographics.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top3Entries = widget.isTop3 ? sortedEntries.take(3) : sortedEntries;

    top3Percentages = {
      for (var e in top3Entries) e.key: (e.value / totalCount) * 100,
    };

    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    if (widget.eventTotalData.reportsId.isNotEmpty) {
      _processData();
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryColor, strokeWidth: 3),
              SizedBox(height: 12),
              Text(
                "Loading demographic data...",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.eventTotalData.receivedData == 0) {
      return const Center(child: Text("No reports available yet"));
    } else if (totalCount == 0) {
      return const Center(child: Text("No demographic data available"));
    }

    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 2,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: widget.isTop3 ? 20 : 50,
                sectionsSpace: 1,
                sections: [
                  for (var entry in top3Percentages.entries)
                    PieChartSectionData(
                      color:
                          Colors.primaries[top3Percentages.keys
                                  .toList()
                                  .indexOf(entry.key) %
                              Colors.primaries.length],
                      value: entry.value,
                      title: '${entry.value.toStringAsFixed(1)}%',
                      radius: widget.isTop3 ? 55 : 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isTop3)
                    for (var entry in top3Percentages.entries)
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Colors.primaries[top3Percentages.keys
                                          .toList()
                                          .indexOf(entry.key) %
                                      Colors.primaries.length],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            entry.key.length > 15
                                ? '${entry.key.substring(0, 15)}..'
                                : entry.key,
                            style: const TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                ],
              ),
            ),
            widget.isTop3
                ? Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, right: 8),
                        child: _buildActionButton(
                          label: "Add Report",
                          icon: Icons.add_rounded,
                          isPrimary: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddReportScreen(
                                      currentEvent: widget.eventData,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, right: 14),
                        child: _buildActionButton(
                          label: "Details",
                          icon: Icons.analytics_rounded,
                          isPrimary: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DetailedViewScreen(
                                      currentEvent: widget.eventData, currentEventTotal: widget.eventTotalData,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }

  // NEW BUTTON METHOD - Same as BarGraphBuilder
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 110, // Same smaller width
      height: 36, // Same smaller height
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? primaryColor : Colors.transparent,
          foregroundColor: isPrimary ? Colors.white : primaryColor,
          elevation: isPrimary ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Same smaller radius
            side: isPrimary 
                ? BorderSide.none
                : BorderSide(color: primaryColor.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Same smaller padding
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14), // Same smaller icon
            const SizedBox(width: 4), // Same smaller spacing
            Text(
              label,
              style: TextStyle(
                fontSize: 11, // Same smaller font
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}