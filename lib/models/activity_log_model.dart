import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toJson(){
    return{
      'dateCreated': Timestamp.fromDate(dateCreated),
      'module': module,
      'moduleItem': moduleItem,
      'initiatedBy': initiatedBy,
      'action': action,
      'data': data,
    };
  }

  factory ActivityLog.fromFirestore(Map<String, dynamic> firestoreData) {
    final ts = firestoreData['dateCreated'];

    return ActivityLog(
      dateCreated: ts is Timestamp
          ? ts.toDate()
          : DateTime.tryParse(ts ?? '') ?? DateTime.now(),

      module: firestoreData['module'] ?? '',
      moduleItem: firestoreData['moduleItem'] ?? '',
      initiatedBy: firestoreData['initiatedBy'] ?? '',
      action: firestoreData['action'] ?? '',
      data: firestoreData['data'] != null
          ? Map<String, dynamic>.from(firestoreData['data'])
          : {},
    );
  }


}