import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';
import 'package:upm_drrm_irs_mobile/providers/activity_logs_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/event_totals_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/calendar_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/table_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/graphs_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _page = 1;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  
  // Modern color scheme
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color primaryColor = Color(0xFFA11D1C);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = Color(0xFF1E293B);
  final Color textSecondary = Color(0xFF64748B);
  final Color iconColor = Color(0xFF475569);
  
  // Modern shadows
  final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  bool isAnalyticsEnabled = false;

  // Don't pre-initialize the page list, build it dynamically
  List<Widget> get _pageList => [
    CalendarScreen(),
    isAnalyticsEnabled ? TableScreen() : GraphsScreen(),
    ProfileScreen(),
  ];

  PreferredSizeWidget _buildAppBar() {
    switch (_page) {
      case 0:
        return _buildModernAppBar(title: "Calendar");
      case 1:
        return _buildModernAppBar(
          title: "Dashboard",
          actions: [
            _buildIconButton(
              icon: Icons.refresh_rounded,
              onPressed: () {
                context.read<Events>().fetchEvents();
                context.read<ActivityLogs>().fetchActivityLogs();
              },
            ),
            _buildViewToggle(),
          ],
        );
      case 2:
        return _buildModernAppBar(
          title: "Profile",
          actions: [
            _buildIconButton(
              icon: Icons.edit_outlined,
              onPressed: () {},
            ),
          ],
        );
      default:
        return _buildModernAppBar(title: "Dashboard");
    }
  }

  Widget _buildViewToggle() {
    return Container(
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [cardShadow],
      ),
      child: TextButton(
        onPressed: _toggleView,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAnalyticsEnabled ? Icons.bar_chart : Icons.table_chart,
              size: 18,
              color: primaryColor,
            ),
            SizedBox(width: 6),
            Text(
              isAnalyticsEnabled ? "Graph" : "Table",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleView() {
    setState(() {
      isAnalyticsEnabled = !isAnalyticsEnabled;
      // The page list will be rebuilt automatically due to the getter
    });
  }

  PreferredSizeWidget _buildModernAppBar({
    required String title,
    List<Widget>? actions,
  }) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: surfaceColor,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, Color(0xFFC62828)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/favicon.png',
                width: 20,
                height: 20,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [cardShadow],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor),
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Events>().fetchEvents();
      print("Fetched events in MainScreen");
      context.read<EventTotals>().fetchEventTotals();
      print("Fetched event totals in MainScreen");
      context.read<ActivityLogs>().fetchActivityLogs();
      print("Fetched activity logs in Mainscreen");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, Color(0xFFF1F5F9)],
          ),
        ),
        child: IndexedStack(index: _page, children: _pageList),
      ),
      bottomNavigationBar: _buildModernNavigationBar(),
    );
  }

  Widget _buildModernNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: CurvedNavigationBar(
        color: surfaceColor,
        index: _page,
        buttonBackgroundColor: primaryColor,
        backgroundColor: Colors.transparent,
        key: _bottomNavigationKey,
        height: 70,
        animationCurve: Curves.easeInOutCubic,
        animationDuration: Duration(milliseconds: 400),
        items: <Widget>[
          _buildNavItem(
            icon: Icons.calendar_month_rounded,
            label: "Calendar",
            isActive: _page == 0,
          ),
          _buildNavItem(
            icon: Icons.dashboard_rounded,
            label: "Dashboard",
            isActive: _page == 1,
          ),
          _buildNavItem(
            icon: Icons.person_rounded,
            label: "Profile",
            isActive: _page == 2,
          ),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: isActive
              ? BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: Icon(
            icon,
            size: 25,
            color: isActive ? Colors.white : iconColor,
          ),
        ),
        SizedBox(height: 4),
        isActive?
        SizedBox(width: 1,)
        :
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? primaryColor : textSecondary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}