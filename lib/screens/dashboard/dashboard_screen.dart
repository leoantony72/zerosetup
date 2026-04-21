import 'package:flutter/material.dart';
import '../../widgets/side_nav/side_nav.dart';
import '../../widgets/top_bar/floating_top_bar.dart';
import 'sections/hero_section.dart';
import 'sections/personas_section.dart';
import '../installed/installed_view.dart';
import '../library/library_view.dart';
import '../personas/personas_view.dart';
import '../settings/settings_view.dart';
import '../workflow/create_workflow_view.dart';
import '../workflow/workflows_view.dart';
import '../../theme/app_colors.dart';

// ─── Nav route data ────────────────────────────────────────────────────────────
const List<NavItem> _kNavItems = [
  NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
  NavItem(icon: Icons.folder_open_rounded, label: 'Library'),
  NavItem(icon: Icons.download_done_rounded, label: 'Installed'),
  NavItem(icon: Icons.psychology_rounded, label: 'Personas'),
  NavItem(icon: Icons.schema_rounded, label: 'Workflows'),
  NavItem(icon: Icons.settings_rounded, label: 'Settings'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Root screen of the app. Lays out [SideNav] + scrollable main content canvas
/// with a [FloatingTopBar] overlaid at the top of the canvas.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF4), // AppColors.background
      body: Row(
        children: [
          // ── Fixed Left Sidebar ─────────────────────────────────────────────
          SideNav(
            navItems: _kNavItems,
            selectedIndex: _selectedNavIndex,
            onNavTap: (i) => setState(() => _selectedNavIndex = i),
            onNewWorkflowTap: () => setState(() => _selectedNavIndex = 6),
          ),

          // ── Main Canvas ────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Scrollable page sections
                _selectedNavIndex == 6 
                    ? Padding( // Workflow builder has custom scrolling/layout
                        padding: const EdgeInsets.only(top: 80),
                        child: _buildBody(_selectedNavIndex),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          top: 100,
                          left: 40,
                          right: 40,
                          bottom: 40,
                        ),
                        child: _buildBody(_selectedNavIndex),
                      ),

                // Floating glass top bar pinned to top of canvas
                const Positioned(
                  top: 12,
                  left: 24,
                  right: 16,
                  child: FloatingTopBar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const _DashboardBody();
      case 1:
        return const LibraryView();
      case 2:
        return const InstalledView();
      case 3:
        return const PersonasView();
      case 4:
        return const WorkflowsView();
      case 5:
        return const SettingsView();
      case 6:
        return const CreateWorkflowView();
      default:
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Text(
              'Under Construction',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Body  (all scrollable sections)
// ─────────────────────────────────────────────────────────────────────────────

/// Composes all individual dashboard sections vertically.
/// Add new sections here as the dashboard grows.
class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroSection(),
        SizedBox(height: 52),
        PersonasSection(),
        SizedBox(height: 40),
        // TODO: Add more sections here (Analytics, Recent Activity, etc.)
      ],
    );
  }
}
