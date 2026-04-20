import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/dialogs/installation_dialog.dart';
import '../models/persona_model.dart';

class PersonaCard extends StatefulWidget {
  final PersonaModel persona;
  const PersonaCard({super.key, required this.persona});

  @override
  State<PersonaCard> createState() => _PersonaCardState();
}

class _PersonaCardState extends State<PersonaCard> {
  bool _isHovered = false;

  void _showInstallDialog() {
    InstallationDialog.show(
      context: context,
      title: 'Proceed Installation',
      subtitle: 'Review the tools required for ${widget.persona.title} before continuing.',
      tools: [
        const InstallationToolItem(
          name: 'Git CLI',
          description: 'Version Control',
          version: '2.40+',
          isInstalled: true,
        ),
        const InstallationToolItem(
          name: 'Python',
          description: 'Core Language',
          version: '3.11',
          isInstalled: true,
        ),
        const InstallationToolItem(
          name: 'PostgreSQL',
          description: 'Database Engine',
          version: '15.0+',
          isInstalled: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _showInstallDialog,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outlineVariant.withAlpha(38),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            AnimatedScale(
              scale: _isHovered ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: widget.persona.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  border: widget.persona.title == 'Neural Architect'
                      ? Border.all(color: AppColors.outline.withAlpha(25))
                      : null,
                ),
                child: Center(
                  child: Icon(
                    widget.persona.icon,
                    size: 32,
                    color: widget.persona.iconColor,
                  ),
                ),
              ),
            ),
            
            Text(
              widget.persona.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.persona.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            
            const Spacer(),
            
            // Stack Includes
            const Text(
              'STACK INCLUDES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.outline,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.persona.stack.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.only(top: 24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.surfaceContainerHigh.withAlpha(128),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Deploy Stack',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isHovered ? AppColors.primaryContainer : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedSlide(
                    offset: _isHovered ? const Offset(0.2, 0) : Offset.zero,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: _isHovered ? AppColors.primaryContainer : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
