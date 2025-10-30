class Event {
  final DateTime timeStampStart;
  final DateTime timeStampEnd;
  final String name;
  final String description;
  final String status;
  final String action;

  Event({
    required this.timeStampStart,
    required this.timeStampEnd,
    required this.name,
    required this.description,
    required this.status,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'timeStampStart': timeStampStart,
      'timeStampEnd': timeStampEnd,
      'name': name,
      'description': description,
      'status': status,
      'action': action
    };
  }
}
