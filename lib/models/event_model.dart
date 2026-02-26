
/* import 'package:cloud_firestore/cloud_firestore.dart'; */

class Event {
  final String eventId;
  final DateTime timeStampStart;
  final DateTime timeStampEnd;
  final String category;
  final String eventName;
  final String eventDescription;
  final bool eventStarted;
  final String incidentCommander;
  final String liasonOfficer;
  final String status;
  final String location;
  final String publicInformationOfficer;
  final String safetySecurityOfficer;
  final String eventType;
  
  // User-Event association fields
  final String? cluster;
  final String? office;
  final String? bldgName;

  Event({
    required this.eventId,
    required this.timeStampStart,
    required this.timeStampEnd,
    required this.category,
    required this.eventName,
    required this.eventDescription,
    required this.incidentCommander,
    required this.liasonOfficer,
    required this.status,
    required this.publicInformationOfficer,
    required this.safetySecurityOfficer,
    required this.location,
    this.eventStarted = false,
    this.eventType = '',
    this.cluster,
    this.office,
    this.bldgName,
  });

  factory Event.fromMap(Map<String, dynamic> data, String id) {
    // Helper getters to handle different key casings returned by Supabase
    String _str(List<String> keys) {
      for (var k in keys) {
        if (data.containsKey(k) && data[k] != null) return data[k].toString();
      }
      return '';
    }

    List<String> _list(List<String> keys) {
      for (var k in keys) {
        if (!data.containsKey(k) || data[k] == null) continue;
        final val = data[k];
        if (val is List) return List<String>.from(val);
        if (val is String) {
          // Handle Postgres array string like '{a,b}'
          final s = val.trim();
          if (s.startsWith('{') && s.endsWith('}')) {
            final inner = s.substring(1, s.length - 1);
            return inner
                .split(',')
                .map((e) => e.trim().replaceAll('"', ''))
                .where((e) => e.isNotEmpty)
                .toList();
          }
          return [val];
        }
      }
      return <String>[];
    }

    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (_) {
          return DateTime.now();
        }
      }
      if (date is DateTime) return date;
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    final eventName = _str(['eventName', 'eventname', 'name']);
    // If eventName is still empty, log keys for debugging
    if (eventName.isEmpty) {
      // ignore: avoid_print
      print('Warning: Event $id has empty name. Available keys: ${data.keys}');
    }

    return Event(
      eventId: id,
      eventName: eventName,
      eventDescription: _str(['eventDescription', 'eventdescription', 'description']),
      status: _str(['status']),
      timeStampStart: parseDate(data['timeStampStart'] ?? data['timestampstart'] ?? data['time_stamp_start']),
      timeStampEnd: parseDate(data['timeStampEnd'] ?? data['timestampend'] ?? data['time_stamp_end']),
      category: _str(['category']),
      incidentCommander: _str(['incidentCommander', 'incidentcommander']),
      liasonOfficer: _str(['liasonOfficer', 'liasonofficer']),
      publicInformationOfficer: _str(['publicInformationOfficer', 'publicinformationofficer']),
      safetySecurityOfficer: _str(['safetySecurityOfficer', 'safetysecurityofficer']),
      location: _str(['location']),
      // User-Event association fields
      cluster: data['cluster']?.toString(),
      office: data['office']?.toString(),
      bldgName: data['bldgname']?.toString(),
    );
  }

  factory Event.empty() {
    return Event(
      eventId: '',
      timeStampStart: DateTime.now(),
      timeStampEnd: DateTime.now(),
      category: '',
      eventName: '',
      eventDescription: '',
      incidentCommander: '',
      liasonOfficer: '',
      status: '',
      publicInformationOfficer: '',
      safetySecurityOfficer: '',
      location: '',
      eventStarted: false,
      eventType: '',
    );
  }

  DateTime get getStartDate =>
      DateTime(timeStampStart.year, timeStampStart.month, timeStampStart.day);
  DateTime get getEndDate =>
      DateTime(timeStampEnd.year, timeStampEnd.month, timeStampEnd.day);

  get reportsIds => null;

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'timeStampStart': timeStampStart,
      'timeStampEnd': timeStampEnd,
      'category': category,
      'eventName': eventName,
      'eventDescription': eventDescription,
      'incidentCommander': incidentCommander,
      'liasonOfficer': liasonOfficer,
      'publicInformationOfficer': publicInformationOfficer,
      'safetySecurityOfficer': safetySecurityOfficer,
      'status': status,
      'location': location,
      'eventType': eventType,
    };
  }
}
