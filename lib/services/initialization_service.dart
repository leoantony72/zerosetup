import 'program_service.dart';
import 'detection_service.dart';

class InitializationService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Initializes the application's data layer in the background.
  /// This should be called on app startup (main.dart).
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // 1. Load programs from JSON (fast)
      final programs = await ProgramService.loadPrograms();
      
      // 2. Trigger initial detection (slow, but now happening in background)
      // We don't await this because we want UI to show up immediately
      DetectionService.checkAll(programs, forceRefresh: true).then((_) {
        print('Background detection complete.');
      });

      _isInitialized = true;
    } catch (e) {
      print('Initialization error: $e');
    }
  }
}
