import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';

class BarGraphBuilder extends StatefulWidget {
  final Event eventData;
  final EventTotal eventTotal;
  final bool isTop3;
  const BarGraphBuilder({
    super.key,
    required this.eventData,
    required this.eventTotal,
    required this.isTop3,
  });

  @override
  State<BarGraphBuilder> createState() => _BarGraphBuilderState();
}

class _BarGraphBuilderState extends State<BarGraphBuilder> {
  Map<String, int> distribution = {};
  Map<String, int> top = {};
  bool _isLoading = true;
  final Color primaryColor = Color.fromARGB(255, 161, 29, 28);

  Future<void> _processData() async {
    setState(() => _isLoading = true);

    distribution.clear();
    distribution.addAll(widget.eventTotal.totalDistribution);

    final sortedEntries =
        distribution.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // Only take top 3 if isTop3 is true
    final topEntries = widget.isTop3 ? sortedEntries.take(3) : sortedEntries;
    top = {for (var e in topEntries) e.key: e.value};

    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    if (widget.eventTotal.reportsId.isNotEmpty) {
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
                "Loading report data...",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.eventTotal.receivedData == 0) {
      return const Center(child: Text("No reports available yet"));
    } else if (top.isEmpty) {
      return const Center(child: Text("No demographic data available"));
    }

    // Convert to list for asMap()
    final topEntriesList = top.entries.toList();

    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: BarChart(
                BarChartData(
                  maxY: (top.entries.first.value + top.entries.first.value * 0.2)
                      .round()
                      .toDouble(),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine:
                        (value) => FlLine(color: Colors.grey, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border.symmetric(
                      horizontal: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < topEntriesList.length) {
                            final entry = topEntriesList[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                entry.key.length > 12
                                    ? '${entry.key.substring(0, 10)}..'
                                    : entry.key,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  barGroups: topEntriesList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.value.toDouble(),
                          color: Colors.primaries[
                              index % Colors.primaries.length],
                          width: 20,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                duration: const Duration(milliseconds: 150),
                curve: Curves.linear,
              ),
            ),
          ),
        ),

        // Legend and buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Always show legend, but only show top 3 items when isTop3 is true
                  for (var entry in topEntriesList)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.primaries[
                                topEntriesList.indexWhere((e) => e.key == entry.key) %
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