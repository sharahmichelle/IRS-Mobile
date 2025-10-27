import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/screens/calendar_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/dashboard_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _page = 1;
  Color myGrey = Color(0xFFECECEC);
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final Color primaryColor = Color.fromARGB(255, 161, 29, 28);
  
  // screen per division (Based on BottomNavBar)
  final List<Widget> _pageList = [
    CalendarScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];

  // appBar per screen (top)
  final Map<int, PreferredSizeWidget> _appBarList = {

    // 2: AppBar(
    //     automaticallyImplyLeading: false,
    //     backgroundColor: Color(0xFFECECEC),
    //     title: Padding(
    //       padding: EdgeInsets.all(8),
    //       child: Text(
    //         "Dashboard",
    //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
    //       ),
    //     ),
    //     actions: <Widget>[
    //       DropdownButton<String>(
    //         value: 'UP System',
    //         icon: const Icon(Icons.keyboard_arrow_down),
    //         elevation: 16,
    //         style: const TextStyle(color: Color.fromARGB(255, 20, 99, 50), fontSize: 16),
    //         underline: Container(
    //           height: 2,
    //           color: Color.fromARGB(255, 20, 99, 50),
    //         ),
    //         items: [
    //           'UP System',
    //           'Campus',
    //           'College',
    //         ].map<DropdownMenuItem<String>>((String value) {
    //           return DropdownMenuItem<String>(
    //             value: value,
    //             child: Text(value),
    //           );
    //         }).toList(),
    //         onChanged: (value) => {
              
    //         },
    //         )
    //         ],
    //   ),
    // 3: AppBar(
    //     automaticallyImplyLeading: false,
    //     backgroundColor: Color(0xFFECECEC),
    //     title: Padding(
    //       padding: EdgeInsets.all(8),
    //       child: Text(
    //         "Encoding History",
    //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
    //       ),
    //     ),
    //   ),
        0: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFECECEC),
        title: Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            "Calendar",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ),
        // actions: [
        //   IconButton(onPressed: () {}, icon: Icon(Icons.add_card_outlined)),
        // ],
      ),

          1: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFECECEC),
        title: Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            "Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ),
        // actions: <Widget>[
        //   DropdownButton<String>(
        //     value: 'UP System',
        //     icon: const Icon(Icons.keyboard_arrow_down),
        //     elevation: 16,
        //     style: const TextStyle(color: Color.fromARGB(255, 20, 99, 50), fontSize: 16),
        //     underline: Container(
        //       height: 2,
        //       color: Color.fromARGB(255, 20, 99, 50),
        //     ),
        //     items: [
        //       'UP System',
        //       'Campus',
        //       'College',
        //     ].map<DropdownMenuItem<String>>((String value) {
        //       return DropdownMenuItem<String>(
        //         value: value,
        //         child: Text(value),
        //       );
        //     }).toList(),
        //     onChanged: (value) => {
              
        //     },
        //     )
        //     ],
      ),
    
    2: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFECECEC),
        title: Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            "Profile",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: IconButton(
              onPressed: () => {},
              icon: Icon(Icons.edit_outlined),
            ),
          ),
        ],
      ),
  };

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<Events>().fetchEvents(); 
  //     print("Fetched events in MainScreen");
  //   });
  // }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarList[_page],
      backgroundColor: myGrey,
      bottomNavigationBar: CurvedNavigationBar(
          color: myGrey,
          index: 0,
          buttonBackgroundColor: primaryColor,
          backgroundColor: myGrey,
          key: _bottomNavigationKey,
          height: 70,
          items: <Widget>[
            Icon(Icons.calendar_month_outlined, size: 30, color: _page==0? myGrey: Colors.black,),
            // Icon(Icons.keyboard, size: 30, color: _page==1? myGrey: Colors.black),
            Icon(Icons.dashboard_outlined, size: 30, color: _page==1? myGrey: Colors.black),
            // Icon(Icons.timelapse, size: 30, color: _page==3? myGrey: Colors.black,),
            Icon(Icons.account_circle_outlined, size: 30, color: _page==2? myGrey: Colors.black,),
          ],
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
        ),
      
      body: IndexedStack(
        index: _page,
        children: _pageList,
      ),
    );
  }
}