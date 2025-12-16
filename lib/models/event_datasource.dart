import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';

/// DataGrid source for Event
class EventDataSource extends DataGridSource {
  EventDataSource(List<Event> events) {
    _eventData = events
        .map<DataGridRow>(
          (e) => DataGridRow(
            cells: [
              DataGridCell(columnName: 'dateAndTime', value: e.timeStampStart),
              DataGridCell(columnName: 'name', value: e.eventName),
              DataGridCell(columnName: 'description', value: e.eventDescription),
              DataGridCell(columnName: 'status', value: e.status),
              DataGridCell(columnName: 'action', value: e.action),
            ],
          ),
        )
        .toList();
  }

  late List<DataGridRow> _eventData;

  @override
  List<DataGridRow> get rows => _eventData;

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