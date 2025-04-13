import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:campus_cush_consumer/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'; // <-- Add this for kIsWeb

Future<void> initializeFirebase() async {
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Verify initialization was successful
      if (Firebase.apps.isNotEmpty) {
        debugPrint('Firebase initialized successfully');

        // Additional verification for web platform
        if (kIsWeb) {
          try {
            await FirebaseAuth.instance.authStateChanges().first;
            debugPrint('Firebase Auth web verification successful');
          } catch (e) {
            debugPrint('Firebase Auth web verification failed: $e');
            throw Exception('Failed to verify Firebase Auth on web');
          }
        }
      } else {
        throw Exception('Firebase initialization completed but no apps found');
      }
    }
  } on FirebaseException catch (e) {
    debugPrint('FirebaseException during initialization: ${e.message}');
    throw Exception('Firebase service error: ${e.message}');
  } catch (e, stackTrace) {
    debugPrint('General error during Firebase initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    throw Exception('Failed to initialize Firebase: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
    runApp(const MyApp());
  } catch (e) {
    // Fallback UI if Firebase fails to initialize
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Failed to initialize app: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await initializeFirebase();
                      runApp(const MyApp());
                    } catch (retryError) {
                      // Could show another error message here
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Cush Consumer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Handle different auth states here
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Your normal splash screen with Firebase ready
          return const SplashScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}