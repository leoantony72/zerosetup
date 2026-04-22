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
        const ActiveServices(),
        const SizedBox(height: 48),
        const Divider(height: 1),
        const SizedBox(height: 48),
        const InstalledApps(),
        const SizedBox(height: 48),
      ],
    );
  }
}
