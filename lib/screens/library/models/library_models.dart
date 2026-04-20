import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

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

  const AppItem({
    required this.title,
    required this.description,
    required this.version,
    required this.icon,
    required this.iconColor,
    required this.typeLabel,
    this.isInstalled = false,
  });
}

const mockCategories = [
  AppCategory('All Apps', 42),
  AppCategory('Databases', 12),
  AppCategory('IDEs & Editors', 8),
  AppCategory('Utilities', 15),
  AppCategory('DevOps', 7),
];

const mockApps = [
  AppItem(
    title: 'PostgreSQL 16',
    description: 'Advanced open source relational database with robust feature set.',
    version: 'v16.2.0',
    icon: Icons.dns_rounded,
    iconColor: AppColors.secondary,
    typeLabel: 'Installed',
    isInstalled: true,
  ),
  AppItem(
    title: 'VS Code',
    description: 'Lightweight but powerful source code editor optimized for zeroSetup.',
    version: 'v1.87.0',
    icon: Icons.code_rounded,
    iconColor: Colors.blue,
    typeLabel: 'IDE',
    isInstalled: false,
  ),
  AppItem(
    title: 'Redis Stack',
    description: 'In-memory data structure store, used as a database, cache, and message broker.',
    version: 'v7.2.4',
    icon: Icons.storage_rounded,
    iconColor: Colors.red,
    typeLabel: 'Database',
    isInstalled: false,
  ),
];
