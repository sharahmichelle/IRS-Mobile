import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityLog {
  ActivityLog({
    required this.dateCreated,
    required this.module,
    required this.moduleItem,
    required this.initiatedBy,
    required this.action,
    required this.data,
  });

  final DateTime dateCreated;
  final String module;
  final String moduleItem;
  final String initiatedBy;
  final String action;
  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() {
    return {
      'dateCreated': dateCreated.toIso8601String(),
      'module': module,
      'moduleItem': moduleItem,
      'initiatedBy': initiatedBy,
      'action': action,
      'data': data,
    };
  }

  factory ActivityLog.fromJson(Map<String, dynamic> jsonData) {
    final ts = jsonData['dateCreated'];

    return ActivityLog(
      dateCreated: DateTime.tryParse(ts ?? '') ?? DateTime.now(),
      module: jsonData['module'] ?? '',
      moduleItem: jsonData['moduleItem'] ?? '',
      initiatedBy: jsonData['initiatedBy'] ?? '',
      action: jsonData['action'] ?? '',
      data: jsonData['data'] != null
          ? Map<String, dynamic>.from(jsonData['data'])
          : {},
    );
  }
}
