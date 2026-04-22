import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class IconService {
  static final IconService instance = IconService._();
  IconService._();

  Directory? _cacheDir;

  Future<void> init() async {
    final appDir = await getApplicationSupportDirectory();
    _cacheDir = Directory(p.join(appDir.path, 'icons'));
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
    
    // Automatically clean up corrupt or invalid icons on startup
    await sanitizeCache();
  }

  /// Scans the cache directory and deletes invalid or corrupted SVG files.
  Future<void> sanitizeCache() async {
    if (_cacheDir == null) return;
    
    try {
      final files = _cacheDir!.listSync();
      int deletedCount = 0;
      
      for (var entity in files) {
        if (entity is File && entity.path.endsWith('.svg')) {
          // Check for legacy Simple Icons filenames (contains an underscore for color)
          // or invalid content.
          final basename = p.basename(entity.path);
          final content = await entity.readAsBytes();
          
          bool shouldDelete = false;
          
          // 1. Check for legacy simple-icons format (e.g. visualstudiocode_007acc.svg)
          if (basename.contains('_') && !basename.startsWith('logos:')) {
            shouldDelete = true;
          }
          // 2. Check for invalid SVG content (HTML or malformed)
          else if (!_isValidSvg(content)) {
            shouldDelete = true;
          }

          if (shouldDelete) {
            print('Deleting invalid or legacy SVG: ${entity.path}');
            await entity.delete();
            deletedCount++;
          }
        }
      }
      if (deletedCount > 0) {
        print('Sanitized cache: Deleted $deletedCount legacy/invalid files.');
      }
    } catch (e) {
      print('Error during cache sanitization: $e');
    }
  }

  /// Checks if the byte array starts with a valid SVG or XML header.
  bool _isValidSvg(List<int> bytes) {
    if (bytes.length < 10) return false;
    
    // Convert the first 100 bytes to string for checking
    final headerPart = utf8.decode(bytes.sublist(0, bytes.length > 200 ? 200 : bytes.length), allowMalformed: true).toLowerCase();
    
    if (headerPart.contains('<html>') || headerPart.contains('<!doctype html>')) {
      return false;
    }
    
    return headerPart.contains('<svg') || headerPart.contains('<?xml');
  }

  /// Gets the local path of an icon. If not cached, it triggers a download.
  Future<String?> getIconPath(String? url) async {
    if (url == null || url.isEmpty) return null;

    if (_cacheDir == null) await init();

    final fileName = _getFileNameFromUrl(url);
    if (fileName == null) return null;
    
    final filePath = p.join(_cacheDir!.path, fileName);
    final file = File(filePath);

    if (await file.exists()) {
      return filePath;
    }

    // Download in background
    _downloadIcon(url, filePath);
    
    return null;
  }

  String? _getFileNameFromUrl(String url) {
    if (url.contains('api.iconify.design')) {
      // url format: https://api.iconify.design/logos:visual-studio-code.svg
      final parts = url.split('/');
      return parts.last.replaceAll(':', '_'); // logos_visual-studio-code.svg
    }
    
    // Legacy support or other sources
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;
    
    if (segments.length >= 2) {
      final slug = segments[segments.length - 2];
      final color = segments.last;
      return '${slug}_$color.svg';
    }
    
    return segments.last;
  }

  Future<void> _downloadIcon(String url, String savePath) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        if (_isValidSvg(response.bodyBytes)) {
          final file = File(savePath);
          await file.writeAsBytes(response.bodyBytes);
          print('Cached valid icon: $url');
        } else {
          print('Discarded invalid icon response for: $url');
        }
      }
    } catch (e) {
      print('Error caching icon $url: $e');
    }
  }

  /// Utility to get the cached file if it exists and is valid
  File? getFileIfCached(String url) {
    if (_cacheDir == null) return null;
    
    final fileName = _getFileNameFromUrl(url);
    if (fileName == null) return null;
    
    final file = File(p.join(_cacheDir!.path, fileName));
    return file.existsSync() ? file : null;
  }
}
