import 'package:flutter/material.dart';
import 'package:senior_design_app/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/api_service.dart'; // Import the ApiService
import '../screens/register_screen.dart'; //Register Screen
import '../screens/connected_screen.dart'; //Connected Screen
import '../screens/disconnected_screen.dart'; //Disconnected Screen
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart'; //Import JWT Decoder 

//Reference Sizes
final baseHeight = 914;
final baseWidth = 411;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to capture user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? emailNotEntered;
  String? passwordNotEntered;

  String? invalidLogin;

  // Function to handle sign-in
  void _signIn() async {
    // Validate inputs and update UI synchronously
    setState(() {
      emailNotEntered = _emailController.text.isEmpty ? 'Enter an email.' : null;
      passwordNotEntered = _passwordController.text.isEmpty ? 'Enter a password.' : null;
    });

    if (emailNotEntered != null || passwordNotEntered != null) {
      setState(() {
        invalidLogin = null;
      });
      return;
    }

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      // Perform API call
      var response = await ApiService.login(email, password);
      print("API Response: $response");

      if (response['error'] != null) {
        setState(() {
          invalidLogin = 'Password or Email is incorrect.';
        });
        return;
      }

      // Decode JWT
      final token = JWT.decode(response['accessToken']);
      final payload = token.payload;

      // Save to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', response['accessToken']);
      await prefs.setString('userID', payload['userInfo']['userID']);

      // Update FCM token
      String? fcmToken = await ApiService.getFcmToken();
      if(fcmToken != ''){
        setState(() {
          invalidLogin = 'Error: $e';
        });
        return;
      }
      var resFCM = await ApiService.updateFCMToken(
        payload['userInfo']['userID'],
        fcmToken ?? '',
      );
      if (resFCM['error'] != null) {
        print("FCM Update Error: ${resFCM['error']}");
      }

      // Navigate based on connection status
      if (payload['userInfo']['isConnected']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConnectedScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DisconnectedScreen()),
        );
      }
    } catch (e) {
      print("Login Error: $e");
      setState(() {
        invalidLogin = 'Error: $e';
      });
    }
  }

  void _register() async{
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => RegisterScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Empty space to push the text to the top
            SizedBox(height: (MediaQuery.of(context).size.height / baseHeight) * 50), // Adjust the height to your preference

            //Text PEISS
            PEISSText(),
            
            //Image
            PEISSLogo(),
            
            //Email Input
            Align(
              alignment: Alignment.topLeft,
              child:Text(
                'Email',
                style: TextStyle(fontSize: (MediaQuery.of(context).size.height / baseHeight) * 18),
              ),
            ),

            Center(
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                ),
              ),
            ),
            
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                emailNotEntered ?? '',
                style: TextStyle(
                  fontSize: (MediaQuery.of(context).size.height / baseHeight) * 18,
                  color: Colors.red, // Correct usage of color
                ),
              ),
            ),


            SizedBox(height: (MediaQuery.of(context).size.height / baseHeight) * 30),

            //Password Input
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Password',
                style: TextStyle(fontSize: (MediaQuery.of(context).size.height / baseHeight) * 18),
              ),
            ),

            Center(
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                ),
              )
            ),

            
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                passwordNotEntered ?? '',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: (MediaQuery.of(context).size.height / baseHeight) * 18,
                ) 
              ),
            ),
    
            SizedBox(height: (MediaQuery.of(context).size.height / baseHeight) * 30),

            //Sign-In Button
            SizedBox(
              width: double.infinity,
              height: (MediaQuery.of(context).size.height / baseHeight) * 50,
              child: ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  side: BorderSide(color: Colors.black, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ) ,
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                ),
              ),
            ),

            Align(
              alignment: Alignment.topLeft,
              child: Text(
                invalidLogin ?? '',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: (MediaQuery.of(context).size.height / baseHeight) * 18,
                )
              )
            ),

            SizedBox(height: (MediaQuery.of(context).size.height / baseHeight) * 20),

            //Register Button
            SizedBox(
              width: double.infinity,
              height: (MediaQuery.of(context).size.height / baseHeight) * 50,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  side: BorderSide(color: Colors.black, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  )
                ),
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                ),
              ),
            ),

          ],


        ),
      ),
    );
  }
}
