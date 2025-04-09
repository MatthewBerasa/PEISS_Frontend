import 'package:senior_design_app/screens/login_screen.dart';
import '../Services/api_service.dart';
import 'package:flutter/material.dart';
import '../components.dart';
import '../screens/disconnected_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart'; //Import JWT Decoder 

//Reference Sizes
final baseHeight = 914;
final baseWidth = 411;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailInput = TextEditingController();
  final TextEditingController passwordInput = TextEditingController();
  final TextEditingController confirmPasswordInput = TextEditingController();
  final TextEditingController verificationCodeInput = TextEditingController();

  //Error Texts to Display to User
  String? emailNotFilled = '';
  String? passwordNotFilled = '';
  String? notValidEmail = '';
  String? notMatchingPassword = '';
  String? notPasswordValidLength = '';
  String? notPasswordContainsCaptial = '';

  String? incorrectVerificationCode = '';

  void backToLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void verifyInputParameters() {
    setState(() {
      emailNotFilled = emailInput.text.isEmpty ? 'Enter an email.' : null;
      passwordNotFilled = passwordInput.text.isEmpty ? 'Enter a password.' : null;
      notMatchingPassword = confirmPasswordInput.text.isEmpty ? 'Must retype password.' : null;

      notValidEmail = notPasswordContainsCaptial = notPasswordValidLength = null;

      if (emailNotFilled != null || passwordNotFilled != null || notMatchingPassword != null) {
        return;
      }
    });

    if (emailNotFilled != null || passwordNotFilled != null || notMatchingPassword != null) {
      notValidEmail = notPasswordContainsCaptial = notPasswordValidLength = null;
      return;
    }

    //Check if Password Requirements are filled
    setState(() {
      bool invalidPassword = false;
      if (passwordInput.text != confirmPasswordInput.text) {
        notMatchingPassword = 'Password must match.';
        return;
      }
      if (passwordInput.text.length < 6 || passwordInput.text.length > 18) {
        notPasswordValidLength = 'Password must be between 6-18 characters';
        invalidPassword = true;
      }
      if (!RegExp(r'[A-Z]').hasMatch(passwordInput.text)) {
        notPasswordContainsCaptial = 'Password must contain a capital letter.';
        invalidPassword = true;
      }
      if (invalidPassword) return;
    });

    //Check if Valid Email Format
    setState(() {
      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(emailInput.text)) {
        notValidEmail = 'Must enter proper email format.';
        return;
      } else {
        verifyEmail();
      }
    });
  }

  void verifyEmail() async {
    var response = await ApiService.requestVerificationCode(emailInput.text);

    if (response['error'] != null) {
      setState(() {
        notValidEmail = response['error'].toString();
      });
      return;
    } else {
      verificationPopup(response['verificationCode']);
    }
  }

  void verificationPopup(String verificationCode) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext content) {
          return StatefulBuilder(builder: (content, setDialogState) {
            return AlertDialog(
              title: Text(
                'Enter Verification Code Sent to Email',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / baseHeight * 15.0,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: verificationCodeInput,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      incorrectVerificationCode ?? '',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / baseHeight * 18.0,
                          color: Colors.red),
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => {
                          setDialogState(() {
                            incorrectVerificationCode = null;
                          }),
                          verificationCodeInput.clear(),
                          Navigator.of(context).pop(),
                        },
                    child: Text('Cancel')),
                TextButton(
                  onPressed: () async {
                    tryRegister(verificationCode, setDialogState);
                  },
                  child: Text('Submit'),
                )
              ],
            );
          });
        });
  }

  void tryRegister(String verificationCode, StateSetter setDialogState) async {
    if (verificationCode != verificationCodeInput.text) {
      setDialogState(() {
        incorrectVerificationCode = 'Incorrect verification code, Please Try Again.';
      });
      return;
    }

    var fcmToken = await ApiService.getFcmToken();
    var response = await ApiService.register(emailInput.text, passwordInput.text, fcmToken.toString());

    if (response['error'] != null) {
      incorrectVerificationCode = response['error'].toString();
    } else {
      final token = JWT.decode(response['accessToken']);
      final payload = token.payload;

      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('accessToken', response['accessToken']);
        prefs.setString('userID', payload['userInfo']['userID']);
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DisconnectedScreen()));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 30.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / baseHeight * 20.0),
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: backToLogin,
                  child: Text(
                    'X',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / baseHeight * 20.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              PEISSText(),
              PEISSLogo(),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / baseHeight * 18.0,
                            color: Colors.black,
                          ),
                        )),
                    TextField(
                      controller: emailInput,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          emailNotFilled ?? '',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: MediaQuery.of(context).size.height / baseHeight * 18.0,
                          ),
                        )),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / baseHeight * 18.0,
                            color: Colors.black,
                          ),
                        )),
                    TextField(
                      controller: passwordInput,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          passwordNotFilled ?? '',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: MediaQuery.of(context).size.height / baseHeight * 18.0,
                          ),
                        )),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / baseHeight * 18.0,
                            color: Colors.black,
                          ),
                        )),
                    TextField(
                      controller: confirmPasswordInput,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (notMatchingPassword != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        notMatchingPassword!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: MediaQuery.of(context).size.height / baseHeight * 18.0,
                        )
                      )
                    ),
                    if (notPasswordValidLength != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        notPasswordValidLength!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: MediaQuery.of(context).size.height / baseHeight * 18.0,
                        )
                      )
                    ),
                    if (notPasswordContainsCaptial != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        notPasswordContainsCaptial!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: MediaQuery.of(context).size.height / baseHeight * 18.0,
                        )
                      )
                    ),
                    if (notValidEmail != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        notValidEmail!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: MediaQuery.of(context).size.height / baseHeight * 18.0,
                        )
                      )
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / baseHeight * 50.0,
                    child: ElevatedButton(
                        onPressed: verifyInputParameters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          side: BorderSide(
                            width: 3.0,
                            color: Colors.black,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ))),
              )
            ],
          ),
        ),
      ),
    );
  }
}