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

  Map<String, dynamic> toJson(){
    return{
      'dateCreated': dateCreated,
      'module': module,
      'moduleItem': moduleItem,
      'initiatedBy': initiatedBy,
      'action': action
    };
  }
}