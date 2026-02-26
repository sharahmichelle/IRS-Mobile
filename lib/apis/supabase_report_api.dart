import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/report_model.dart';

class SupabaseReportAPI {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Stream<List<Report>> getAllReports() {
    return _supabase
        .from('reports')
        .stream(primaryKey: ['id'])
        .map<List<Report>>((data) => data
            .map((json) =>
                Report.fromJson(Map<String, dynamic>.from(json)))
            .toList());
  }

  Stream<List<Report>> getReportsByEncoderId(
      String encoderId) {
    return _supabase
        .from('reports')
        .stream(primaryKey: ['id'])
        .eq('encoder_id', encoderId)
        .map<List<Report>>((data) => data
            .map((json) =>
                Report.fromJson(Map<String, dynamic>.from(json)))
            .toList());
  }

  Future<String> addReport(
      Map<String, dynamic> reportData) async {
    try {
      final nowUtcString =
          DateTime.now().toUtc().toIso8601String();

      final dataWithTimestamp = {
        ...reportData,
        'lastModified': nowUtcString,
        'created': nowUtcString,
      };

      final dbFormattedData =
          _convertToDatabaseFormat(dataWithTimestamp);

      final response = await _supabase
          .from('reports')
          .insert(dbFormattedData)
          .select('id')
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to add report: $e');
    }
  }

  Future<void> editReport(
      String id, Map<String, dynamic> edit) async {
    try {
      final nowUtcString =
          DateTime.now().toUtc().toIso8601String();

      final editCopy = Map<String, dynamic>.from(edit);
      editCopy.remove('created');

      final updatedEdit = {
        ...editCopy,
        'lastModified': nowUtcString,
      };

      final dbFormattedEdit =
          _convertToDatabaseFormat(updatedEdit);

      await _supabase
          .from('reports')
          .update(dbFormattedEdit)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to edit report: $e');
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await _supabase
          .from('reports')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  Future<Report> fetchReportById(String id) async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .eq('id', id)
          .single();

      return Report.fromJson(
          Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Report not found for id: $id. Error: $e');
    }
  }

  Map<String, dynamic> _convertToDatabaseFormat(
      Map<String, dynamic> reportData) {
    final dbData = <String, dynamic>{};

    reportData.forEach((key, value) {
      switch (key) {
        case 'encoderId':
          dbData['encoder_id'] = value;
          break;
        case 'encoderposition':
          dbData['encoder_position'] = value;
          break;
        case 'reportId':
          dbData['event_id'] = value;
          dbData['report_id'] = value;
          break;
        case 'eventId':
          dbData['event_id'] = value;
          break;
        case 'bldgName':
          dbData['bldg_name'] = value;
          break;
        case 'lastModified':
          dbData['last_modified'] = value;
          break;
        case 'created':
          dbData['created_at'] = value;
          break;
        case 'eventType':
          dbData['event_type'] = value;
          break;
        case 'hazardType':
          dbData['hazard_type'] = value;
          break;
        case 'id':
          break;
        default:
          dbData[key] = value;
      }
    });

    return dbData;
  }
}
