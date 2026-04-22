import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'services/settings_service.dart';
import 'services/protocol_service.dart';
import 'services/auth_service.dart';
import 'services/initialization_service.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register the custom URI protocol for deep linking
  await ProtocolService.register();
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Initialize AuthService singleton to start the deep link listener
  AuthService();

  // Initialize Settings
  await SettingsService().init();

  // Start background data loading
  InitializationService.init();

  runApp(const AutomationCoreApp());
}
