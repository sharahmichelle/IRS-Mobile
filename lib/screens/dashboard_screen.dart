import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color primaryColor = const Color.fromARGB(255, 161, 29, 28);
  late List<ActivityLog> _activityData;
  late ActivityDataSource _activityDataSource;

  // Pagination parameters
  int _rowsPerPage = 10;
  int _currentPage = 1;
  int _totalPages = 1;

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

    _totalPages = (_activityData.length / _rowsPerPage).ceil();
    _updateDataSource();
  }

  void _updateDataSource() {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex =
        (_currentPage * _rowsPerPage).clamp(0, _activityData.length);

    final currentData = _activityData.sublist(startIndex, endIndex);
    _activityDataSource = ActivityDataSource(currentData);
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Activity Logs",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

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
                  source: _activityDataSource,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  columnWidthMode: ColumnWidthMode.none,
                  columns: [
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
                      width: 120,
                      label: CenterHeaderText('Action', primaryColor),
                    ),
                  ],
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

/// Model class for an activity log entry
class ActivityLog {
  ActivityLog({
    required this.dateCreated,
    required this.module,
    required this.moduleItem,
    required this.initiatedBy,
    required this.action,
  });

  final String dateCreated;
  final String module;
  final String moduleItem;
  final String initiatedBy;
  final String action;
}

/// DataGrid source for Activity Logs
class ActivityDataSource extends DataGridSource {
  ActivityDataSource(List<ActivityLog> activityLogs) {
    _activityData = activityLogs
        .map<DataGridRow>(
          (e) => DataGridRow(
            cells: [
              DataGridCell(columnName: 'dateCreated', value: e.dateCreated),
              DataGridCell(columnName: 'module', value: e.module),
              DataGridCell(columnName: 'moduleItem', value: e.moduleItem),
              DataGridCell(columnName: 'initiatedBy', value: e.initiatedBy),
              DataGridCell(columnName: 'action', value: e.action),
            ],
          ),
        )
        .toList();
  }

  late List<DataGridRow> _activityData;

  @override
  List<DataGridRow> get rows => _activityData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            cell.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}
