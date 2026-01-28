import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:upm_drrm_irs_mobile/models/activity_log_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/activity_log_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/report_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';
import 'package:upm_drrm_irs_mobile/providers/activity_logs_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/reports_provider.dart';
import 'package:upm_drrm_irs_mobile/widgets/screen_header.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  // Modern color scheme
  final Color primaryColor = Color(0xFFA11D1C);
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = Color(0xFF1E293B);
  final Color textSecondary = Color(0xFF64748B);
  final Color accentColor = Color(0xFF0EA5E9);

  // Data lists
  List<ActivityLog> _activityData = [];
  List<Event> _eventData = [];
  List<Report> _reportData = [];

  // Data sources
  ActivityDataSource? _activityDataSource;
  EventDataSource? _eventDataSource;
  ReportDataSource? _reportDataSource;

  final List<String> tablePages = ['Activity Logs', 'Events', 'Reports'];
  final List<IconData> tableIcons = [
    Icons.history_rounded,
    Icons.event_rounded,
    Icons.assessment_rounded,
  ];

  // Pagination
  final int _rowsPerPage = 10;
  int _currentPage = 1;
  int _totalPages = 1;
  int _currentIndex = 0;

  List<List<GridColumn>> dataListColumns = [];

  @override
  void initState() {
    super.initState();

    // // Temporary dummy report data
    // _reportData = List.generate(25, (index) {
    //   return Report(
    //     encoderId: 'Encoder${index + 1}',
    //     reportId: 'Report${index + 1}',
    //     upSystem: 'UP System ${(index % 3) + 1}',
    //     office: 'Office ${(index % 5) + 1}',
    //   );
    // });

    // Initialize columns with modern styling
    dataListColumns = [
      // ACTIVITY LOGS COLUMNS
      [
        _buildGridColumn('dateCreated', 'Date Created', 140),
        _buildGridColumn('module', 'Module', 130),
        _buildGridColumn('moduleItem', 'Module Item', 180),
        _buildGridColumn('initiatedBy', 'Initiated By', 140),
        _buildGridColumn('action', 'Action', 120),
      ],

      // EVENTS COLUMNS
      [
        _buildGridColumn('dateAndTime', 'Date & Time', 160),
        _buildGridColumn('name', 'Name', 130),
        _buildGridColumn('description', 'Description', 200),
        _buildGridColumn('status', 'Status', 100),
        _buildGridColumn('action', 'Action', 120),
      ],

      // REPORTS COLUMNS
      [
        _buildGridColumn('encoderId', 'Encoder ID', 130),
        _buildGridColumn('reportId', 'Report ID', 130),
        _buildGridColumn('upSystem', 'UP System', 130),
        _buildGridColumn('office', 'Office', 130),
        _buildGridColumn('encoderPosition', 'Encoder Position', 160),
      ],
    ];
  }

  GridColumn _buildGridColumn(String columnName, String label, double width) {
    return GridColumn(
      columnName: columnName,
      width: width,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.05),
          border: Border(
            right: BorderSide(color: Color(0xFFE2E8F0)),
            bottom: BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: primaryColor,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // Pagination update
  void _updateDataSource() {
    final startIndex = (_currentPage - 1) * _rowsPerPage;

    if (_currentIndex == 0) {
      final end = (_currentPage * _rowsPerPage).clamp(0, _activityData.length);
      _activityDataSource = ActivityDataSource(_activityData.sublist(startIndex, end));
    } else if (_currentIndex == 1) {
      final end = (_currentPage * _rowsPerPage).clamp(0, _eventData.length);
      _eventDataSource = EventDataSource(_eventData.sublist(startIndex, end));
    } else {
      final end = (_currentPage * _rowsPerPage).clamp(0, _reportData.length);
      _reportDataSource = ReportDataSource(_reportData.sublist(startIndex, end));
    }

    setState(() {});
  }

  // Navigation methods
  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
      _currentPage = 1;
      _totalPages = _getTotalPages();
      _updateDataSource();
    });
  }

  void _onPageLeft() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _updateDataSource();
      });
    }
  }

  void _onPageRight() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
        _updateDataSource();
      });
    }
  }

  int _getTotalPages() {
    if (_currentIndex == 0) return (_activityData.length / _rowsPerPage).ceil();
    if (_currentIndex == 1) return (_eventData.length / _rowsPerPage).ceil();
    return (_reportData.length / _rowsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 0) {
      return Consumer<ActivityLogs>(
        builder: (context, provider, _) {
          return StreamBuilder(
            stream: provider.activityLogs,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _buildLoadingState();
              }

              final data = snapshot.data!;
              _activityData = data.map((d) => ActivityLog.fromJson(d)).toList();
              _totalPages = _getTotalPages();

              final startIndex = (_currentPage - 1) * _rowsPerPage;
              final end = (_currentPage * _rowsPerPage).clamp(0, _activityData.length);
              _activityDataSource = ActivityDataSource(_activityData.sublist(startIndex, end));

              return _buildTableBody();
            },
          );
        },
      );
    } else if (_currentIndex == 1) {
      return Consumer<Events>(
        builder: (context, provider, _) {
          return StreamBuilder(
            stream: provider.events,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _buildLoadingState();
              }

              final data = snapshot.data!;
              _eventData = data.map((d) => Event.fromMap(d, d['id'])).toList();
              _totalPages = _getTotalPages();

              final startIndex = (_currentPage - 1) * _rowsPerPage;
              final end = (_currentPage * _rowsPerPage).clamp(0, _eventData.length);
              _eventDataSource = EventDataSource(_eventData.sublist(startIndex, end));

              return _buildTableBody();
            },
          );
        },
      );
    } else if (_currentIndex == 2) {
          return Consumer<Reports>(
            builder: (context, reportProvider, _) {
              return StreamBuilder(
                stream: reportProvider.reports,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildLoadingState();
                  }

                  final data = snapshot.data!;
                  _reportData = data;
                  _totalPages = _getTotalPages();

                  final startIndex = (_currentPage - 1) * _rowsPerPage;
                  final end = (_currentPage * _rowsPerPage).clamp(0, _reportData.length);
                  _reportDataSource = ReportDataSource(_reportData.sublist(startIndex, end));

                  return _buildTableBody();
                },
              );
            },
          );
    }

    // This should never be reached since _currentIndex is always 0, 1, or 2
    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            Text(
              'Loading data...',
              style: TextStyle(
                color: textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableBody() {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ScreenHeader(primaryColor: primaryColor, textPrimary: textPrimary, textSecondary: textSecondary, title: "Tables", subtitle: "Monitor activities and reports", icon: Icons.table_chart_outlined),
              const SizedBox(height: 24),

              // Tab Navigation
              _buildTabNavigation(),
              const SizedBox(height: 20),

              // Data Table Card
              Expanded(
                child: _buildDataTableCard(),
              ),

              // Pagination
              const SizedBox(height: 16),
              _buildPagination(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tablePages.length, (index) {
          final isActive = index == _currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onTabChange(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isActive
                      ? Border.all(color: primaryColor.withOpacity(0.3))
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tableIcons[index],
                      size: 20,
                      color: isActive ? primaryColor : textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tablePages[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? primaryColor : textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDataTableCard() {
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
          // Table Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  tableIcons[_currentIndex],
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  tablePages[_currentIndex],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_getCurrentDataLength()} items',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(height: 1, color: Color(0xFFE2E8F0)),
          
          // Data Table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1), // Small padding for the table
              child: _buildTable(),
            ),
          ),
        ],
      ),
    );
  }

  int _getCurrentDataLength() {
    if (_currentIndex == 0) return _activityData.length;
    if (_currentIndex == 1) return _eventData.length;
    return _reportData.length;
  }

  Widget _buildTable() {
    if (_currentIndex == 0 && _activityDataSource != null) {
      return SfDataGrid(
        source: _activityDataSource!,
        columns: dataListColumns[0],
        gridLinesVisibility: GridLinesVisibility.horizontal,
        headerGridLinesVisibility: GridLinesVisibility.horizontal,
      );
    }

    if (_currentIndex == 1 && _eventDataSource != null) {
      return SfDataGrid(
        source: _eventDataSource!,
        columns: dataListColumns[1],
        gridLinesVisibility: GridLinesVisibility.horizontal,
        headerGridLinesVisibility: GridLinesVisibility.horizontal,
      );
    }

    if (_currentIndex == 2 && _reportDataSource != null) {
      return SfDataGrid(
        source: _reportDataSource!,
        columns: dataListColumns[2],
        gridLinesVisibility: GridLinesVisibility.horizontal,
        headerGridLinesVisibility: GridLinesVisibility.horizontal,
      );
    }

    return const Center(child: Text('No data available'));
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPaginationButton(
            icon: Icons.chevron_left_rounded,
            onPressed: _onPageLeft,
            isEnabled: _currentPage > 1,
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Page $_currentPage of $_totalPages',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildPaginationButton(
            icon: Icons.chevron_right_rounded,
            onPressed: _onPageRight,
            isEnabled: _currentPage < _totalPages,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isEnabled,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isEnabled ? primaryColor : Colors.grey.withOpacity(0.3),
        shape: BoxShape.circle,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: IconButton(
        onPressed: isEnabled ? onPressed : null,
        icon: Icon(icon, color: Colors.white, size: 20),
        padding: EdgeInsets.zero,
      ),
    );
  }
}