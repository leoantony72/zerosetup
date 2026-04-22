import 'package:flutter/material.dart';
import '../../models/program.dart';
import '../../services/program_service.dart';
import '../../services/detection_service.dart';
import 'models/library_models.dart';
import 'widgets/app_grid.dart';
import 'widgets/category_filters.dart';
import 'widgets/library_header.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  String _selectedCategory = 'All Apps';

  @override
  void initState() {
    super.initState();
    // Programs should be loading in background from main.dart
    // If not, ensure they load now.
    if (ProgramService.cachedPrograms == null) {
      ProgramService.loadPrograms().then((_) {
        if (mounted) setState(() {});
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LibraryHeader(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                final programs = ProgramService.cachedPrograms ?? [];
                
                // Calculate dynamic categories
                final categoriesMap = <String, int>{};
                for (var p in programs) {
                  categoriesMap[p.category] = (categoriesMap[p.category] ?? 0) + 1;
                }

                final List<AppCategory> dynamicCategories = [
                  AppCategory('All Apps', programs.length),
                  ...categoriesMap.entries.map((e) => AppCategory(e.key, e.value)).toList()
                    ..sort((a, b) => a.label.compareTo(b.label)),
                ];

                return CategoryFilters(
                  categories: dynamicCategories,
                  selectedLabel: _selectedCategory,
                  onSelect: (label) {
                    setState(() {
                      _selectedCategory = label;
                    });
                  },
                );
              },
            ),
            const SizedBox(width: 48),
            Expanded(
              child: ListenableBuilder(
                listenable: DetectionService.statusNotifier,
                builder: (context, _) {
                  final programs = ProgramService.cachedPrograms;
                  
                  if (programs == null) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading library...'),
                        ],
                      ),
                    );
                  }

                  final apps = programs
                      .where((p) =>
                          _selectedCategory == 'All Apps' ||
                          p.category == _selectedCategory)
                      .map((p) {
                        final item = p.toAppItem();
                        return AppItem(
                          title: item.title,
                          description: item.description,
                          version: item.version,
                          icon: item.icon,
                          iconColor: item.iconColor,
                          typeLabel: item.typeLabel,
                          isInstalled: DetectionService.isInstalled(p.id),
                          program: p,
                        );
                      })
                      .toList();

                  if (apps.isEmpty && _selectedCategory == 'All Apps') {
                    return const Center(child: Text('No applications found.'));
                  }

                  return AppGrid(apps: apps);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
