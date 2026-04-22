import 'dart:async';
import '../models/program.dart';
import 'installation_service.dart';
import 'detection_service.dart';

enum InstallationStatus { idle, installing, success, error }

class InstallationManager {
  static final InstallationManager _instance = InstallationManager._internal();
  static InstallationManager get instance => _instance;
  InstallationManager._internal();

  final Map<String, double> _progressMap = {};
  final Map<String, InstallationStatus> _statusMap = {};
  final Map<String, String?> _errorMap = {};
  final Map<String, StreamSubscription> _subscriptions = {};

  double getProgress(String id) => _progressMap[id] ?? 0.0;
  InstallationStatus getStatus(String id) => _statusMap[id] ?? InstallationStatus.idle;
  String? getError(String id) => _errorMap[id];

  bool isInstalling(String id) => getStatus(id) == InstallationStatus.installing;

  void install(Program program) {
    final id = program.id;
    if (isInstalling(id)) return;

    _statusMap[id] = InstallationStatus.installing;
    _progressMap[id] = 0.1;
    _errorMap[id] = null;
    
    // Notify UI that we started
    DetectionService.statusNotifier.notifyListeners();

    final subscription = InstallationService.install(program).listen(
      (progress) {
        _progressMap[id] = progress;
        DetectionService.statusNotifier.notifyListeners();
      },
      onError: (error) {
        _statusMap[id] = InstallationStatus.error;
        _errorMap[id] = error.toString();
        _subscriptions[id]?.cancel();
        _subscriptions.remove(id);
        DetectionService.statusNotifier.notifyListeners();
      },
      onDone: () async {
        _statusMap[id] = InstallationStatus.success;
        _progressMap[id] = 1.0;
        _subscriptions[id]?.cancel();
        _subscriptions.remove(id);
        
        // Wait a small moment for OS registry/FS to catch up
        await Future.delayed(const Duration(seconds: 1));
        
        // Final detection to update global state - force refresh to bypass cache
        await DetectionService.checkAll([program], forceRefresh: true);
        DetectionService.statusNotifier.notifyListeners();
      },
    );

    _subscriptions[id] = subscription;
  }

  void clearStatus(String id) {
    if (isInstalling(id)) return;
    _statusMap.remove(id);
    _progressMap.remove(id);
    _errorMap.remove(id);
    DetectionService.statusNotifier.notifyListeners();
  }
}
