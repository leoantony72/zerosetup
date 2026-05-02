import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/dialogs/installation_dialog.dart';
import '../../../widgets/dialogs/database_connection_dialog.dart';
import '../../../services/installation_service.dart';
import '../../../services/detection_service.dart';
import '../../../services/installation_manager.dart';
import '../../../services/icon_service.dart';
import '../models/library_models.dart';

class AppCard extends StatefulWidget {
  final AppItem item;

  const AppCard({super.key, required this.item});

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  void _startInstallation() async {
    if (widget.item.program == null) return;

    final confirmed = await InstallationDialog.show(
      context: context,
      title: 'Confirm Installation',
      subtitle: 'Review the details for ${widget.item.title} before continuing.',
      size: widget.item.program?.sizeMb,
      tools: [
        InstallationToolItem(
          name: '${widget.item.title} Package',
          description: 'Universal setup script',
          version: widget.item.version,
          isInstalled: false,
        ),
      ],
    );

    if (confirmed == true) {
      InstallationManager.instance.install(widget.item.program!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DetectionService.statusNotifier,
      builder: (context, child) {
        final id = widget.item.program?.id ?? '';
        final isInstalled = DetectionService.isInstalled(id) || 
                          InstallationManager.instance.getStatus(id) == InstallationStatus.success;
        final version = DetectionService.getVersion(id) ?? widget.item.version;
        final isInstalling = InstallationManager.instance.isInstalling(id);
        final progress = InstallationManager.instance.getProgress(id);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: _isHovered ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      )
                    ]
                  : [],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isHovered 
                              ? AppColors.primary.withValues(alpha: 0.2) 
                              : AppColors.outlineVariant.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Center(
                        child: widget.item.iconAsset != null
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: widget.item.iconAsset!.endsWith('.svg')
                                    ? SvgPicture.asset(
                                        widget.item.iconAsset!,
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          widget.item.icon,
                                          size: 22,
                                          color: widget.item.iconColor,
                                        ),
                                      )
                                    : Image.asset(
                                        widget.item.iconAsset!,
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          widget.item.icon,
                                          size: 22,
                                          color: widget.item.iconColor,
                                        ),
                                      ),
                              )
                            : Icon(
                                widget.item.icon,
                                size: 22,
                                color: widget.item.iconColor,
                              ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isInstalled 
                            ? AppColors.secondaryContainer 
                            : AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.item.typeLabel.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isInstalled 
                              ? AppColors.onSecondaryContainer 
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.item.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          version,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isInstalled)
                        ElevatedButton(
                          onPressed: () {
                            final prog = widget.item.program;
                            if (prog == null) return;
                            if (prog.isDatabase) {
                              DatabaseConnectionDialog.show(context, prog);
                            } else {
                              DetectionService.launchApp(prog);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainerHighest,
                            foregroundColor: AppColors.onSurface,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            textStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text(widget.item.program?.isDatabase == true ? 'MANAGE' : 'Open'),
                        )
                      else if (isInstalling)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    color: AppColors.primary,
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryContainer],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: _startInstallation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: AppColors.onPrimary,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Install'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
