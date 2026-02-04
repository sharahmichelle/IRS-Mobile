import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/providers/activity_logs_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/event_totals_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/calendar_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/graphs_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/profile_screen.dart';

// ignore_for_file: unused_field, unused_local_variable

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 1;
  int _previousIndex = 1;
  
  // Color scheme matching graphs_screen
  static const Color _backgroundColor = Color(0xFFF8F9FA);
  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _primaryRed = Color(0xFFE63946);
  static const Color _textPrimary = Color(0xFF212529);
  static const Color _textSecondary = Color(0xFF6C757D);
  static const Color _textInactive = Color(0xFFADB5BD);

  // Animation controllers
  late AnimationController _pageController;
  late AnimationController _navScaleController;
  late AnimationController _navFadeController;
  late Animation<double> _navScaleAnimation;
  late Animation<double> _navFadeAnimation;

  // Pages
  final List<Widget> _pages = [
    const CalendarScreen(),
    const GraphsScreen(),
    const ProfileScreen(),
  ];

  // Navigation data
  final List<NavItemData> _navItems = [
    NavItemData(icon: Icons.calendar_month_rounded, label: "Events"),
    NavItemData(icon: Icons.dashboard_rounded, label: "Reports"),
    NavItemData(icon: Icons.person_rounded, label: "Profile"),
  ];

  @override
  void initState() {
    super.initState();
    
    // Page transition animation
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Navigation bar animations
    _navScaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _navFadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _navScaleAnimation = CurvedAnimation(
      parent: _navScaleController,
      curve: Curves.easeOutCubic,
    );
    
    _navFadeAnimation = CurvedAnimation(
      parent: _navFadeController,
      curve: Curves.easeOutCubic,
    );
    
    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _navFadeController.forward();
      _navScaleController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navScaleController.dispose();
    _navFadeController.dispose();
    super.dispose();
  }

  void _onNavItemTap(int index) {
    if (_currentIndex == index) return;
    
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
    
    // Play tap animation
    _navScaleController.forward(from: 0.0);
    
    // Trigger page transition
    _pageController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Page content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _pages[_currentIndex],
          ),
          
          // Modern navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildModernNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNavigationBar() {
    return AnimatedBuilder(
      animation: _navFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _navFadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - _navFadeAnimation.value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _primaryRed.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          height: 72, // Slightly increased for better spacing
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.black.withOpacity(0.04),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              return _buildNavItem(_navItems[index], index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItemData item, int index) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onNavItemTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _navScaleController,
        builder: (context, child) {
          final scale = isActive && _navScaleController.isAnimating
              ? 1.0 + (_navScaleAnimation.value * 0.1)
              : 1.0;
          
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 72, // Minimum width for each item
            maxWidth: 96,  // Maximum width to prevent overflow
          ),
          height: 72,
          alignment: Alignment.center,
          child: Container(
            width: 56, // Increased width for bigger icons
            height: 56, // Increased height for bigger icons
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background pulse for active state
                if (isActive)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Container(
                        width: 40 + (value * 12),
                        height: 40 + (value * 12),
                        decoration: BoxDecoration(
                          color: _primaryRed.withOpacity(0.08 * (1 - value)),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),

                // Bigger Icon
                Icon(
                  item.icon,
                  size: 28, // Increased from 22 to 28
                  color: isActive ? _primaryRed : _textInactive,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize providers on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Events>().fetchEvents();
      context.read<EventTotals>().fetchEventTotals();
      context.read<ActivityLogs>().fetchActivityLogs();
    });
  }
}

class NavItemData {
  final IconData icon;
  final String label;

  const NavItemData({required this.icon, required this.label});
}