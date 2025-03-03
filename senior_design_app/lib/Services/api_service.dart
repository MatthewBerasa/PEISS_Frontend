import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ApiService {
  // Base URL of your API (make sure it's correct and points to your backend server)
  static final String baseUrl = 'http://64.227.10.20:5000/api';

  // Method for logging in
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    return json.decode(response.body); 
  }

  // Method for registering a user
  static Future<Map<String, dynamic>> register(String email, String password, String fcmToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'fcmToken': fcmToken}),
    );

    return json.decode(response.body); 
  }

  // Method for requesting a verification code
  static Future<Map<String, dynamic>> requestVerificationCode(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verification'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    return json.decode(response.body); 
  }

  // Method for providing settings
  static Future<Map<String, dynamic>> provideSettings(String deviceID) async {
    final response = await http.get(
      Uri.parse('$baseUrl/provideSettings?deviceID=$deviceID'),
    );

    return json.decode(response.body); 
  }

  // Method to update settings
  static Future<Map<String, dynamic>> updateSettings(String deviceID, bool alarmSetting, bool notificationSetting) async {
    final response = await http.post(
      Uri.parse('$baseUrl/updateSettings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'deviceID': deviceID,
        'alarmSetting': alarmSetting,
        'notificationSetting': notificationSetting,
      }),
    );

    return json.decode(response.body); 
  }

  // Method for getting activity logs
  static Future<Map<String, dynamic>> getLogs(String deviceID) async {
    final response = await http.get(
      Uri.parse('$baseUrl/getLogs?deviceID=$deviceID'),
    );

    return json.decode(response.body); 
  }

  // Method for adding an activity log
  static Future<Map<String, dynamic>> addActivityLog(String deviceID, String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/addActivityLog'))
      ..fields['deviceID'] = deviceID
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      return json.decode(await response.stream.bytesToString()); // Success message
    } else {
      throw Exception('Failed to add activity log: ${response.reasonPhrase}');
    }
  }

  // Method to connect system
  static Future<Map<String, dynamic>> connectSystem(String deviceID, String userID) async {
    final response = await http.get(
      Uri.parse('$baseUrl/connectSystem?deviceID=$deviceID&userID=$userID'),
    );

    return json.decode(response.body); 
  }

  // Method to disconnect system
  static Future<Map<String, dynamic>> disconnectSystem(String deviceID, String userID) async {
    final response = await http.get(
      Uri.parse('$baseUrl/disconnectSystem?deviceID=$deviceID&userID=$userID'),
    );

    return json.decode(response.body); 
  }

   // Method to check connection
  static Future<Map<String, dynamic>> checkConnection(String userID) async {
    final response = await http.post(
      Uri.parse('$baseUrl/checkConnection'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userID': userID,
      }),  // Closing parenthesis here
    );

    return json.decode(response.body); 
  }

  

  // Method to get alarm state
  static Future<Map<String, dynamic>> getAlarmState(String deviceID) async {
    final response = await http.get(
      Uri.parse('$baseUrl/getAlarmState?deviceID=$deviceID'),
    );

    return json.decode(response.body); 
  }

  // Method to update alarm state
  static Future<Map<String, dynamic>> updateAlarmState(String deviceID, bool alarmState) async {
    final response = await http.post(
      Uri.parse('$baseUrl/updateAlarmState'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'deviceID': deviceID,
        'alarmState': alarmState,
      }),
    );

    return json.decode(response.body); 
  }

  // Method for getting specific log
  static Future<Map<String, dynamic>> getSpecificLog(String logID) async {
    final response = await http.get(
      Uri.parse('$baseUrl/specificLog?logID=$logID'),
    );

    return json.decode(response.body); 
  }

  //Method for getting DeviceID
  static Future<Map<String, dynamic>> getDeviceID() async {
    final response = await http.get(
      Uri.parse('$baseUrl/getDeviceID'),
    );

    return json.decode(response.body);
  }

  //Method for updating System WiFi Connection 
  static Future<Map<String, dynamic>> updateSystemWiFiConnection(String deviceID, bool wifiState) async {
    final response = await http.post(
      Uri.parse('$baseUrl/updateSystemWiFiConnection'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'deviceID': deviceID,
        'wifiState': wifiState,
      }),
    );

    return json.decode(response.body);
  }

  // Method for getting System Wifi Connection 
  static Future<Map<String, dynamic>> checkSystemWiFiConnection(String deviceID) async {
    final response = await http.get(
      Uri.parse('$baseUrl/checkSystemWiFiConnection?deviceID=$deviceID'),
    );

    return json.decode(response.body); 
  }

  // Method for getting specific log
  static Future<Map<String, dynamic>> getSystemUsers(String deviceID) async {
    final response = await http.get(
      Uri.parse('$baseUrl/getSystemUsers?deviceID=$deviceID'),
    );  

    return json.decode(response.body); 
  }

  // Method for updating Firebase Token 
  static Future<Map<String, dynamic>> updateFCMToken(String userID, String fcmToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/updateFCMToken'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userID': userID, 'fcmToken': fcmToken}),
    );

    return json.decode(response.body); 
  }

  static Future<String?> getFcmToken() async {
  return await FirebaseMessaging.instance.getToken();
  }


  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
  final response = await http.post(
    Uri.parse('$baseUrl/refresh_token'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'token': refreshToken}),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to refresh token: ${response.statusCode}');
  }
}


}
