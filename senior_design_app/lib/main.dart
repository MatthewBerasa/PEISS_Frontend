import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'screens/login_screen.dart';
import 'screens/connected_screen.dart';
import 'screens/disconnected_screen.dart';
import 'Services/api_service.dart'; // Import the ApiService file
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart'; // Import JWT Decoder
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'firebase_options.dart';

void main() async {
  // Initialize time zones
  tz.initializeTimeZones();

  // Ensure widgets are bound
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize Firebase with platform-specific options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  // Configure Firebase Messaging
  final messaging = FirebaseMessaging.instance;
    
  // Request notification permissions (iOS specific)
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
    

  // Set up foreground message listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a foreground message: ${message.messageId}');
    // Optionally, display a local notification here using flutter_local_notifications.
  });

  // Set up listener for when a notification is tapped/opened
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('User tapped on a notification: ${message.messageId}');
    // Navigate to a specific screen if desired.
  });

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PEISS Senior Design App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey,
      ),
      home: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              bool isLoggedIn = snapshot.data as bool;
              if (!isLoggedIn) {
                return LoginScreen();
              }
              return FutureBuilder<Map<String, dynamic>>(
                future: _checkConnection(),
                builder: (context, connectionSnapshot) {
                  if (connectionSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (connectionSnapshot.hasData && connectionSnapshot.data != null) {
                    var isConnected = connectionSnapshot.data!['connectionStatus'] ?? false;
                    return isConnected ? ConnectedScreen() : DisconnectedScreen();
                  }
                  return LoginScreen(); // If connection check fails, go to login screen
                },
              );
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return Container(); // Fallback widget
        },
      ),
    );
  }

  // Check login status (whether the token exists and is not expired)
  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    if (accessToken == null) {
      return false;
    }
    try {
      // Decode the JWT token to check if it's expired
      final token = JWT.decode(accessToken);
      final payload = token.payload;
      // Get the expiration timestamp from the payload
      final exp = payload['exp'];
      if (exp == null) {
        return false; // No expiration, invalid token
      }
      // Check if the token is expired
      DateTime expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      if (expirationDate.isBefore(DateTime.now())) {
        return false; // Token expired
      }
      return true; // Token is valid
    } catch (e) {
      // If there's an error decoding the token, log out
      return false;
    }
  }

  // Check if the user is connected
  Future<Map<String, dynamic>> _checkConnection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');
    if (userID == null) {
      return {}; // Return empty response if userID is not found
    }
    try {
      var response = await ApiService.checkConnection(userID.toString());
      if(response['error'] != null){
        return {};
      } else {
        return {'connectionStatus': response['connectionStatus']};
      }
    } catch (error) {
      return {}; // Return empty response in case of an error
    }
  }
}
