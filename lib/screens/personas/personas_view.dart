import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'widgets/personas_hero.dart';
import 'widgets/persona_card.dart';
import 'widgets/featured_persona_card.dart';
import 'models/persona_model.dart';

class PersonasView extends StatelessWidget {
  const PersonasView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 800) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 2;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Global background blur/glow decoration
            Positioned(
              top: -96,
              right: -96,
              child: Container(
                width: 384,
                height: 384,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer.withAlpha(51),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withAlpha(51),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PersonasHero(),
                const SizedBox(height: 64),
                
                // Grid for standard personas
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 32,
                    mainAxisSpacing: 32,
                    mainAxisExtent: 460, // Increased height to prevent text overflow
                  ),
                  itemCount: mockPersonas.length,
                  itemBuilder: (context, index) {
                    return PersonaCard(persona: mockPersonas[index]);
                  },
                ),
                
                // Featured persona card
                const FeaturedPersonaCard(),
                
                // Bottom spacing as in HTML
                const SizedBox(height: 96),
              ],
            ),
          ],
        );
      },
    );
  }
}
