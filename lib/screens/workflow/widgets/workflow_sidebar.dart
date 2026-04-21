import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

class WorkflowSidebar extends StatelessWidget {
  const WorkflowSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          left: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 30,
            offset: const Offset(-10, 0),
          )
        ],
      ),
      child: Column(
        children: [
          // Sidebar Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Components',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                // Search Box
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Find module...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: AppColors.outline,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.outline,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
          
          // Categories
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCategory(
                  'Runtimes & SDKs',
                  [
                    _DraggableComponent(
                      title: 'Node.js',
                      subtitle: 'Runtime environment',
                      icon: Icons.terminal_rounded,
                      color: const Color(0xFF339933),
                    ),
                    _DraggableComponent(
                      title: 'Python',
                      subtitle: 'Setup pyenv & pip',
                      icon: Icons.code_rounded,
                      color: const Color(0xFF3776AB),
                    ),
                  ]
                ),
                const SizedBox(height: 24),
                _buildCategory(
                  'Source Control',
                  [
                    _DraggableComponent(
                      title: 'Git Config',
                      subtitle: 'Global user settings',
                      icon: Icons.commit_rounded,
                      color: AppColors.onSurface,
                      isNeutral: true,
                    ),
                    _DraggableComponent(
                      title: 'Clone Repo',
                      subtitle: 'Checkout workspace',
                      icon: Icons.folder_zip_rounded,
                      color: AppColors.onSurface,
                      isNeutral: true,
                    ),
                  ]
                ),
                const SizedBox(height: 24),
                _buildCategory(
                  'Databases',
                  [
                    _DraggableComponent(
                      title: 'PostgreSQL',
                      subtitle: 'Local instance via Docker',
                      icon: Icons.storage_rounded,
                      color: const Color(0xFF336791),
                    ),
                  ]
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategory(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _DraggableComponent extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isNeutral;

  const _DraggableComponent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isNeutral = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isNeutral 
                  ? AppColors.surfaceContainerHigh 
                  : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                )
              ],
            ),
          ),
          const Icon(
            Icons.drag_indicator_rounded,
            size: 18,
            color: AppColors.outlineVariant,
          ),
        ],
      ),
    );
  }
}
