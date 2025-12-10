import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';
import 'package:upm_drrm_irs_mobile/providers/reports_provider.dart';
import 'package:upm_drrm_irs_mobile/widgets/bar_graph_builder.dart';
import 'package:upm_drrm_irs_mobile/widgets/pie_chart_builder.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DetailedViewScreen extends StatefulWidget {
  final Event currentEvent;
  final EventTotal currentEventTotal;
  
  const DetailedViewScreen({
    super.key, 
    required this.currentEvent, 
    required this.currentEventTotal,
  });

  @override
  State<DetailedViewScreen> createState() => _DetailedViewScreenState();
}

class _DetailedViewScreenState extends State<DetailedViewScreen> {
  // Modern color scheme matching GraphsScreen
  final Color primaryColor = Color(0xFFA11D1C);
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = Color(0xFF1E293B);
  final Color textSecondary = Color(0xFF64748B);
  final Color accentColor = Color(0xFF0EA5E9);
  
  bool isDemographics = true;
  bool isLoadingReports = true;
  late ReportsDataSource _reportsDataSource;
  final ScrollController _scrollController = ScrollController();
  List<Report> _reports = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
    });
  }

  Future<void> _loadReports() async {
    try {
      final reportsProvider = Provider.of<Reports>(context, listen: false);
      List<Report> loadedReports = [];
      
      // Fetch each report by ID
      for (String reportId in widget.currentEventTotal.reportsId) {
        try {
          Report report = await reportsProvider.getReportById(reportId);
          loadedReports.add(report);
        } catch (e) {
          debugPrint('Error loading report $reportId: $e');
        }
      }
      
      setState(() {
        _reports = loadedReports;
        _reportsDataSource = ReportsDataSource(_reports);
        isLoadingReports = false;
      });
    } catch (e) {
      debugPrint('Error loading reports: $e');
      setState(() {
        isLoadingReports = false;
      });
    }
  }

  SvgPicture? selectIcon(String type) {
    final icons = {
      "earthquake": 'assets/earthquake.svg',
      "fire": 'assets/fire.svg',
      "flood": 'assets/flood.svg',
      "tsunami": 'assets/tsunami.svg',
    };
    return icons[type] != null
        ? SvgPicture.asset(icons[type]!, width: 30, height: 30)
        : null;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'ongoing':
        return Colors.orange;
      case 'upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Helper method to calculate total head count from a report
  int _calculateTotalHeadCount(Report report) {
    return report.headCountFaculty +
           report.headCountadminMember +
           report.headCountRepsMember +
           report.headCountCustodian +
           report.headCountJoCosMember +
           report.headCountStudent +
           report.headCountSecurity +
           report.headCountConstructionWorker +
           report.headCountHealthWorker +
           report.headCountGuest +
           report.headCountPatient;
  }

  // Helper method to format office name
  String _formatOfficeName(String office) {
    if (office.length > 25) {
      return '${office.substring(0, 22)}...';
    }
    return office;
  }

  // Helper method to format location name
  String _formatLocation(String location) {
    if (location.length > 30) {
      return '${location.substring(0, 27)}...';
    }
    return location;
  }

  // Helper method to calculate totals from all reports
  Map<String, int> _calculateTotals() {
    int totalHeadCount = 0;
    int totalMissing = 0;
    int totalCasualties = 0;
    
    for (var report in _reports) {
      totalHeadCount += _calculateTotalHeadCount(report);
      totalMissing += report.numMissingPerson;
      totalCasualties += report.numCasualty;
    }

    return {
      'totalHeadCount': totalHeadCount,
      'totalMissing': totalMissing,
      'totalCasualties': totalCasualties,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header with back button
            _buildHeader(),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16), // Reduced from 20
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Title and Status Card
                      _buildEventHeader(),
                      const SizedBox(height: 16), // Reduced from 20

                      // Event Details Grid - Fixed overflow
                      _buildEventDetailsGrid(totals),
                      const SizedBox(height: 20), // Reduced from 24

                      // Chart Type Selector
                      _buildChartTypeSelector(),
                      const SizedBox(height: 16), // Reduced from 20

                      // Chart Card
                      _buildChartCard(),
                      const SizedBox(height: 20), // Reduced from 24

                      // Reports Section
                      _buildReportsSection(),
                      const SizedBox(height: 24), // Reduced from 32
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Reduced
      decoration: BoxDecoration(
        color: surfaceColor,
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
          // Back Button
          Container(
            width: 40, // Reduced from 44
            height: 40, // Reduced from 44
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10), // Reduced from 12
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18), // Reduced
              color: textPrimary,
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 12), // Reduced from 16
          
          // Header Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Event Details",
                  style: TextStyle(
                    fontSize: 17, // Reduced from 18
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Complete overview and analytics",
                  style: TextStyle(
                    fontSize: 11, // Reduced from 12
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced
            decoration: BoxDecoration(
              color: _getStatusColor(widget.currentEvent.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16), // Reduced from 20
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7, // Reduced from 8
                  height: 7, // Reduced from 8
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.currentEvent.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5), // Reduced from 6
                Text(
                  widget.currentEvent.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10, // Reduced from 11
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(widget.currentEvent.status),
                    letterSpacing: 0.3, // Reduced from 0.5
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventHeader() {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16), // Reduced from 20
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12, // Reduced from 16
            offset: Offset(0, 3), // Reduced from 4
          ),
        ],
      ),
      child: Row(
        children: [
          // Event Icon
          Container(
            width: 52, // Reduced from 60
            height: 52, // Reduced from 60
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14), // Reduced from 16
            ),
            child: Center(
              child: selectIcon("fire") ?? Icon(
                Icons.event_rounded,
                color: primaryColor,
                size: 24, // Reduced from 28
              ),
            ),
          ),
          const SizedBox(width: 14), // Reduced from 16
          
          // Event Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.currentEvent.eventName,
                  style: TextStyle(
                    fontSize: 18, // Reduced from 20
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5), // Reduced from 6
                Wrap(
                  spacing: 6, // Reduced from 8
                  runSpacing: 5, // Reduced from 6
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13, // Reduced from 14
                          color: textSecondary,
                        ),
                        const SizedBox(width: 5), // Reduced from 6
                        Text(
                          "${widget.currentEvent.timeStampStart.day}/${widget.currentEvent.timeStampStart.month}/${widget.currentEvent.timeStampStart.year}",
                          style: TextStyle(
                            fontSize: 12, // Reduced from 13
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 13, // Reduced from 14
                          color: textSecondary,
                        ),
                        const SizedBox(width: 5), // Reduced from 6
                        Text(
                          "${widget.currentEvent.timeStampStart.hour.toString().padLeft(2, '0')}:${widget.currentEvent.timeStampStart.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            fontSize: 12, // Reduced from 13
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsGrid(Map<String, int> totals) {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16), // Reduced from 20
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12, // Reduced from 16
            offset: Offset(0, 3), // Reduced from 4
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                width: 36, // Reduced from 40
                height: 36, // Reduced from 40
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9), // Reduced from 10
                ),
                child: Center(
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: accentColor,
                    size: 18, // Reduced from 20
                  ),
                ),
              ),
              const SizedBox(width: 10), // Reduced from 12
              Text(
                "Event Information",
                style: TextStyle(
                  fontSize: 15, // Reduced from 16
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Reduced from 20

          // Details Grid - Adjusted sizes to prevent overflow
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12, // Reduced from 16
            mainAxisSpacing: 12, // Reduced from 16
            childAspectRatio: 1.1, // Reduced from 1.2 (more compact)
            children: [
              // Row 1
              _buildDetailItem(
                icon: Icons.location_on_rounded,
                label: "Location",
                value: _formatLocation(widget.currentEvent.location),
                color: Colors.blue,
              ),
              _buildDetailItem(
                icon: Icons.people_rounded,
                label: "Total Reports",
                value: "${widget.currentEventTotal.reportsId.length}",
                color: Colors.purple,
              ),
              
              // Row 2
              _buildDetailItem(
                icon: Icons.category_rounded,
                label: "Category",
                value: widget.currentEvent.category,
                color: Colors.green,
              ),
              _buildDetailItem(
                icon: Icons.person_outline_rounded,
                label: "Total People",
                value: "${totals['totalHeadCount']}",
                color: Colors.orange,
              ),
              
              // Row 3
              _buildDetailItem(
                icon: Icons.person_search_rounded,
                label: "Missing Persons",
                value: "${totals['totalMissing']}",
                color: Colors.red,
              ),
              _buildDetailItem(
                icon: Icons.medical_services_rounded,
                label: "Casualties",
                value: "${totals['totalCasualties']}",
                color: Color(0xFFA11D1C),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10), // Reduced from 12
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced from 16
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 40, // Reduced from 48
              height: 40, // Reduced from 48
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10), // Reduced from 12
              ),
              child: Center(
                child: Icon(icon, size: 20, color: color), // Reduced from 24
              ),
            ),
            const SizedBox(height: 8), // Reduced from 12
            
            // Label
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10, // Reduced from 11
                color: textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3, // Reduced from 0.5
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4), // Reduced from 6
            
            // Value
            Text(
              value,
              style: TextStyle(
                fontSize: 20, // Reduced from 20
                color: textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3, // Reduced from -0.5
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6), // Reduced from 8
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14), // Reduced from 16
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6, // Reduced from 8
            offset: Offset(0, 1), // Reduced from 2
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          IconButton(
            onPressed: () {
              setState(() {
                isDemographics = !isDemographics;
              });
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: 16, // Reduced from 18
              color: primaryColor,
            ),
            splashRadius: 18, // Reduced from 20
            padding: EdgeInsets.zero,
          ),
          
          // Spacer
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // Reduced
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10), // Reduced from 12
                ),
                child: Text(
                  isDemographics ? "DEMOGRAPHICS" : "DISTRIBUTION",
                  style: TextStyle(
                    fontSize: 12, // Reduced from 14
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    letterSpacing: 0.3, // Reduced from 0.5
                  ),
                ),
              ),
            ),
          ),
          
          // Next Button
          IconButton(
            onPressed: () {
              setState(() {
                isDemographics = !isDemographics;
              });
            },
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16, // Reduced from 18
              color: primaryColor,
            ),
            splashRadius: 18, // Reduced from 20
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16), // Reduced from 20
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12, // Reduced from 16
            offset: Offset(0, 3), // Reduced from 4
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Header
          Row(
            children: [
              Container(
                width: 36, // Reduced from 40
                height: 36, // Reduced from 40
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9), // Reduced from 10
                ),
                child: Center(
                  child: Icon(
                    isDemographics ? Icons.pie_chart_rounded : Icons.bar_chart_rounded,
                    color: primaryColor,
                    size: 18, // Reduced from 20
                  ),
                ),
              ),
              const SizedBox(width: 10), // Reduced from 12
              Expanded(
                child: Text(
                  isDemographics ? "Participant Demographics" : "Report Distribution",
                  style: TextStyle(
                    fontSize: 15, // Reduced from 16
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Reduced from 20

          // Chart
          Container(
            height: 310, // Reduced from 300
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10), // Reduced from 12
            ),
            child: isDemographics
                ? PieChartBuilder(
                    eventData: widget.currentEvent,
                    isTop3: false, 
                    eventTotalData: widget.currentEventTotal,
                  )
                : BarGraphBuilder(
                    eventData: widget.currentEvent,
                    isTop3: false, 
                    eventTotal: widget.currentEventTotal,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsSection() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16), // Reduced from 20
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12, // Reduced from 16
            offset: Offset(0, 3), // Reduced from 4
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(16), // Reduced from 20
            child: Row(
              children: [
                Container(
                  width: 36, // Reduced from 40
                  height: 36, // Reduced from 40
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9), // Reduced from 10
                  ),
                  child: Center(
                    child: Icon(
                      Icons.description_rounded,
                      color: Colors.green,
                      size: 18, // Reduced from 20
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Reduced from 12
                Text(
                  "Submitted Reports",
                  style: TextStyle(
                    fontSize: 15, // Reduced from 16
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                if (isLoadingReports)
                  CircularProgressIndicator(color: primaryColor, strokeWidth: 2)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16), // Reduced from 20
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description, size: 13, color: primaryColor), // Reduced
                        const SizedBox(width: 5), // Reduced from 6
                        Text(
                          "${_reports.length} reports",
                          style: TextStyle(
                            fontSize: 11, // Reduced from 12
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: Color(0xFFF1F5F9)),

          // Reports Table
          isLoadingReports 
              ? _buildLoadingIndicator()
              : _buildReportsTable(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 130, // Reduced from 150
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 12), // Reduced from 16
            Text(
              "Loading reports...",
              style: TextStyle(
                fontSize: 13, // Reduced from 14
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTable() {
    // If no reports, show empty state
    if (_reports.isEmpty) {
      return Container(
        height: 130, // Reduced from 150
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 42, // Reduced from 48
                color: textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 12), // Reduced from 16
              Text(
                "No reports submitted yet",
                style: TextStyle(
                  fontSize: 13, // Reduced from 14
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // For small number of reports, show in list view
    if (_reports.length <= 3) {
      return _buildReportsListView();
    }
    
    // For more reports, use DataGrid with horizontal scrolling
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            minHeight: 80, // Reduced from 100
            maxHeight: constraints.maxHeight > 350 ? 350 : constraints.maxHeight, // Reduced from 400
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: BoxConstraints(minWidth: 900), // Reduced from 1000
              child: SfDataGrid(
                source: _reportsDataSource,
                gridLinesVisibility: GridLinesVisibility.horizontal,
                headerGridLinesVisibility: GridLinesVisibility.horizontal,
                columnWidthMode: ColumnWidthMode.fill,
                columns: [
                  GridColumn(
                    columnName: 'reportId',
                    width: 130, // Reduced from 140
                    label: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14), // Reduced
                      child: Text(
                        'Report ID',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontSize: 12, // Reduced from 13
                        ),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'office',
                    label: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14), // Reduced
                      child: Text(
                        'Office',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontSize: 12, // Reduced from 13
                        ),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'encoderPosition',
                    label: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14), // Reduced
                      child: Text(
                        'Encoder Position',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontSize: 12, // Reduced from 13
                        ),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'totalHeadCount',
                    width: 90, // Reduced from 100
                    label: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14), // Reduced
                      child: Text(
                        'Total People',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontSize: 12, // Reduced from 13
                        ),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'facultyCount',
                    width: 80, // Reduced from 90
                    label: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14), // Reduced
                      child: Text(
                        'Faculty',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontSize: 12, // Reduced from 13
                        ),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'studentCount',
                    width: 80, // Reduced from 90
                    label: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14), // Reduced
                      child: Text(
                        'Students',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontSize: 12, // Reduced from 13
                        ),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'missingCount',
                    width: 80, // Reduced from 90
                    label: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14), // Reduced
                      child: Text(
                        'Missing',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontSize: 12, // Reduced from 13
                        ),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'casualtyCount',
                    width: 80, // Reduced from 90
                    label: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14), // Reduced
                      child: Text(
                        'Casualties',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontSize: 12, // Reduced from 13
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportsListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        final totalHeadCount = _calculateTotalHeadCount(report);
        
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Reduced
          decoration: BoxDecoration(
            border: Border(
              bottom: index < _reports.length - 1
                  ? BorderSide(color: Color(0xFFF1F5F9), width: 1)
                  : BorderSide.none,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatOfficeName(report.office),
                          style: TextStyle(
                            fontSize: 14, // Reduced from 15
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3), // Reduced from 4
                        Text(
                          'ID: ${report.reportId.substring(0, 8)}...',
                          style: TextStyle(
                            fontSize: 11, // Reduced from 12
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10), // Reduced from 12
                    ),
                    child: Text(
                      '$totalHeadCount',
                      style: TextStyle(
                        fontSize: 13, // Reduced from 14
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10), // Reduced from 12
              Wrap(
                spacing: 6, // Reduced from 8
                runSpacing: 6, // Reduced from 8
                children: [
                  if (report.headCountFaculty > 0)
                    _buildCountChip(
                      label: 'Faculty',
                      count: report.headCountFaculty,
                      color: Colors.blue,
                    ),
                  if (report.headCountStudent > 0)
                    _buildCountChip(
                      label: 'Students',
                      count: report.headCountStudent,
                      color: Colors.green,
                    ),
                  if (report.headCountadminMember > 0)
                    _buildCountChip(
                      label: 'Admin',
                      count: report.headCountadminMember,
                      color: Colors.purple,
                    ),
                  if (report.numMissingPerson > 0)
                    _buildCountChip(
                      label: 'Missing',
                      count: report.numMissingPerson,
                      color: Colors.orange,
                    ),
                  if (report.numCasualty > 0)
                    _buildCountChip(
                      label: 'Casualties',
                      count: report.numCasualty,
                      color: Colors.red,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountChip({
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Reduced
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10), // Reduced from 12
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11, // Reduced from 12
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 3), // Reduced from 4
          Text(
            label,
            style: TextStyle(
              fontSize: 11, // Reduced from 12
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// DataGrid source for Reports using actual Report model
class ReportsDataSource extends DataGridSource {
  ReportsDataSource(List<Report> reports) {
    _reports = reports;
    _reportsData = reports
        .map<DataGridRow>(
          (e) => DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'reportId', value: e.reportId),
              DataGridCell<String>(columnName: 'office', value: e.office),
              DataGridCell<String>(columnName: 'encoderPosition', value: e.encoderPosition),
              DataGridCell<int>(columnName: 'totalHeadCount', value: _calculateTotalHeadCount(e)),
              DataGridCell<int>(columnName: 'facultyCount', value: e.headCountFaculty),
              DataGridCell<int>(columnName: 'studentCount', value: e.headCountStudent),
              DataGridCell<int>(columnName: 'missingCount', value: e.numMissingPerson),
              DataGridCell<int>(columnName: 'casualtyCount', value: e.numCasualty),
            ],
          ),
        )
        .toList();
  }

  late List<Report> _reports;
  late List<DataGridRow> _reportsData;

  int _calculateTotalHeadCount(Report report) {
    return report.headCountFaculty +
           report.headCountadminMember +
           report.headCountRepsMember +
           report.headCountCustodian +
           report.headCountJoCosMember +
           report.headCountStudent +
           report.headCountSecurity +
           report.headCountConstructionWorker +
           report.headCountHealthWorker +
           report.headCountGuest +
           report.headCountPatient;
  }

  @override
  List<DataGridRow> get rows => _reportsData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return Container(
          alignment: cell.columnName == 'office' || cell.columnName == 'encoderPosition'
              ? Alignment.centerLeft
              : Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14), // Reduced
          child: Text(
            cell.value.toString(),
            style: TextStyle(
              fontSize: 12, // Reduced from 13
              color: Color(0xFF1E293B),
              fontWeight: cell.columnName == 'office' || cell.columnName == 'reportId'
                  ? FontWeight.w600 
                  : FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}