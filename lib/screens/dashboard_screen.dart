import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color primaryColor = const Color.fromARGB(255, 161, 29, 28);
  late ActivityDataSource _activityDataSource;

  @override
  void initState() {
    super.initState();
    // Initialize dummy dataset
    final List<ActivityLog> activityData = List.generate(10, (index) {
      return ActivityLog(
        dateCreated: '2025-10-${(index + 1).toString().padLeft(2, '0')}',
        module: 'Module ${index + 1}',
        moduleItem: 'Item ${(index + 1)}',
        initiatedBy: 'User ${index + 1}',
        action: index.isEven ? 'Created' : 'Updated',
      );
    });

    _activityDataSource = ActivityDataSource(activityData);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            "Activity Logs",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // White padded container
          Container(
            width: double.infinity,
            height: 400,
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
            child: SfDataGrid(
              source: _activityDataSource,
              columns: [
                GridColumn(
                  columnName: 'dateCreated',
                  label: const Center(child: Text('Date Created')),
                ),
                GridColumn(
                  columnName: 'module',
                  label: const Center(child: Text('Module')),
                ),
                GridColumn(
                  columnName: 'moduleItem',
                  label: const Center(child: Text('Module Item')),
                ),
                GridColumn(
                  columnName: 'initiatedBy',
                  label: const Center(child: Text('Initiated By')),
                ),
                GridColumn(
                  columnName: 'action',
                  label: const Center(child: Text('Action')),
                ),
              ],
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              columnWidthMode: ColumnWidthMode.fill,
            ),
          ),
        ],
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
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'dateCreated', value: e.dateCreated),
              DataGridCell<String>(columnName: 'module', value: e.module),
              DataGridCell<String>(columnName: 'moduleItem', value: e.moduleItem),
              DataGridCell<String>(columnName: 'initiatedBy', value: e.initiatedBy),
              DataGridCell<String>(columnName: 'action', value: e.action),
            ]))
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
