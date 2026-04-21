import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

class WorkflowCard extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget content;
  final bool isLast;
  final bool isGit;

  const WorkflowCard({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.content,
    this.isLast = false,
    this.isGit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The main card block
          Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isGit 
                        ? AppColors.surfaceContainer 
                        : AppColors.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isGit 
                          ? AppColors.onSurfaceVariant 
                          : AppColors.onSecondaryContainer,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Texts and Controls
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          StatefulBuilder(
                            builder: (context, setState) {
                              bool isHovered = false;
                              return MouseRegion(
                                onEnter: (_) => setState(() => isHovered = true),
                                onExit: (_) => setState(() => isHovered = false),
                                cursor: SystemMouseCursors.click,
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: isHovered 
                                      ? AppColors.error 
                                      : Colors.transparent,
                                ),
                              );
                            }
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Dynamic content injection
                      content,
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Step circle badge
          Positioned(
            left: 0,
            top: 40, // Half of card top padding approx
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ]
              ),
              child: Center(
                child: Text(
                  step.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          // Connection Line Custom Drawing
          if (!isLast)
            Positioned(
              left: 32 + 16, // Indent inside the card 
              bottom: -24,
              child: Container(
                width: 2,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      step == 1 ? AppColors.primary.withValues(alpha: 0.3) : AppColors.outlineVariant.withValues(alpha: 0.3),
                      AppColors.outlineVariant.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
