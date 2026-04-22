import 'package:flutter/material.dart';
import '../screens/library/models/library_models.dart';

class Program {
  final String id;
  final String programName;
  final String category;
  final String version;
  final String executableCmd;
  final String windowsScript;
  final String linuxScript;
  final String macScript;
  final String sizeMb;
  final DateTime createdAt;

  Program({
    required this.id,
    required this.programName,
    required this.category,
    required this.version,
    required this.executableCmd,
    required this.windowsScript,
    required this.linuxScript,
    required this.macScript,
    required this.sizeMb,
    required this.createdAt,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'],
      programName: json['program_name'],
      category: json['category'],
      version: json['version'],
      executableCmd: json['executable_cmd'] ?? '',
      windowsScript: json['windows_script'],
      linuxScript: json['linux_script'],
      macScript: json['mac_script'],
      sizeMb: json['size_mb'] ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  AppItem toAppItem() {
    IconData icon;
    Color iconColor;

    switch (category) {
      case 'IDEs & Editors':
        icon = Icons.code_rounded;
        iconColor = Colors.blue;
        break;
      case 'DevOps':
        icon = Icons.terminal_rounded;
        iconColor = Colors.purple;
        break;
      case 'Databases':
        icon = Icons.storage_rounded;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.settings_rounded;
        iconColor = Colors.grey;
    }

    // Specific overrides if needed
    if (programName.toLowerCase().contains('spotify')) {
      icon = Icons.library_music_rounded;
      iconColor = Colors.green;
    } else if (programName.toLowerCase().contains('chrome')) {
      icon = Icons.public_rounded;
      iconColor = Colors.redAccent;
    } else if (programName.toLowerCase().contains('postman')) {
      icon = Icons.api_rounded;
      iconColor = Colors.orange;
    }

    return AppItem(
      title: programName,
      description: 'ZeroSetup automated installation for $programName.',
      version: version,
      icon: icon,
      iconColor: iconColor,
      typeLabel: category,
      isInstalled: false, // Default to false for now
      program: this,
    );
  }
}
