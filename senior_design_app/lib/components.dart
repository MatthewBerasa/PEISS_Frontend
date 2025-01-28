import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data; // Required for initializeTimeZones
import 'package:intl/intl.dart';


//Reference Sizes
final baseWidth = 411;
final baseHeight = 914;

class LeftButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LeftButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (MediaQuery.of(context).size.height / baseHeight) * 100,
      width: MediaQuery.of(context).size.width / 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(0),
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / baseHeight * 10.0),
            child: SizedBox(
              height: (MediaQuery.of(context).size.height / baseHeight) * 85,
              width: (MediaQuery.of(context).size.width / baseWidth) * 85,
              child: Image.network('https://i.imgur.com/gt4YmOa.png'),
            ),
          ),
        ),
      ),
    );
  }
}

class RightButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RightButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (MediaQuery.of(context).size.height / baseHeight) * 100,
      width: MediaQuery.of(context).size.width / 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(0),
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / baseHeight * 10.0),
            child: SizedBox(
              height: (MediaQuery.of(context).size.height / baseHeight) * 100,
              width: (MediaQuery.of(context).size.width / baseWidth) * 100,
              child: Image.network('https://i.imgur.com/4A4fuhn.png'),
            ),
          ),
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(right: (MediaQuery.of(context).size.width / baseWidth) * 20),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.black, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: Text(
            'LOGOUT',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class PEISSText extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    return Center(
      child: Text(
      'PEISS',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: (MediaQuery.of(context).size.height / baseHeight) * 50),
      ),
    );
  }
}


class PEISSLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the screen width and height dynamically
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Determine a proportionate size for the image
    double imageHeight = screenHeight * 0.25; // 30% of screen height
    double imageWidth = screenWidth * 0.6;  // 60% of screen width

    return Center(
      child: SizedBox(
        height: imageHeight,
        width: imageWidth,
        child: Image.network(
          'https://i.imgur.com/j4Mm9K9.png',
          fit: BoxFit.contain, // Ensure the image maintains its aspect ratio
        ),
      ),
    );
  }
}

Map<String, String> convertUTCtoEST(String utcTimestamp) {
  // Get EST time zone
  final estTimeZone = tz.getLocation('America/New_York');

  // Parse UTC timestamp
  final utcDateTime = DateTime.parse(utcTimestamp);

  // Convert UTC to EST/EDT considering DST
  final localDateTime = tz.TZDateTime.from(utcDateTime, estTimeZone);

  // Format date and time
  String formattedDate = DateFormat('MM/dd/yyyy').format(localDateTime);
  String formattedTime = DateFormat('hh:mm a').format(localDateTime);

  return {
    'date': formattedDate,
    'time': formattedTime,
  };
}
