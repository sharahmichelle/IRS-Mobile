  import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';

/// DataGrid source for Report
class ReportDataSource extends DataGridSource {
  ReportDataSource(List<Report> reports) {
    _reportData = reports
        .map<DataGridRow>(
          (e) => DataGridRow(
            cells: [
              DataGridCell(columnName: 'encoderId', value: e.encoderId),
              DataGridCell(columnName: 'reportId', value: e.reportId),
              DataGridCell(columnName: 'cluster', value: e.cluster),
              DataGridCell(columnName: 'office', value: e.office),
              DataGridCell(columnName: 'bldgName', value: e.bldgName),
              DataGridCell(columnName: 'encoderposition', value: e.encoderposition),

            ],
          ),
        )
        .toList();
  }

  late List<DataGridRow> _reportData;

  @override
  List<DataGridRow> get rows => _reportData;

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