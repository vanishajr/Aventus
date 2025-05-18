import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/citizen_dashboard.dart';
import 'screens/supplier_dashboard.dart';
import 'screens/dashboard_screen.dart';
import 'screens/funding_screen.dart';
import 'screens/provide_assistance_screen.dart';
import 'screens/supply_assistant_screen.dart';
import 'screens/disaster_education_screen.dart';
import 'screens/supplier_ai_assistant.dart';
import 'config/supabase.dart';
import 'theme/app_theme.dart';
import 'providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add error handling for platform channels
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      theme: AppTheme.theme,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.orange, size: 60),
              const SizedBox(height: 16),
              Text(
                'Error: ${details.exception}',
                style: const TextStyle(color: AppTheme.orange),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };

  try {
    await SupabaseConfig.initialize();
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
    runApp(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, color: AppTheme.orange, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'Failed to connect to the server',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: $e',
                  style: const TextStyle(color: AppTheme.orange),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.greenGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.elevation1,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      main();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Retry Connection'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Disaster Management',
      theme: AppTheme.theme,
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/citizen': (context) => const CitizenDashboard(),
        '/supplier': (context) => const SupplierDashboard(),
        '/dashboard': (context) => const DashboardScreen(),
        '/funding': (context) => const FundingScreen(),
        '/provide_assistance': (context) => const ProvideAssistanceScreen(),
        '/supply-assistant': (context) => const SupplyAssistantScreen(),
        '/disaster-education': (context) => const DisasterEducationScreen(),
        '/ai-assistant': (context) => const SupplierAIAssistant(),
      },
    );
  }
}
