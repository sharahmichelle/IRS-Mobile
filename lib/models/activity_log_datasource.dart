import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:upm_drrm_irs_mobile/models/activity_log_model.dart';

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