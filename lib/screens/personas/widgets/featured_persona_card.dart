import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/dialogs/installation_dialog.dart';

class FeaturedPersonaCard extends StatelessWidget {
  const FeaturedPersonaCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 1024;

    return Container(
      margin: const EdgeInsets.only(top: 32),
      decoration: BoxDecoration(
        color: AppColors.inverseSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 60,
            offset: const Offset(0, 30),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Align(
                alignment: isSmallScreen ? Alignment.topCenter : Alignment.centerRight,
                child: Container(
                  width: isSmallScreen ? double.infinity : MediaQuery.of(context).size.width * 0.5,
                  height: isSmallScreen ? 300 : double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryContainer.withAlpha(51), Colors.transparent],
                      begin: isSmallScreen ? Alignment.topCenter : Alignment.centerRight,
                      end: isSmallScreen ? Alignment.bottomCenter : Alignment.centerLeft,
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 32 : 48,
                vertical: isSmallScreen ? 32 : 48,
              ),
              child: isSmallScreen ? _buildVertical(context) : _buildHorizontal(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _buildTextContent(context),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 2,
            child: _buildGraphic(),
          )
        ],
      ),
    );
  }

  Widget _buildVertical(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 250, child: _buildGraphic()),
        const SizedBox(height: 32),
        _buildTextContent(context),
      ],
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.new_releases, size: 16, color: AppColors.primaryFixedDim),
              SizedBox(width: 8),
              Text(
                'New Persona',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryFixedDim,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Data Science Canvas',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.inverseOnSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Dive into complex datasets immediately. Pre-loaded with R, Python data libraries, and visual exploration tools. Skip the environment setup and go straight to insights.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.surfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton(
              onPressed: () {
                InstallationDialog.show(
                  context: context,
                  title: 'Proceed Installation',
                  subtitle: 'Review the tools required for Data Science Canvas before continuing.',
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryFixed,
                foregroundColor: AppColors.onPrimaryFixed,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                elevation: 4,
                shadowColor: Colors.black.withAlpha(100),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Launch Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.inverseOnSurface,
                backgroundColor: Colors.white.withAlpha(25),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGraphic() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surface.withAlpha(25), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withAlpha(25)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: 0.6,
          child: Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBRpfohLV5znfDbYHapuSdR836lo7xBSRN-ao0ZScJbTcRuXLetnmc5TTJssgXa4wbdG-BB7c1JwGzauSWmyWelahup3guKBn5XprZOk_lC4KCY5aQX7F3YhLp8vmDjZCb0negz3-4bt5s2RFsHzWRQD0DURHMxnGnbu1WsGM1GuAc4xsjEaS22EkVJvneBQvyNgIXyVQSOKTmprnGNwD14Cm_h8xUBCBnkWehDaPEY_hx9qQimoZP6-TxGg-Clwir3Bo3So-420bk',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.primaryContainer.withAlpha(25),
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.white24, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
