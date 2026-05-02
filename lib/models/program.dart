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
  final String? iconSlug;
  final String? iconColor;
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
    this.iconSlug,
    this.iconColor,
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
      iconSlug: json['icon_slug'],
      iconColor: json['icon_color'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  AppItem toAppItem() {
    IconData icon;
    Color categoryColor;

    switch (category) {
      case 'IDEs & Editors':
        icon = Icons.code_rounded;
        categoryColor = Colors.blue;
        break;
      case 'DevOps':
        icon = Icons.terminal_rounded;
        categoryColor = Colors.purple;
        break;
      case 'Databases':
        icon = Icons.storage_rounded;
        categoryColor = Colors.orange;
        break;
      case 'Languages':
        icon = Icons.translate_rounded;
        categoryColor = Colors.teal;
        break;
      default:
        icon = Icons.settings_rounded;
        categoryColor = Colors.grey;
    }

    // Official Icon URL from Simple Icons CDN
    String? iconUrl;
    Color displayColor = categoryColor;

    if (iconSlug != null) {
      final hex = iconColorHex;
      iconUrl = 'https://api.iconify.design/logos:$iconSlug.svg';
      
      // Parse the brand color hex string to a Flutter Color
      try {
        displayColor = Color(int.parse('FF$hex', radix: 16));
      } catch (e) {
        displayColor = categoryColor;
      }
    }

    String? iconAsset;
    if (iconSlug != null) {
      // Determine extension based on known PNG assets
      final pngSlugs = {'vlc', 'tableplus'};
      final ext = pngSlugs.contains(iconSlug) ? 'png' : 'svg';
      iconAsset = 'assets/icons/logos_$iconSlug.$ext';
    }

    return AppItem(
      title: programName,
      description: 'ZeroSetup automated installation for $programName.',
      version: version,
      iconUrl: iconUrl,
      iconAsset: iconAsset,
      icon: icon,
      iconColor: displayColor, // Official brand color!
      typeLabel: category,
      isInstalled: false,
      program: this,
    );
  }

  String get iconColorHex => iconColor ?? '444444';

  /// True when this program is a database engine (not a GUI app).
  bool get isDatabase => category == 'Databases' && const {
    'postgresql', 'mysql', 'redis', 'mongodb', 'cassandra',
    'cockroachdb', 'elasticsearch', 'mariadb', 'neo4j', 'clickhouse',
  }.contains(id);
}
