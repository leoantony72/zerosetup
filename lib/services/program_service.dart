import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/program.dart';

class ProgramService {
  static List<Program>? _cachedPrograms;
  static List<Program>? get cachedPrograms => _cachedPrograms;

  static Future<List<Program>> loadPrograms({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPrograms != null) {
      return _cachedPrograms!;
    }

    try {
      final String response = await rootBundle.loadString('assets/data/programs.json');
      final List<dynamic> data = json.decode(response);
      _cachedPrograms = data.map((json) => Program.fromJson(json)).toList();
      return _cachedPrograms!;
    } catch (e) {
      print('Error loading programs: $e');
      return [];
    }
  }
}
