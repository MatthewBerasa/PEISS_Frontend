import 'dart:math';
import 'package:flutter/material.dart';
import 'package:senior_design_app/screens/connected_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/api_service.dart';
import '../screens/login_screen.dart';
import '../screens/activitylogs_screen.dart';
import '../components.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:url_launcher/url_launcher.dart';

final baseHeight = 914;
final baseWidth = 411;

class DisconnectedScreen extends StatefulWidget {
  @override
  _DisconnectedScreenState createState() => _DisconnectedScreenState();
}

class _DisconnectedScreenState extends State<DisconnectedScreen> {
  String? connectionResult;
  // This variable indicates whether the system is already connected to WiFi.
  bool systemWiFiConnected = false; 

  @override
  void initState() {
    super.initState();
    _refreshToken();
    _checkSystemWiFiConnection();
  }

  void _refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('accessToken');
    try {
      var response = await ApiService.refreshToken(refreshToken.toString());
      if (response['error'] != null) {
        print(response['error']);
      } else {
        prefs.setString('accessToken', response['accessToken']);
      }
    } catch (error) {
      print('An error has occurred.');
    }
  }

  void _checkSystemWiFiConnection() async{
    var deviceIDResponse = await ApiService.getDeviceID();

    if(deviceIDResponse['error'] != null){
      print("Failed to retrieve Device ID.");
      return;
    }

    var connectionResponse = await ApiService.checkSystemWiFiConnection(deviceIDResponse['deviceID']);
    if(connectionResponse['error'] != null){
      print(connectionResponse['error']);
      return;
    }

    systemWiFiConnected = connectionResponse['status']['wifiConnection'];
  }

  Widget _buildConnectionInstructions() {
    if (systemWiFiConnected) {
      // If system is already connected to WiFi, instruct user to simply press Continue.
      return Text("System already connected to Wi-Fi. Simply press 'Continue' to connect to system.");
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Please follow these steps:"),
          SizedBox(height: MediaQuery.of(context).size.height / baseHeight * 10),
          Text("1. Open your WiFi settings"),
          Text("2. Select 'PEISS-System Setup'"),
          Text("3. Password: PEISS_Spring2025"),
          Text("4. Complete the setup in the portal"),
          Text("5. Return to app and click 'Continue'"),
        ],
      );
    }
  }

  void _ConnectPressed() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              contentPadding: EdgeInsets.all(16),
              insetPadding: EdgeInsets.symmetric(horizontal: 20),
              title: Text(
                'Connect to PEISS System',
                style: TextStyle(fontSize: 18),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width / baseWidth * 0.8,
                constraints: BoxConstraints(
                  maxWidth: 400,
                  minWidth: 300,
                ),
                child: _buildConnectionInstructions(),
              ),
              actions: [
                TextButton(
                  child: Text('Continue'),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _TryConnect();
                  },
                ),
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> connectToESP32() async {
    bool connected = await WiFiForIoTPlugin.connect(
      "PEISS-System Setup",
      password: "PEISS_Spring2025",
      security: NetworkSecurity.WPA,
      joinOnce: true,
      withInternet: false,
    );

    if (connected) {
      print("Connected to ESP32 AP");
      WiFiForIoTPlugin.forceWifiUsage(true);
    } else {
      print("Failed to connect to ESP32 AP");
    }
  }

  Future<void> _TryConnect() async {
    // Get device ID from API
    var deviceIDResponse = await ApiService.getDeviceID();
    if (deviceIDResponse['error'] != null) {
      print("Failed to get Device ID");
      return;
    }

    // Check system WiFi connection status via API.
    var wifiConnectionResponse = await ApiService.checkSystemWiFiConnection(
      deviceIDResponse['deviceID']
    );
    if (wifiConnectionResponse['error'] != null) {
      print(wifiConnectionResponse['error']);
      return;
    }

    // If system is connected to WiFi, then proceed.
    if (wifiConnectionResponse['status']['wifiConnection']) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('deviceID', deviceIDResponse['deviceID']);

      String? deviceID = prefs.getString('deviceID');
      String? userID = prefs.getString('userID');

      // Call API to connect user to system
      var response = await ApiService.connectSystem(
        deviceID.toString(), userID.toString()
      );

      if (response['error'] != null) {
        print(response['error']);
        return;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConnectedScreen())
        );
      }
    } else {
      // Display AlertBox indicating connection failure
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text('Failed to connect system to WiFi. Please try again.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _Logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('accessToken');
    
    //Delete Firebase Token
    await ApiService.updateFCMToken(pref.getString('userID').toString(), "");
    await pref.remove('userID');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _Logs() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ActivityLogsScreen()),
    );
  }

  void _Home() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DisconnectedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                SizedBox(height: (MediaQuery.of(context).size.height / baseHeight) * 30),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: (MediaQuery.of(context).size.width / baseWidth) * 20.0),
                    child: LogoutButton(onPressed: _Logout),
                  ),
                ),
                PEISSText(),
                PEISSLogo(),
                SizedBox(
                  width: (MediaQuery.of(context).size.width / baseWidth) * 250,
                  height: (MediaQuery.of(context).size.height / baseHeight) * 180,
                  child: ElevatedButton(
                    onPressed: _ConnectPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      side: BorderSide(color: Colors.black, width: 3),
                      shape: CircleBorder(),
                    ),
                    child: Image.network('https://i.imgur.com/Vwt3d6w.png'),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'OFFLINE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: (MediaQuery.of(context).size.height / baseHeight) * 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              LeftButton(onPressed: _Home),
              RightButton(onPressed: _Logs),
            ],
          ),
        ],
      ),
    );
  }
}
