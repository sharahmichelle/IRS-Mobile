import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_options.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static const String supabaseUrl = 'https://bdjullzlquogcroflwbp.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkanVsbHpscXVvZ2Nyb2Zsd2JwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg5Nzg4NzcsImV4cCI6MjA4NDU1NDg3N30.ysY_jWrL3WeKK3uO4Zpr_hj0IUaR4D1pTaBXbIUI9L4';
}
