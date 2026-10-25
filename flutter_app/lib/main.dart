import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/item_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/item_detail_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/search_screen.dart';
import 'screens/staff_dashboard_screen.dart';
import 'screens/staff_login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
      ],
      child: const BackpocketApp(),
    ),
  );
}

class BackpocketApp extends StatelessWidget {
  const BackpocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Backpocket — Campus Lost & Found',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/item-detail') {
          final itemId = settings.arguments as String? ?? '';
          return MaterialPageRoute(
            builder: (_) => ItemDetailScreen(itemId: itemId),
            settings: settings,
          );
        }

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LandingScreen(), settings: settings);
          case '/search':
            return MaterialPageRoute(builder: (_) => const SearchScreen(), settings: settings);
          case '/staff/login':
            return MaterialPageRoute(builder: (_) => const StaffLoginScreen(), settings: settings);
          case '/staff/dashboard':
            return MaterialPageRoute(builder: (_) => const StaffDashboardScreen(), settings: settings);
          default:
            return MaterialPageRoute(builder: (_) => const LandingScreen(), settings: settings);
        }
      },
    );
  }
}
