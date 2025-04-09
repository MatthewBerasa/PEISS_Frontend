import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/api_service.dart';
import 'connected_screen.dart';
import 'activitylogs_screen.dart';
import '../components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

//Reference Sizes
final baseHeight = 914;
final baseWidth = 411;

class DetailedlogScreen extends StatefulWidget{
  final String logID;

  const DetailedlogScreen({
    required this.logID,
  });

  _DetailedlogScreenState createState() => _DetailedlogScreenState();
}

class _DetailedlogScreenState extends State<DetailedlogScreen>{ 
  String date = '';
  String time = '';
  String imageURL = '';
  bool alarmSounding = false;

  double sliderFinalValue = 1;
  double sliderCurrentValue = 1;

  bool isLoading = true;

  void initState(){
    super.initState();
    fetchLog();
    getAlarmState();
  }

  void fetchLog() async {
    try {
      var response = await ApiService.getSpecificLog(widget.logID);

      if (response == null || response['error'] != null) {
        print("Error fetching log: ${response?['error']}");
      } else {
        final convertedDate = convertUTCtoEST(response['Timestamp']); // Convert UTC to EST
        setState(() {
          date = convertedDate['date'].toString(); // Store Date
          time = convertedDate['time'].toString(); // Store time
          imageURL = response['ImageURL']; // Store Image URL
        });
      }
    } catch (e) {
      print("Error in fetchLog: $e");
    }
}

void getAlarmState() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceID = prefs.getString('deviceID');
    var response = await ApiService.getAlarmState(deviceID.toString());


    if (response == null || response['error'] != null) {
      print("Error fetching alarm state: ${response?['error']}");
    } else {
      setState(() {
        alarmSounding = response['alarmState']['alarmSounding'];
        sliderCurrentValue = sliderFinalValue = (alarmSounding) ? 1 : 0;
        isLoading = false;
      });
    }
  } catch (e) {
    print("Error in getAlarmState: $e");
  }
}

  void _Home() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ConnectedScreen()),
    );
  }

  void _ActivityLogs() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ActivityLogsScreen())
    );
  }

  void sliderChange(double value){
    setState(() {
      sliderCurrentValue = value;
    });
  }

  void sliderFinal(double value){
    setState(() {
      if(value <= .1){
        sliderCurrentValue = sliderFinalValue = 0;
        alarmSounding = false;
        _updateAlarmSounding();
      }
      else if(value >= .9){
        sliderCurrentValue = sliderFinalValue = 1;
        alarmSounding = true;
        _updateAlarmSounding();
      }
      else{
        sliderCurrentValue = sliderFinalValue;
      }
    });
  }

  void _updateAlarmSounding() async {
    //Request Data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceID = prefs.getString('deviceID');

    //API Call
    var response = await ApiService.updateAlarmState(deviceID.toString(), alarmSounding);

    if(response['error'] != null)
      print(response['error']);
    
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      body: isLoading ? Center(child: CircularProgressIndicator())
        :Column(
        children: [
          Expanded(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / baseHeight * 40.0),
                PEISSText(),
                SizedBox(height: MediaQuery.of(context).size.height /baseHeight * 20.0),
                Text(
                  date,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height /baseHeight * 30.0,
                  )
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height / baseHeight * 30.0,
                    color: Colors.black,
                  )
                ),
                SizedBox(height: MediaQuery.of(context).size.height / baseHeight * 50.0),
                Transform.rotate(
                  angle: math.pi / 2,
                  child: CachedNetworkImage(
                    imageUrl: imageURL,
                    height: MediaQuery.of(context).size.height / baseHeight * 350.0,
                    width: MediaQuery.of(context).size.width / baseWidth * 350.0,
                    fit: BoxFit.fill,
                  )
                ),
                SizedBox(
                      height: MediaQuery.of(context).size.height / baseHeight * 100.0,
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
                              value: sliderCurrentValue,
                              onChanged: sliderChange,
                              onChangeEnd: sliderFinal,
                              activeColor: Colors.green,
                              inactiveColor: Colors.red,
                            ),
                          ),
                          Align(
                            alignment: sliderFinalValue == 1
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: sliderFinalValue == 1
                                  ? EdgeInsets.only(right: MediaQuery.of(context).size.width / baseWidth * 28.0)
                                  : EdgeInsets.only(left: MediaQuery.of(context).size.width / baseWidth * 25.0),
                              child: IgnorePointer(
                                child: Text(
                                  sliderFinalValue == 1 ? 'ON' : 'OFF',
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
                              'Sound Alarm',
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
          )
        ]
      )
    );
  }


}


