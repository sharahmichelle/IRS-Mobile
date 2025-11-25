import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/providers/activity_logs_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/calendar_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/dashboard_screen.dart';
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

  final List<Widget> _pageList = [
    CalendarScreen(),
    GraphsScreen(),
    ProfileScreen(),
  ];

  bool isAnalyticsEnabled = false;


  // Modern app bars with gradient and better typography
  late final Map<int, PreferredSizeWidget> _appBarList = {
    0: _buildModernAppBar(
      title: "Calendar",
    ),
    1: _buildModernAppBar(
      title: "Dashboard",
      actions: [
        _buildIconButton(
          icon: Icons.refresh_rounded,
          onPressed: () {
            context.read<Events>().fetchEvents();
            context.read<ActivityLogs>().fetchActivityLogs();
          },
        ),
        isAnalyticsEnabled?
        _buildIconButton(icon: Icons.analytics, onPressed: (){
          setState(() {
            isAnalyticsEnabled = !isAnalyticsEnabled;
            _pageList[1] = isAnalyticsEnabled ? DashboardScreen() : GraphsScreen();
          });
        }):
        _buildIconButton(icon: Icons.analytics_outlined, onPressed: (){
          setState(() {
            isAnalyticsEnabled = !isAnalyticsEnabled;
            _pageList[1] = isAnalyticsEnabled ? DashboardScreen() : GraphsScreen();
          });
        }),
      ],
    ),
    2: _buildModernAppBar(
      title: "Profile",
      actions: [
        _buildIconButton(
          icon: Icons.edit_outlined,
          onPressed: () {},
        ),
      ],
    ),
  };

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
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: textPrimary,
              letterSpacing: -0.5,
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
      context.read<ActivityLogs>().fetchActivityLogs();
      print("Fetched activity logs in Mainscreen");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarList[_page],
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
          width: 40,
          height: 40,
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
            size: 22,
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