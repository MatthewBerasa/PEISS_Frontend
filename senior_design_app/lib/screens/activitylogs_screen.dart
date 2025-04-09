import 'package:flutter/material.dart';
import 'package:senior_design_app/screens/detailedlog_screen.dart';
import '../Services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'disconnected_screen.dart';
import 'connected_screen.dart';
import '../components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;


//Reference Sizes
final baseHeight = 914;
final baseWidth = 411;

class ActivityLogsScreen extends StatefulWidget{
  _ActivityLogsScreenState createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen>{
  List logs = []; 

  @override
  void initState(){
    super.initState();
    fetchLogs();
  }

  void fetchLogs() async{
    //Request Body Data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceID = prefs.getString('deviceID');

    //API Call
    var response = await ApiService.getLogs(deviceID.toString());

    if(response['error'] != null){
      print(response['error']);
    }else{
      setState(() {
        logs = response['logs'];
      });
    }

  }

  void _Home() async {
    //Request Data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');

    //API Call to check connection
    var response = await ApiService.checkConnection(userID.toString());

    if(response['error'] != null)
      print(response['error']);
    else{
      if(response['connectionStatus']){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConnectedScreen()),
        );
      }else{
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DisconnectedScreen()),
        );
      }
    }
  }

  void _ActivityLogs(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ActivityLogsScreen()),
    );
  }
  
 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height / baseHeight * 40.0),
        PEISSText(),
        Expanded(
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final currLog = logs[index];
              return LogDisplay(
                imageURL: currLog['ImageURL'],
                date: currLog['Timestamp'],
                logID: currLog['_id'],
              );
            },
          ),
        ),
      ],
    ),
    bottomNavigationBar: 
      Row(
        children: [
          Expanded(child: LeftButton(onPressed: _Home)),
          Expanded(child: RightButton(onPressed: _ActivityLogs)),
        ],
    ),
  );
}

}

class LogDisplay extends StatelessWidget{
  String imageURL = '';
  String date = '';
  String logID = '';

  LogDisplay({
    required this.imageURL,
    required this.date,
    required this.logID,
  });

  void _clickDetailedLog(String logID, BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DetailedlogScreen(logID: logID)),
    );
  }


  Widget build(BuildContext context){
    final convertedDate = convertUTCtoEST(date);
    return SizedBox(
      height: MediaQuery.of(context).size.height / baseHeight * 100.0,
      width: MediaQuery.of(context).size.width * .65,
      child: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width / baseWidth * 30.0, 
          right: MediaQuery.of(context).size.width / baseWidth * 30.0, 
          top: MediaQuery.of(context).size.height / baseHeight * 8.0, 
          bottom: MediaQuery.of(context).size.height / baseHeight * 8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            side: BorderSide(
              color: Colors.black,
              width: 3.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            backgroundColor: Colors.transparent,
          ),
          onPressed: () => _clickDetailedLog(logID, context),
          child: Row(
            children: [
              RotatedBox(
                quarterTurns: 1,
                child: CachedNetworkImage(
                  imageUrl: imageURL,
                  height: MediaQuery.of(context).size.height / baseHeight * 100.0,
                  width: MediaQuery.of(context).size.width / baseWidth * 100.0,
                  fit: BoxFit.contain,
                )
              ),
              SizedBox(width: MediaQuery.of(context).size.width / baseWidth * 60.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    convertedDate['date'].toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / baseHeight * 20.0,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  Text(
                    convertedDate['time'].toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / baseHeight * 20.0,
                      fontWeight: FontWeight.bold,
                    )
                  )
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}