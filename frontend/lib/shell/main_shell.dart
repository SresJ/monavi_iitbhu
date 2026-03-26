import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../config/breakpoints.dart';
import '../config/design_tokens.dart';
import '../providers/auth_provider.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/dashboard/dashboard_screen_v2.dart';
import '../screens/patients/patient_list_screen.dart';

/// Lets descendants switch main tabs without [Navigator.pushNamed] (avoids stacked shells).
class MainShellScope extends InheritedWidget {
  const MainShellScope({
    super.key,
    required this.selectTab,
    required super.child,
  });

  final ValueChanged<int> selectTab;

  /// 0 = dashboard, 1 = patients, 2 = analytics
  static void goToTab(BuildContext context, int index) {
    context.getInheritedWidgetOfExactType<MainShellScope>()?.selectTab(index);
  }

  @override
  bool updateShouldNotify(covariant MainShellScope oldWidget) => false;
}

/// Main app chrome: primary tabs + shared app bar (notifications, logout).
///
/// Narrow: [NavigationBar]. Wide ([Breakpoints.landingDesktopMinWidth]): [NavigationRail].
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});

  /// 0 = dashboard, 1 = patients, 2 = analytics
  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab.clamp(0, 2);
  }

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _index = widget.initialTab.clamp(0, 2);
    }
  }

  static const List<String> _titles = ['Dashboard', 'People', 'Analytics'];

  void _onSelectTab(int i) {
    setState(() => _index = i.clamp(0, 2));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = Breakpoints.isLandingDesktopWidth(width);

    final stack = IndexedStack(
      index: _index,
      sizing: StackFit.expand,
      children: const [
        DashboardScreenV2(),
        PatientListScreen(),
        AnalyticsScreen(),
      ],
    );

    return MainShellScope(
      selectTab: _onSelectTab,
      child: Scaffold(
        backgroundColor: DesignTokens.voidBlack,
        appBar: AppBar(
          backgroundColor: DesignTokens.surfaceBlack,
          elevation: 0,
          title: Text(_titles[_index], style: DesignTokens.headingSmall),
          actions: [
            _ShellBarIconButton(
              icon: Iconsax.notification,
              tooltip: 'Notifications',
              badge: 3,
              onTap: () {},
            ),
            _ShellBarIconButton(
              icon: Iconsax.logout,
              tooltip: 'Sign out',
              onTap: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: useRail
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: _onSelectTab,
                    backgroundColor: DesignTokens.surfaceBlack,
                    indicatorColor: DesignTokens.medicalBlue.withOpacity(0.25),
                    selectedIconTheme: const IconThemeData(
                      color: DesignTokens.clinicalTeal,
                      size: 24,
                    ),
                    unselectedIconTheme: const IconThemeData(
                      color: DesignTokens.textTertiary,
                      size: 22,
                    ),
                    selectedLabelTextStyle: DesignTokens.labelMedium.copyWith(
                      color: DesignTokens.clinicalTeal,
                    ),
                    unselectedLabelTextStyle: DesignTokens.labelSmall.copyWith(
                      color: DesignTokens.textTertiary,
                    ),
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Iconsax.health),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Iconsax.people),
                        label: Text('People'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Iconsax.chart),
                        label: Text('Analytics'),
                      ),
                    ],
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: DesignTokens.borderGray.withOpacity(0.5),
                  ),
                  Expanded(child: stack),
                ],
              )
            : stack,
        bottomNavigationBar: useRail
            ? null
            : NavigationBar(
                height: 72,
                backgroundColor: DesignTokens.surfaceBlack,
                indicatorColor: DesignTokens.medicalBlue.withOpacity(0.2),
                surfaceTintColor: Colors.transparent,
                selectedIndex: _index,
                onDestinationSelected: _onSelectTab,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Iconsax.health),
                    selectedIcon: Icon(Iconsax.health),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Iconsax.people),
                    selectedIcon: Icon(Iconsax.people),
                    label: 'People',
                  ),
                  NavigationDestination(
                    icon: Icon(Iconsax.chart),
                    selectedIcon: Icon(Iconsax.chart),
                    label: 'Analytics',
                  ),
                ],
              ),
      ),
    );
  }
}

class _ShellBarIconButton extends StatelessWidget {
  const _ShellBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: DesignTokens.textSecondary),
          if (badge != null)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: DesignTokens.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$badge',
                  textAlign: TextAlign.center,
                  style: DesignTokens.labelSmall.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
      onPressed: onTap,
      constraints: const BoxConstraints(
        minWidth: Breakpoints.minTouchTarget,
        minHeight: Breakpoints.minTouchTarget,
      ),
    );
  }
}
