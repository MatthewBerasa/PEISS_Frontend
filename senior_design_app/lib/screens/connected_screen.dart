import 'package:flutter/material.dart';
import 'package:senior_design_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/api_service.dart';
import 'package:senior_design_app/components.dart';
import '../screens/login_screen.dart'; //Login Screen
import '../screens/activitylogs_screen.dart';
import '../screens/disconnected_screen.dart';

//Reference Size
final baseHeight = 914;
final baseWidth = 411;

class ConnectedScreen extends StatefulWidget{
  _ConnectedScreenState createState() => _ConnectedScreenState();
}

class _ConnectedScreenState extends State<ConnectedScreen>{
  double sliderValueAlarm = 1; //Stores Final Value of Alarm (Only changes if user goes from slider value 0 -> 1 or 1 -> 0)
  double sliderValueNotifications = 1; //Stores Final Value of Notification
  double sliderAlarmCurrent = 1; //Stores Current Value of Alarm (Ex if user has slider at .5 it is .5)
  double sliderNotificationCurrent = 1; //Stores Current Value of Notification
  
  
  bool isLoading = true; // Add isLoading to track loading state


  @override
  void initState() {
    super.initState();
    _loadSettings();
    _refreshToken();
  }

  void _loadSettings() async {
    var deviceIDResponse = await ApiService.getDeviceID();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('deviceID', deviceIDResponse['deviceID']);
    String? deviceID = prefs.getString('deviceID');

    if (deviceID != null) {
      var response = await ApiService.provideSettings(deviceID.toString());

      if (response['error'] != null) {
        setState(() {
          sliderAlarmCurrent = sliderValueAlarm = 0.5;
          sliderNotificationCurrent = sliderValueNotifications = 0.5;
          isLoading = false; // Data loading is complete
        });
      } else {
        setState(() {
          sliderAlarmCurrent = sliderValueAlarm = response['alarmSetting'] ? 1 : 0;
          sliderNotificationCurrent = sliderValueNotifications = response['notificationSetting'] ? 1 : 0;
          isLoading = false; // Data loading is complete
        });
      }
    }
    else{
      print('No Device ID Found');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _refreshToken() async{
    //Request Body JWT
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('accessToken');
    try{
      var response = await ApiService.refreshToken(refreshToken.toString());
      if(response['error'] != null){
        print(response['error']);
      }else{
        prefs.setString('accessToken', response['accessToken']);
      }
    }catch(error){
      print('An error has occurred.');
    }
  }
  
  //Initialize Sliders Depending on System Setting
  _ConnectedScreenState()  {
    sliderAlarmCurrent = sliderValueAlarm;
    sliderNotificationCurrent = sliderValueNotifications;
  }
  
  //Change Value as Alarm Slider is Moving 
  void _onAlarmSliderChanged(double value){
    setState(() {
      sliderAlarmCurrent = value;
    });
  }

  //Change Value as Notification Slider is Moving 
  void _onNotificationSliderChanged(double value){
    setState(() {
      sliderNotificationCurrent = value;
    });
  }

  //Set Final Value of Alarm Slider if either 0 or 1 otherwise remain unchanged 
  void _OnAlarmSliderEnd(double value) {
    setState(() {
      if(value <= 0.1){
        sliderAlarmCurrent = sliderValueAlarm = 0;    
        _updateSetting(); 
      }
      else if(value >= .9){
        sliderAlarmCurrent = sliderValueAlarm = 1;
        _updateSetting();
      }
      else{
        sliderAlarmCurrent = sliderValueAlarm;
      }
    });
  }

  //Set Final Value of Notification Slider if either 0 or 1 otherwise remain unchanged 
  void _onNotificationSliderEnd(double value){
    setState(() {
      if(value <= .1){
        sliderNotificationCurrent = sliderValueNotifications = 0;
        _updateSetting();
      }
      else if(value >= .9){
        sliderNotificationCurrent = sliderValueNotifications = 1;
        _updateSetting();
      }
      else
        sliderNotificationCurrent = sliderValueNotifications;
    });
  }

void _DisconnectPressed() async {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext Context) {
      return AlertDialog(
        title: Center(
          child: Text(
            'Confirm Disconnection',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          // Centering the buttons using Row and MainAxisAlignment.center
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _Disconnect,
                child: Text('Confirm'),
              ),
              SizedBox(width: 10), // Optional space between the buttons
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        ],
      );
    },
  );
}

  
  void _Disconnect() async{
    //API Request Data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceID = prefs.getString('deviceID');
    String? userID = prefs.getString('userID');

    //API Call to check number of users connected to system
    var systemUsers = await ApiService.getSystemUsers(deviceID.toString());
    if(systemUsers['error'] != null){
      print(systemUsers['error']);
      return;
    }

    if((systemUsers['result']['usersConnected']).length == 1){ //Last User Connected to System is Disconnecting make System Disconnect from WiFi
      var wifiDisconnectResponse = await ApiService.updateSystemWiFiConnection(deviceID.toString(), false);
      if(wifiDisconnectResponse['error'] != null){
        print(wifiDisconnectResponse['error']);
        return;
      }
    }


    //API Call Disconnect User from System 
    var response = await ApiService.disconnectSystem(deviceID.toString(), userID.toString());

    if(response['error'] != null){
      print(response['error']);
    }else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('deviceID');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DisconnectedScreen()),
      );
    }
  }

  void _Home(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ConnectedScreen()),
    );
  }

  void _ActivityLogs(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ActivityLogsScreen()),
    );
  }

  void _Logout() async {
    //Delete JWT 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('accessToken');

    //Delete Firebase Token
    await ApiService.updateFCMToken(prefs.getString('userID').toString(), "");
    prefs.remove('userID');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  //Function to Update System Setting in Database
  void _updateSetting() async{
    //API Request Data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceID = prefs.getString('deviceID');

    bool alarmSetting = sliderValueAlarm == 1 ? true : false;
    bool notificationSetting = sliderValueNotifications == 1 ? true : false;

    //API Call
    var response = await ApiService.updateSettings(deviceID.toString(), alarmSetting, notificationSetting);

    if(response['error'] != null){
      print(response['error']);
    }else{
      print(response['message']);
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner if still loading
          : Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height / baseHeight * 30),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: MediaQuery.of(context).size.width / baseWidth * 20),
                        child: LogoutButton(onPressed: _Logout),
                      ),
                    ),
                    PEISSText(),
                    PEISSLogo(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / baseHeight * 180,
                      width: MediaQuery.of(context).size.width / baseWidth * 250,
                      child: ElevatedButton(
                        onPressed: _DisconnectPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          side: BorderSide(
                            color: Colors.black,
                            width: 3,
                          ),
                          shape: CircleBorder(),
                        ),
                        child: Image.network('https://i.imgur.com/Vwt3d6w.png'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'ONLINE',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / baseHeight * 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / baseHeight * 100.0,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Stack(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: MediaQuery.of(context).size.height / baseHeight * 30.0,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
                              thumbColor: Colors.black,
                            ),
                            child: Slider(
                              value: sliderAlarmCurrent,
                              onChanged: _onAlarmSliderChanged,
                              onChangeEnd: _OnAlarmSliderEnd,
                              min: 0.0,
                              max: 1.0,
                              activeColor: Colors.green,
                              inactiveColor: Colors.red,
                            ),
                          ),
                          Center(
                            child: Text(
                              'Alarm System',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.height / baseHeight * 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Align(
                            alignment: sliderValueAlarm == 1
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: sliderValueAlarm == 1
                                  ? EdgeInsets.only(right: MediaQuery.of(context).size.width / baseWidth * 28.0)
                                  : EdgeInsets.only(left: MediaQuery.of(context).size.width / baseWidth * 25.0),
                              child: IgnorePointer(
                                child: Text(
                                  sliderValueAlarm == 1 ? 'ON' : 'OFF',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.height / baseHeight * 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / baseHeight * 30.0,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Stack(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbColor: Colors.black,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
                              trackHeight: MediaQuery.of(context).size.height / baseHeight * 30,
                            ),
                            child: Slider(
                              value: sliderNotificationCurrent,
                              onChanged: _onNotificationSliderChanged,
                              onChangeEnd: _onNotificationSliderEnd,
                              activeColor: Colors.green,
                              inactiveColor: Colors.red,
                            ),
                          ),
                          Align(
                            alignment: sliderValueNotifications == 1
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: sliderValueNotifications == 1
                                  ? EdgeInsets.only(right: MediaQuery.of(context).size.width / baseWidth * 28.0)
                                  : EdgeInsets.only(left: MediaQuery.of(context).size.width / baseWidth * 25.0),
                              child: IgnorePointer(
                                child: Text(
                                  sliderValueNotifications == 1 ? 'ON' : 'OFF',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.height / baseHeight * 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.height / baseHeight * 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ),
            Row(
              children: [
                LeftButton(onPressed: _Home),
                RightButton(onPressed: _ActivityLogs),
              ],
            ),
          ],
        ),
    );
  }
}