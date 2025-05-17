import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/citizen_dashboard.dart';
import 'screens/supplier_dashboard.dart';
import 'screens/dashboard_screen.dart';
import 'screens/funding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Management',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        colorScheme: ColorScheme.dark(
          primary: Colors.green,
          secondary: Colors.greenAccent,
          surface: const Color(0xFF2A2A2A),
          background: const Color(0xFF1A1A1A),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/citizen': (context) => const CitizenDashboard(),
        '/supplier': (context) => const SupplierDashboard(),
        '/dashboard': (context) => const DashboardScreen(),
        '/funding': (context) => const FundingScreen(),
      },
    );
  }
}

class FirebaseConnectionTest extends StatefulWidget {
  const FirebaseConnectionTest({super.key});

  @override
  State<FirebaseConnectionTest> createState() => _FirebaseConnectionTestState();
}

class _FirebaseConnectionTestState extends State<FirebaseConnectionTest> {
  String _connectionStatus = 'Checking Firebase connection...';
  bool _isLoading = true;
  bool _isRetrying = false;
  int _retryCount = 0;
  static const int maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing Firebase services...';
    });

    try {
      // Test Firestore write
      final writeDoc = await FirebaseFirestore.instance
          .collection('test')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'test': 'Firebase connection test',
      });
      
      // Test Firestore read
      final readDoc = await FirebaseFirestore.instance
          .collection('test')
          .doc(writeDoc.id)
          .get();

      // Test Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('test/connection_test.txt');
      await storageRef.putString('Connection test');
      await storageRef.delete();

      setState(() {
        _connectionStatus = '''
Firebase connection successful!
✓ Firestore Write Test
✓ Firestore Read Test
✓ Storage Test
All systems operational''';
        _isLoading = false;
        _isRetrying = false;
      });

      // Clean up test document
      await writeDoc.delete();

    } catch (e) {
      print('Firebase connection error: $e');
      if (_retryCount < maxRetries) {
        _retryCount++;
        setState(() {
          _isRetrying = true;
          _connectionStatus = 'Connection attempt $_retryCount of $maxRetries failed.\nRetrying in 2 seconds...';
        });
        await Future.delayed(const Duration(seconds: 2));
        await _checkConnection();
      } else {
        setState(() {
          _connectionStatus = '''
Firebase connection error!
Error details: ${e.toString()}
Please check your internet connection and Firebase configuration.
Tap retry to test again.''';
          _isLoading = false;
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connection Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      _connectionStatus,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                )
              else
                Text(
                  _connectionStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 20),
              if (!_isLoading && !_isRetrying)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _retryCount = 0;
                        _checkConnection();
                      },
                      child: const Text('Retry Test'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: const Text('Continue to App'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
