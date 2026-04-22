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
  final IconData icon;
  final Color iconColor;
  final String typeLabel;
  final bool isInstalled;
  final Program? program;

  const AppItem({
    required this.title,
    required this.description,
    required this.version,
    required this.icon,
    required this.iconColor,
    required this.typeLabel,
    this.isInstalled = false,
    this.program,
  });
}

const mockCategories = [
  AppCategory('All Apps', 42),
  AppCategory('Databases', 12),
  AppCategory('IDEs & Editors', 8),
  AppCategory('Utilities', 15),
  AppCategory('DevOps', 7),
];
