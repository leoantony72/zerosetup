import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../models/program.dart';

class AppCategory {
  final String label;
  final int count;

  const AppCategory(this.label, this.count);
}

class AppItem {
  final String title;
  final String description;
  final String version;
  final String? iconUrl;
  final String? iconAsset;
  final IconData icon;
  final Color iconColor;
  final String typeLabel;
  final bool isInstalled;
  final Program? program;

  const AppItem({
    required this.title,
    required this.description,
    required this.version,
    this.iconUrl,
    this.iconAsset,
    required this.icon,
    required this.iconColor,
    required this.typeLabel,
    this.isInstalled = false,
    this.program,
  });

  AppItem copyWith({
    String? title,
    String? description,
    String? version,
    String? iconUrl,
    String? iconAsset,
    IconData? icon,
    Color? iconColor,
    String? typeLabel,
    bool? isInstalled,
    Program? program,
  }) {
    return AppItem(
      title: title ?? this.title,
      description: description ?? this.description,
      version: version ?? this.version,
      iconUrl: iconUrl ?? this.iconUrl,
      iconAsset: iconAsset ?? this.iconAsset,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      typeLabel: typeLabel ?? this.typeLabel,
      isInstalled: isInstalled ?? this.isInstalled,
      program: program ?? this.program,
    );
  }
}

const mockCategories = [
  AppCategory('All Apps', 42),
  AppCategory('Databases', 12),
  AppCategory('IDEs & Editors', 8),
  AppCategory('Utilities', 15),
  AppCategory('DevOps', 7),
];
