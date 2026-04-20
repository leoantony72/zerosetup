import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../widgets/common/outline_button.dart' as app_buttons;

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────

/// Full hero section: welcome copy on the left, system status card on the right.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 700;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(child: _HeroText()),
              SizedBox(width: 32),
              SizedBox(width: 360, child: SystemStatusCard()),
            ],
          );
        }

        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroText(),
            SizedBox(height: 24),
            SystemStatusCard(),
          ],
        );
      },
    );
  }
}

// ─── Welcome copy ─────────────────────────────────────────────────────────────

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 46,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1,
              color: AppColors.onSurface,
            ),
            children: const [
              TextSpan(text: 'Good Morning,\n'),
              TextSpan(
                text: 'Architect.',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your environments are stable. The AI Developer persona\n'
          'is currently analyzing your latest commits in the staging branch.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurfaceVariant,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            GradientButton(
              label: 'Launch Terminal',
              icon: Icons.terminal_rounded,
            ),
            const SizedBox(width: 12),
            app_buttons.OutlineButton(label: 'View Logs'),
          ],
        ),
      ],
    );
  }
}

// ─── System Status Card ───────────────────────────────────────────────────────

/// Card showing live system health indicators.
class SystemStatusCard extends StatefulWidget {
  const SystemStatusCard({super.key});

  @override
  State<SystemStatusCard> createState() => _SystemStatusCardState();
}

class _SystemStatusCardState extends State<SystemStatusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _lift;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _lift = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _lift,
        builder: (_, child) =>
            Transform.translate(offset: Offset(0, _lift.value), child: child),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.06),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'System Status',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primaryContainer,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Rows
              _StatusRow(label: 'Core API', status: 'Operational'),
              _divider(),
              _StatusRow(label: 'Database Cluster', status: 'Operational'),
              _divider(),
              _StatusRow(label: 'Background Workers', status: 'Operational'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => const Divider(
    color: AppColors.surfaceContainer,
    height: 1,
    thickness: 1,
  );
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String status;

  const _StatusRow({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
