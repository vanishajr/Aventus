import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://buviwkntxqmpipcjzchi.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1dml3a250eHFtcGlwY2p6Y2hpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc0OTA1ODgsImV4cCI6MjA2MzA2NjU4OH0.hewbBT9Rv0iVC2t2lvzepeR3_lQpHnE_qigKLhC91KU';

  static SupabaseClient? _client;
  static bool _initialized = false;

  static SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client ?? Supabase.instance.client;
  }

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: true, // Enable debug mode to see detailed logs
      );
      _client = Supabase.instance.client;
      _initialized = true;
      print('Supabase initialized successfully with URL: $url');
    } catch (e) {
      print('Error initializing Supabase: $e');
      rethrow;
    }
  }
} 