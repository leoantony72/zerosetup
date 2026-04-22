import 'package:flutter/material.dart';
import '../models/library_models.dart';
import 'app_card.dart';

class AppGrid extends StatelessWidget {
  final List<AppItem> apps;

  const AppGrid({super.key, required this.apps});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisExtent: 280,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return AppCard(
          key: ValueKey(apps[index].program?.id ?? apps[index].title),
          item: apps[index],
        );
      },
    );
  }
}
