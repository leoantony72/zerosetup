import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LibraryHeader(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryFilters(
              categories: mockCategories,
              selectedLabel: _selectedCategory,
              onSelect: (label) {
                setState(() {
                  _selectedCategory = label;
                });
              },
            ),
            const SizedBox(width: 48),
            Expanded(
              child: AppGrid(
                apps: _selectedCategory == 'All Apps'
                    ? mockApps
                    : mockApps.where((app) {
                        if (_selectedCategory == 'Databases') {
                          return app.title.contains('PostgreSQL') ||
                                 app.title.contains('Redis');
                        }
                        if (_selectedCategory == 'IDEs & Editors') {
                          return app.title.contains('VS Code');
                        }
                        return false;
                      }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
