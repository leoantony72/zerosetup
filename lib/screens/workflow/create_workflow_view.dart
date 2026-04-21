import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';
import 'widgets/workflow_card.dart';
import 'widgets/workflow_sidebar.dart';

class CreateWorkflowView extends StatefulWidget {
  const CreateWorkflowView({super.key});

  @override
  State<CreateWorkflowView> createState() => _CreateWorkflowViewState();
}

class _CreateWorkflowViewState extends State<CreateWorkflowView> {
  final TextEditingController _titleController = 
      TextEditingController(text: 'Untitled Full-Stack Env Setup');

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The main flow structure
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Center / Main Canvas
        Expanded(
          child: Container(
            color: AppColors.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                Expanded(child: _buildCanvas()),
              ],
            ),
          ),
        ),
        
        // Component Library Sidebar
        const WorkflowSidebar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Title Input & Meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28, // Almost 3xl
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.edit_rounded, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Drafting phase • Last auto-saved 2 mins ago',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text('Test Run'),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  foregroundColor: AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.publish_rounded, size: 16),
                label: const Text('Deploy Workflow'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                  shadowColor: AppColors.primary.withValues(alpha: 0.2),
                  textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                ).copyWith(
                  overlayColor: WidgetStateProperty.all(AppColors.primaryContainer),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Stack(
      children: [
        // Decorative Dot Background
        Positioned.fill(
          child: Opacity(
            opacity: 0.2, // Subtle grid
            child: GridPaper(
              color: AppColors.outline,
              divisions: 1,
              subdivisions: 1,
              interval: 24,
            ),
          ),
        ),

        // Scrollable content
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 96, top: 24),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 768),
                child: Column(
                  children: [
                    // Step 1: Install Node.js
                    WorkflowCard(
                      step: 1,
                      title: 'Install Node.js',
                      subtitle: 'Version manager setup via NVM. Target: v18.17.0 LTS.',
                      icon: Icons.terminal_rounded,
                      content: _buildNodeConfig(),
                    ),

                    // Step 2: Setup Git Config
                    WorkflowCard(
                      step: 2,
                      title: 'Setup Git Config',
                      subtitle: 'Configure global user, email, and credential helper.',
                      icon: Icons.commit_rounded,
                      isGit: true,
                      content: _buildGitConfig(),
                    ),

                    // Step 3: Clone Repo
                    WorkflowCard(
                      step: 3,
                      title: 'Clone Core Mono-Repo',
                      subtitle: 'Pulls the main application repository into the workspace.',
                      icon: Icons.folder_zip_rounded,
                      isGit: true,
                      isLast: true,
                      content: _buildCloneRepo(),
                    ),

                    // Add Dropzone
                    const SizedBox(height: 24),
                    _buildDropzone(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNodeConfig() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'GLOBAL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Use latest LTS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              )
            ],
          ),
          Switch(
            value: true, 
            onChanged: (val) {},
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildGitConfig() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'USER NAME',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  r'${env.GIT_USER}',
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EMAIL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  r'${env.GIT_EMAIL}',
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloneRepo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, size: 20, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            'git@github.com:org/core-mono.git',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropzone() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
            width: 2,
            style: BorderStyle.solid, 
            // In a real app we'd use dash pattern here with a package like dotted_border
          ),
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Drag a component here or click to add',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            )
          ],
        ),
      ),
    );
  }
}
