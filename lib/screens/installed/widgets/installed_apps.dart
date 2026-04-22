import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import '../../../../models/program.dart';
import '../../../../services/program_service.dart';
import '../../../../services/detection_service.dart';
import '../../../../services/icon_service.dart';

class InstalledApps extends StatefulWidget {
  const InstalledApps({super.key});

  @override
  State<InstalledApps> createState() => _InstalledAppsState();
}

class _InstalledAppsState extends State<InstalledApps> {
  @override
  void initState() {
    super.initState();
    // Programs should be loading in background from main.dart
    if (ProgramService.cachedPrograms == null) {
      ProgramService.loadPrograms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Applications',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            IconButton(
              onPressed: () {
                final programs = ProgramService.cachedPrograms;
                if (programs != null) {
                  DetectionService.checkAll(programs, forceRefresh: true);
                }
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              tooltip: 'Refresh Status',
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: DetectionService.statusNotifier,
          builder: (context, child) {
            final programs = ProgramService.cachedPrograms;
            
            if (programs == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final installedPrograms = programs.where((p) => DetectionService.isInstalled(p.id)).toList();
            
            if (installedPrograms.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.apps_rounded, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.1)),
                      const SizedBox(height: 16),
                      Text(
                        'No applications detected as installed.',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Install them from the Library to see them here.',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 1;
                if (constraints.maxWidth > 550) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 280) {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 84,
                  ),
                  itemCount: installedPrograms.length,
                  itemBuilder: (context, index) {
                    return CompactAppCard(
                      key: ValueKey(installedPrograms[index].id),
                      program: installedPrograms[index],
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class CompactAppCard extends StatefulWidget {
  final Program program;

  const CompactAppCard({
    super.key,
    required this.program,
  });

  @override
  State<CompactAppCard> createState() => _CompactAppCardState();
}

class _CompactAppCardState extends State<CompactAppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DetectionService.statusNotifier,
      builder: (context, child) {
        final appItem = widget.program.toAppItem();
        final version = DetectionService.getVersion(widget.program.id) ?? widget.program.version;

        return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _hovered
                  ? AppColors.surfaceContainerLow
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered 
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.outlineVariant.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: appItem.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: appItem.iconAsset != null
                        ? Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: appItem.iconAsset!.endsWith('.svg')
                                ? SvgPicture.asset(
                                    appItem.iconAsset!,
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      appItem.icon,
                                      size: 18,
                                      color: appItem.iconColor,
                                    ),
                                  )
                                : Image.asset(
                                    appItem.iconAsset!,
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      appItem.icon,
                                      size: 18,
                                      color: appItem.iconColor,
                                    ),
                                  ),
                          )
                        : Icon(
                            appItem.icon,
                            color: appItem.iconColor,
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.program.programName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        version,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_hovered)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => DetectionService.launchApp(widget.program),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.launch_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
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
