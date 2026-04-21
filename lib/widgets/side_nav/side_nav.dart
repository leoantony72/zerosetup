import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/gradient_button.dart';

/// Data model for a single sidebar navigation item.
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

/// The fixed left-side navigation rail.
class SideNav extends StatelessWidget {
  final List<NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onNewWorkflowTap;

  const SideNav({
    super.key,
    required this.navItems,
    required this.selectedIndex,
    required this.onNavTap,
    this.onNewWorkflowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      color: AppColors.slate50,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Brand ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automation Core',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.emerald700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'The Fluid Architect',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),

          // ── Nav Items ─────────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: List.generate(
                navItems.length,
                (i) => NavTile(
                  item: navItems[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onNavTap(i),
                ),
              ),
            ),
          ),

          // ── New Workflow CTA ───────────────────────────────────────────────
          GradientButton(
            label: 'New Workflow',
            icon: Icons.add_rounded,
            onTap: onNewWorkflowTap,
          ),
        ],
      ),
    );
  }
}

/// Individual animated nav tile inside [SideNav].
class NavTile extends StatefulWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const NavTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<NavTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slide = Tween<double>(begin: 0, end: 4).animate(
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
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _slide,
          builder: (_, child) => Transform.translate(
            offset: Offset(_slide.value, 0),
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.emerald100.withValues(alpha: 0.5)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(
                  widget.item.icon,
                  size: 20,
                  color: widget.isSelected
                      ? AppColors.emerald700
                      : AppColors.slate500,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.item.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: widget.isSelected
                        ? AppColors.emerald700
                        : AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
