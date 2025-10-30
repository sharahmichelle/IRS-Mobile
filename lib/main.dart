import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/screens/add_event_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/main_screen.dart';

// Firebase and Provider Initialization
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPM-DRRMH-IRS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 1, 26, 253),
        ),
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const MainScreen(),
        "/add_event": (context) => const AddEventScreen(),
      },
    );
  }
}
