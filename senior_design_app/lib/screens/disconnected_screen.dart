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

  @override
  void initState() {
    super.initState();
    _refreshToken();
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

  void _ConnectPressed() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Connecting...',
                style: TextStyle(fontSize: 15, color: Colors.black)
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              )
            );
          },
        );
      },
    );

    await _TryConnect();
  }

  Future<void> connectToESP32() async {
    bool connected = await WiFiForIoTPlugin.connect(
      "PEISS-System Setup",
      password: "PEISS_Spring2025",
      security: NetworkSecurity.WPA,
      joinOnce: true,
      withInternet: false
    );

    if (connected) {
      print("Connected to ESP32 AP");
      WiFiForIoTPlugin.forceWifiUsage(true);
    } else {
      print("Failed to connect to ESP32 AP");
    }
  }

  Future<void> _TryConnect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');

    await connectToESP32();
    
    await Future.delayed(Duration(seconds: 2));
    
    final Uri portalUrl = Uri.parse('http://192.168.4.1');
    if (!await launchUrl(portalUrl, mode: LaunchMode.externalApplication)) {
      print('Could not launch portal');
    }

    var response = await ApiService.getDeviceID();

    if (response['error'] != null) {
      Navigator.of(context).pop();
      print("Failed to retrieve DeviceID.");
    } else {
      prefs.setString('deviceID', response['deviceID']);
    }

    var connectionResponse = await ApiService.connectSystem(
      response['deviceID'],
      userID.toString()
    );

    Navigator.of(context).pop();

    if (connectionResponse['error'] == null) {
      print(connectionResponse['error']);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ConnectedScreen())
      );
    }
  }

  void _Logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('accessToken');
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
        ]
      )
    );
  }
}