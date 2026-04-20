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
        maxCrossAxisExtent: 400,
        mainAxisExtent: 340,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return AppCard(item: apps[index]);
      },
    );
  }
}
