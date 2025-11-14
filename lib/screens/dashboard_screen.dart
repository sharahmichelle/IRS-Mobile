import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:upm_drrm_irs_mobile/models/activity_log_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/activity_log_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/report_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';
import 'package:upm_drrm_irs_mobile/models/user_model.dart';
import 'package:upm_drrm_irs_mobile/providers/activity_logs_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color primaryColor = const Color.fromARGB(255, 161, 29, 28);

  // DATA LISTS
  List<ActivityLog> _activityData = [];
  List<Event> _eventData = [];
  List<Report> _reportData = [];

  // DATASOURCES
  ActivityDataSource? _activityDataSource;
  EventDataSource? _eventDataSource;
  ReportDataSource? _reportDataSource;

  final dashboardPages = ['Activity Logs', 'Events', 'Reports'];

  // Pagination
  final int _rowsPerPage = 10;
  int _currentPage = 1;
  int _totalPages = 1;

  int _currentIndex = 0;

  List<List<GridColumn>> dataListColumns = [];

  @override
  void initState() {
    super.initState();

    // TEMPORARY DUMMY REPORT DATA (still valid)
    _reportData = List.generate(25, (index) {
      return Report(
        encoderId: 'Encoder${index + 1}',
        reportId: 'Report${index + 1}',
        upSystem: 'UP System ${(index % 3) + 1}',
        office: 'Office ${(index % 5) + 1}',
      );
    });

    // Initialize columns
    dataListColumns = [
      // ACTIVITY LOGS COLUMNS
      [
        GridColumn(
          columnName: 'dateCreated',
          width: 150,
          label: CenterHeaderText('Date Created', primaryColor),
        ),
        GridColumn(
          columnName: 'module',
          width: 150,
          label: CenterHeaderText('Module', primaryColor),
        ),
        GridColumn(
          columnName: 'moduleItem',
          width: 200,
          label: CenterHeaderText('Module Item', primaryColor),
        ),
        GridColumn(
          columnName: 'initiatedBy',
          width: 150,
          label: CenterHeaderText('Initiated By', primaryColor),
        ),
        GridColumn(
          columnName: 'action',
          width: 150,
          label: CenterHeaderText('Action', primaryColor),
        ),
      ],

      // EVENTS COLUMNS
      [
        GridColumn(
          columnName: 'dateAndTime',
          width: 200,
          label: CenterHeaderText('Date & Time', primaryColor),
        ),
        GridColumn(
          columnName: 'name',
          width: 150,
          label: CenterHeaderText('Name', primaryColor),
        ),
        GridColumn(
          columnName: 'description',
          width: 250,
          label: CenterHeaderText('Description', primaryColor),
        ),
        GridColumn(
          columnName: 'status',
          width: 100,
          label: CenterHeaderText('Status', primaryColor),
        ),
        GridColumn(
          columnName: 'action',
          width: 150,
          label: CenterHeaderText('Action', primaryColor),
        ),
      ],

      // REPORTS COLUMNS
      [
        GridColumn(
          columnName: 'encoderId',
          width: 150,
          label: CenterHeaderText('Encoder ID', primaryColor),
        ),
        GridColumn(
          columnName: 'reportId',
          width: 150,
          label: CenterHeaderText('Report ID', primaryColor),
        ),
        GridColumn(
          columnName: 'upSystem',
          width: 150,
          label: CenterHeaderText('UP System', primaryColor),
        ),
        GridColumn(
          columnName: 'office',
          width: 150,
          label: CenterHeaderText('Office', primaryColor),
        ),
        GridColumn(
          columnName: 'encoderPosition',
          width: 200,
          label: CenterHeaderText('Encoder Position', primaryColor),
        ),
      ],
    ];
  }

  // PAGINATION UPDATE
  void _updateDataSource() {
    final startIndex = (_currentPage - 1) * _rowsPerPage;

    if (_currentIndex == 0) {
      // ACTIVITY LOGS
      final end = (_currentPage * _rowsPerPage).clamp(0, _activityData.length);
      _activityDataSource = ActivityDataSource(
        _activityData.sublist(startIndex, end),
      );
    } else if (_currentIndex == 1) {
      // EVENTS
      final end = (_currentPage * _rowsPerPage).clamp(0, _eventData.length);
      _eventDataSource = EventDataSource(_eventData.sublist(startIndex, end));
    } else {
      // REPORTS
      final end = (_currentPage * _rowsPerPage).clamp(0, _reportData.length);
      _reportDataSource = ReportDataSource(
        _reportData.sublist(startIndex, end),
      );
    }

    setState(() {});
  }

  // NAVIGATION BUTTONS
  void _onLeftClick() {
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = 2;
    }

    _currentPage = 1;
    _totalPages = _getCurrentListLength();
    _updateDataSource();
  }

  void _onRightClick() {
    if (_currentIndex < 2) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }

    _currentPage = 1;
    _totalPages = _getCurrentListLength();
    _updateDataSource();
  }

  int _getCurrentListLength() {
    if (_currentIndex == 0) return (_activityData.length / _rowsPerPage).ceil();
    if (_currentIndex == 1) return (_eventData.length / _rowsPerPage).ceil();
    return (_reportData.length / _rowsPerPage).ceil();
  }

  // MAIN UI BUILDER
  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color.fromARGB(255, 161, 29, 28);

    /// If Activity Logs TAB → StreamBuilder
    if (_currentIndex == 0) {
      return Consumer<ActivityLogs>(
        builder: (context, provider, _) {
          return StreamBuilder(
            stream: provider.activityLogs,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              _activityData = docs
                  .map((d) => ActivityLog.fromFirestore(d.data()))
                  .toList();

              // compute without setState
              _totalPages = _getCurrentListLength();

              final startIndex = (_currentPage - 1) * _rowsPerPage;
              final end = (_currentPage * _rowsPerPage).clamp(
                0,
                _activityData.length,
              );

              // build datasource directly WITHOUT calling setState
              _activityDataSource = ActivityDataSource(
                _activityData.sublist(startIndex, end),
              );

              return _buildDashboardBody(primaryColor);
            },
          );
        },
      );
    } else if(_currentIndex == 1){
      return Consumer<Events>(
        builder: (context, provider, _) {
          return StreamBuilder(
            stream: provider.events,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              _eventData = docs
                  .map((d) => Event.fromFirestore(d))
                  .toList();

              // compute without setState
              _totalPages = _getCurrentListLength();

              final startIndex = (_currentPage - 1) * _rowsPerPage;
              final end = (_currentPage * _rowsPerPage).clamp(
                0,
                _eventData.length,
              );

              // build datasource directly WITHOUT calling setState
              _eventDataSource = EventDataSource(
                _eventData.sublist(startIndex, end),
              );

              return _buildDashboardBody(primaryColor);
            },
          );
        },
      );
    }

    /// For Events & Reports — no StreamBuilder yet
    _totalPages = _getCurrentListLength();
    _updateDataSource();

    return _buildDashboardBody(primaryColor);
  }

  // UI WRAPPER
  Widget _buildDashboardBody(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _onLeftClick,
                icon: Icon(Icons.arrow_back, color: primaryColor),
              ),
              Text(
                dashboardPages[_currentIndex],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              IconButton(
                onPressed: _onRightClick,
                icon: Icon(Icons.arrow_forward, color: primaryColor),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            height: MediaQuery.of(context).size.height * 0.675,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: _buildTable(),
          ),
        ],
      ),
    );
  }

  // SWITCH TABLE BASED ON PAGE
  Widget _buildTable() {
    if (_currentIndex == 0 && _activityDataSource != null) {
      return SfDataGrid(
        source: _activityDataSource!,
        columns: dataListColumns[0],
      );
    }

    if (_currentIndex == 1 && _eventDataSource != null) {
      return SfDataGrid(source: _eventDataSource!, columns: dataListColumns[1]);
    }

    return SfDataGrid(source: _reportDataSource!, columns: dataListColumns[2]);
  }
}

class CenterHeaderText extends StatelessWidget {
  final String text;
  final Color color;
  const CenterHeaderText(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
