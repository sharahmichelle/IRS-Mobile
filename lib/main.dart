import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:upm_drrm_irs_mobile/firebase_options.dart';
import 'package:upm_drrm_irs_mobile/providers/activity_logs_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/event_totals_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/reports_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/users_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/add_event_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/login_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/main_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/signup_screen.dart';

// Firebase and Provider Initialization
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Events()),
        ChangeNotifierProvider(create: (context) => ActivityLogs()),
        ChangeNotifierProvider(create: (context) => EventTotals()),
        ChangeNotifierProvider(create: (context) => Reports()),
        ChangeNotifierProvider(create: (context) => Users()),
      ],
      child: const MyApp(),
    ),
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
        "/": (context) => const LoginScreen(),
        "/main": (context) => const MainScreen(),
        "/add_event": (context) => const AddEventScreen(),
        "/signup": (context) => const SignUpScreen(), 
      },
    );
  }
}
