import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:upm_drrm_irs_mobile/models/activity_log_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/activity_log_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/report_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color primaryColor = const Color.fromARGB(255, 161, 29, 28);
  late List<ActivityLog> _activityData;
  late ActivityDataSource _activityDataSource;

  late List<Event> _eventData;
  late EventDataSource _eventDataSource;

  late List<Report> _reportData;
  late ReportDataSource _reportDataSource;

  final dashboardPages = [
    'Activity Logs',
    'Events',
    'Reports',
  ];

  // Pagination parameters
  final int _rowsPerPage = 10;
  int _currentPage = 1;
  int _totalPages = 1;

  // Dashboard Page
  int _currentIndex = 0;

  List<List<GridColumn>> dataListColumns = [];
  List<List<dynamic>> dataListRows = [];

  @override
  void initState() {
    super.initState();

    // Generate dummy data
    _activityData = List.generate(25, (index) {
      return ActivityLog(
        dateCreated: '2025-10-${(index + 1).toString().padLeft(2, '0')}',
        module: 'Module ${index + 1}',
        moduleItem: 'Item ${(index + 1)}',
        initiatedBy: 'User ${index + 1}',
        action: index.isEven ? 'Created' : 'Updated',
      );
    });

    _eventData = List.generate(25, (index) {
      return Event(
        timeStampStart: DateTime(2025, 11, index + 1, 10, 0),
        timeStampEnd: DateTime(2025, 11, index + 1, 12, 0),
        name: 'Event ${index + 1}',
        description: 'Description for Event ${(index + 1)}',
        status: index.isEven ? 'Active' : 'Inactive',
        action: index.isEven ? 'Scheduled' : 'Cancelled',
      );
    });

    _reportData = List.generate(25, (index) {
      return Report(
        encoderId: 'Encoder${index + 1}',
        reportId: 'Report${index + 1}',
        upSystem: 'UP System ${(index % 3) + 1}',
        office: 'Office ${(index % 5) + 1}',
      );
    });

    dataListRows = [
      _activityData,
      _eventData,
      _reportData,
    ];

    dataListColumns = [
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

    _totalPages = (_activityData.length / _rowsPerPage).ceil();
    _updateDataSource();
  }

  void _updateDataSource() {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex =
        (_currentPage * _rowsPerPage).clamp(0, _activityData.length);

    final currentActivityData = _activityData.sublist(startIndex, endIndex);
    final currentEventData = _eventData.sublist(startIndex, endIndex);
    final currentReportData = _reportData.sublist(startIndex, endIndex);

    _activityDataSource = ActivityDataSource(currentActivityData);
    _eventDataSource = EventDataSource(currentEventData);
    _reportDataSource = ReportDataSource(currentReportData);

    setState(() {});
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      _updateDataSource();
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      _updateDataSource();
    }
  }

  void _onLeftClick() {
    if (_currentIndex > 0) {
      _currentIndex--;
      
    } else {
      _currentIndex = dashboardPages.length - 1;
    }

    _currentPage = 1;
    _totalPages = (dataListRows[_currentIndex].length / _rowsPerPage).ceil();
    _updateDataSource();

    setState(() {});
  }

  void _onRightClick() {
    if (_currentIndex < dashboardPages.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }

    _currentPage = 1;
    _totalPages = (dataListRows[_currentIndex].length / _rowsPerPage).ceil();
    _updateDataSource();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: _onLeftClick, icon: Icon(Icons.arrow_circle_left_outlined, color: primaryColor, size: 30,)),
              Text(
                dashboardPages[_currentIndex],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              IconButton(onPressed: _onRightClick, icon: Icon(Icons.arrow_circle_right_outlined, color: primaryColor, size: 30,)),
            ],
          ),

          // Table container
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.675,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 775,
                child: SfDataGrid(
                  source: _currentIndex == 0 ? _activityDataSource : _eventDataSource,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  columnWidthMode: ColumnWidthMode.none,
                  columns: dataListColumns[_currentIndex],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Pagination Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Previous'),
              ),
              const SizedBox(width: 16),
              Text(
                'Page $_currentPage of $_totalPages',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _currentPage < _totalPages ? _goToNextPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
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
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

