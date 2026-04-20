import 'package:flutter/material.dart';

import 'widgets/active_services.dart';
import 'widgets/installed_apps.dart';
import 'widgets/installed_page_header.dart';
import 'widgets/upgrade_alert_banner.dart';

class InstalledView extends StatelessWidget {
  const InstalledView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InstalledPageHeader(),
        const SizedBox(height: 48),
        const UpgradeAlertBanner(),
        const SizedBox(height: 48),
        LayoutBuilder(
          builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > 800;

            if (isWide) {
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: ActiveServices()),
                  SizedBox(width: 32),
                  Expanded(flex: 1, child: InstalledApps()),
                ],
              );
            }

            return const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ActiveServices(),
                SizedBox(height: 32),
                InstalledApps(),
              ],
            );
          },
        ),
      ],
    );
  }
}
