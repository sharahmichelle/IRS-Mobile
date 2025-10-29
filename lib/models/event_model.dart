class Event {
  final DateTime timeStamp;
  final String name;
  final String description;
  final String status;
  final String action;

  Event({
    required this.timeStamp,
    required this.name,
    required this.description,
    required this.status,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'timeStamp': timeStamp,
      'name': name,
      'description': description,
      'status': status,
      'action': action
    };
  }
}
