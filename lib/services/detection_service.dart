import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/program.dart';

class DetectionService {
  static final Map<String, bool> _installedStatus = {};
  static final Map<String, String> _installedVersions = {};
  static final ChangeNotifier statusNotifier = ChangeNotifier();

  static DateTime? _lastCheckTime;
  static const _cacheDuration = Duration(minutes: 5);

  static bool isInstalled(String programId) {
    return _installedStatus[programId] ?? false;
  }

  static String? getVersion(String programId) {
    return _installedVersions[programId];
  }

  static Future<void> checkAll(List<Program> programs, {bool forceRefresh = false}) async {
    if (!forceRefresh && _lastCheckTime != null && 
        DateTime.now().difference(_lastCheckTime!) < _cacheDuration) {
      return;
    }

    if (Platform.isWindows) {
      await _checkWindows(programs);
    } else if (Platform.isLinux || Platform.isMacOS) {
      await _checkUnix(programs);
    }
    
    _lastCheckTime = DateTime.now();
    statusNotifier.notifyListeners();
  }

  static Future<void> _checkUnix(List<Program> programs) async {
    try {
      final scriptPath = Platform.isLinux 
          ? 'scripts/linux/detect_apps.sh' 
          : 'scripts/mac/detect_apps.sh';

      final appsJson = jsonEncode(programs.map((p) => {
        'id': p.id,
        'program_name': p.programName,
        'executable_cmd': p.executableCmd,
      }).toList());

      await Process.run('chmod', ['+x', scriptPath]);
      final result = await Process.run('bash', [scriptPath, appsJson]);

      if (result.exitCode == 0) {
        final List<dynamic> output = jsonDecode(result.stdout);
        for (var item in output) {
          _installedStatus[item['id']] = item['installed'] == true;
          if (item['version'] != null && item['version'] != 'Not detected') {
            _installedVersions[item['id']] = item['version'];
          }
        }
      }
    } catch (e) {
      print('Unix detection error: $e');
    }
  }

  static Future<void> _checkWindows(List<Program> programs) async {
    try {
      final appsJson = jsonEncode(programs.map((p) => {
        'id': p.id,
        'program_name': p.programName,
        'executable_cmd': p.executableCmd,
      }).toList());

      final result = await Process.run('powershell.exe', [
        '-ExecutionPolicy', 'Bypass',
        '-File', 'scripts/windows/detect_apps.ps1',
        '-appsJson', appsJson
      ]);

      if (result.exitCode == 0) {
        final List<dynamic> output = jsonDecode(result.stdout);
        for (var item in output) {
          _installedStatus[item['id']] = item['installed'] == true;
          if (item['version'] != null && item['version'] != 'Not detected') {
            _installedVersions[item['id']] = item['version'];
          }
        }
      }
    } catch (e) {
      print('Detection error: $e');
    }
  }

  static Future<void> launchApp(Program program) async {
    try {
      if (Platform.isWindows) {
        // Start process without waiting (detached)
        Process.start(program.executableCmd, [], runInShell: true);
      } else if (Platform.isLinux || Platform.isMacOS) {
        Process.run(program.executableCmd, [], runInShell: true);
      }
    } catch (e) {
      print('Launch error: $e');
    }
  }
}
