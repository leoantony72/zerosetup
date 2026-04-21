import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const _keyDownloadPath = 'download_path';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get the saved download path or a default one.
  Future<String> getDownloadPath() async {
    final savedPath = _prefs.getString(_keyDownloadPath);
    if (savedPath != null && savedPath.isNotEmpty) {
      if (await Directory(savedPath).exists()) {
        return savedPath;
      }
    }

    // Default to system downloads folder if possible
    try {
      Directory? downloadsDir;
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        downloadsDir = await getDownloadsDirectory();
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }
      return downloadsDir?.path ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Save the download path.
  Future<void> setDownloadPath(String path) async {
    await _prefs.setString(_keyDownloadPath, path);
  }
}
