import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class WorkflowsView extends StatelessWidget {
  const WorkflowsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Workflows',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your automation sequences and environment setups.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        
        // Content List
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _WorkflowListTile(
              title: 'Full-Stack Env Setup',
              description: 'Installs Node.js, configures Git, and clones the core mono-repo.',
              lastRun: '2 days ago',
            ),
            SizedBox(height: 16),
            _WorkflowListTile(
              title: 'Node.js Microservice',
              description: 'Sets up a standard Node.js Express server template with Docker.',
              lastRun: '1 week ago',
            ),
            SizedBox(height: 16),
            _WorkflowListTile(
              title: 'Python Data Pipeline',
              description: 'Installs Python, Poetry, and pulls latest ML models.',
              lastRun: 'Never run',
            ),
          ],
        )
      ],
    );
  }
}

class _WorkflowListTile extends StatefulWidget {
  final String title;
  final String description;
  final String lastRun;

  const _WorkflowListTile({
    required this.title,
    required this.description,
    required this.lastRun,
  });

  @override
  State<_WorkflowListTile> createState() => _WorkflowListTileState();
}

class _WorkflowListTileState extends State<_WorkflowListTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovering 
                ? AppColors.primaryContainer 
                : AppColors.outlineVariant.withValues(alpha: 0.15),
            width: _isHovering ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.emerald50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.schema_rounded, color: AppColors.emerald700),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 12, color: AppColors.outline),
                      const SizedBox(width: 6),
                      Text(
                        'Last run: ${widget.lastRun}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Actions
            Row(
              children: [
                _ActionButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'Run',
                  color: AppColors.primary,
                  backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.1),
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  color: AppColors.error,
                  backgroundColor: AppColors.errorContainer.withValues(alpha: 0.3),
                  onTap: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
