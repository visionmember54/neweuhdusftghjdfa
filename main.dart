import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/app_colors.dart';
import 'config/app_constants.dart';
import 'screens/splash/splash_screen.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Push Notifications (Firebase Messaging + Local Notifications with Sound)
  await NotificationService.instance.initialize(
    onNotificationTapped: (payload) {
      debugPrint("Notification tapped: $payload");
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emerald,
          primary: AppColors.emerald,
          secondary: AppColors.gold,
          surface: AppColors.white,
          brightness: Brightness.light,
        ),
        primaryColor: AppColors.emerald,
        scaffoldBackgroundColor: AppColors.canvasBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.white,
          elevation: 2,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.dmSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
