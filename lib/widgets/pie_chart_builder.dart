import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';

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
                centerSpaceRadius: widget.isTop3 ? 25 : 50,
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
                      radius: widget.isTop3 ? 60 : 110,
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
                  // if (!widget.isTop3)
                  //   Row(
                  //     children:
                  //         top3Percentages.entries.map((entry) {
                  //           final colorIndex =
                  //               top3Percentages.keys.toList().indexOf(
                  //                 entry.key,
                  //               ) %
                  //               Colors.primaries.length;

                  //           return Padding(
                  //             padding: const EdgeInsets.symmetric(
                  //               horizontal: 8.0,
                  //             ),
                  //             child: Row(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //                 Container(
                  //                   width: 14, // bigger
                  //                   height: 14,
                  //                   decoration: BoxDecoration(
                  //                     shape: BoxShape.circle,
                  //                     color:
                  //                         widget.isTop3
                  //                             ? Colors.primaries[(colorIndex +
                  //                                     9) %
                  //                                 Colors.primaries.length]
                  //                             : Colors.primaries[colorIndex],
                  //                   ),
                  //                 ),
                  //                 const SizedBox(width: 8),
                  //                 Text(
                  //                   entry.key.length > 20
                  //                       ? '${entry.key.substring(0, 20)}..'
                  //                       : entry.key,
                  //                   style: const TextStyle(
                  //                     fontSize: 12, // bigger font
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //                 const SizedBox(width: 12),
                  //               ],
                  //             ),
                  //           );
                  //         }).toList(),
                  //   ),
                ],
              ),
            ),
            widget.isTop3
                ? Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, right: 5),
                        child: _buildOutlinedButton(
                          label: "Map View",
                          onTap: () {
                            Navigator.pushNamed(context, "/map-view");
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, right: 14),
                        child: _buildOutlinedButton(
                          label: "Detailed View",
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder:
                            //         (context) => DetailedViewScreen(
                            //           currentEvent: widget.eventData,
                            //         ),
                            //   ),
                            // );
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

  Widget _buildOutlinedButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 75,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: primaryColor, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: primaryColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
