import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/common/gradient_button.dart';
import '../../../../widgets/common/tonal_button.dart';

class InstalledHeader extends StatelessWidget {
  const InstalledHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final children = [
          Expanded(
            flex: isWide ? 1 : 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Installed Systems',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isWide ? 48 : 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: AppColors.onSurface,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your active services, environments, and applications. Everything is running smoothly in the Fluid Architect space.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    color: AppColors.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          if (isWide) const SizedBox(width: 24),
          if (!isWide) const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TonalButton(
                label: 'Sync All',
                icon: Icons.sync_rounded,
              ),
              SizedBox(width: 12),
              GradientButton(
                label: 'Install New',
                icon: Icons.add_rounded,
              ),
            ],
          ),
        ];

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        }
      },
    );
  }
}
