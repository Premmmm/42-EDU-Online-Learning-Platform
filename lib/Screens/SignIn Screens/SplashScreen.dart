import 'dart:io';
import 'package:FortyTwo/Components/MySlide.dart';
import 'package:FortyTwo/Screens/Main%20Screens/AllCoursesScreen.dart';
import 'package:FortyTwo/Screens/SignIn%20Screens/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Components/Data.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  Future<void> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        checkLogin();
        return;
      }
    } on SocketException catch (_) {
      Navigator.push(context, ScaleRoute(page: LoginScreen()));
      return;
    }
  }

  void checkLogin() async {
    try {
      FirebaseAuth.instance.authStateChanges().listen(
        (User user) {
          if (user == null) {
            print("Signed out daw");
            Navigator.push(context, ScaleRoute(page: LoginScreen()));
          } else {
            print('${user.email} ${user.displayName}');
            Provider.of<Data>(context, listen: false).setUserEmail(user.email);
            Provider.of<Data>(context, listen: false).setUser(user);
            Navigator.push(context, ScaleRoute(page: AllCoursesScreen()));

            print("signed in daw");
          }
        },
      );
    } on FirebaseException {
      print('Splash screen Firebase Exception daawww ');
      Navigator.push(context, ScaleRoute(page: LoginScreen()));
    } catch (e) {
      print('Splash screen try catch daww $e');
      Navigator.push(context, ScaleRoute(page: LoginScreen()));
    }

    // var prefs3 = await SharedPreferences.getInstance();
    // String email = prefs3.getString('loginEmailFortyTwo');
    // if (email != null) {
    //   print(email);
    //   Provider.of<Data>(context, listen: false).setUserEmail(email);
    //   try {
    //     await FirebaseFirestore.instance
    //         .collection(email)
    //         .doc('credentials')
    //         .get()
    //         .then(
    //       (snapshot) {
    //         if (snapshot.data() != null) {
    //           Map<dynamic, dynamic> values = snapshot.data();
    //           values.forEach(
    //             (key, value) {
    //               if (key.toString() == 'photoUrl') {
    //                 Provider.of<Data>(context, listen: false)
    //                     .setPhotoUrl(value.toString());
    //               }
    //               if (key.toString() == 'name') {
    //                 Provider.of<Data>(context, listen: false)
    //                     .setuserName(value.toString());
    //               }
    //             },
    //           );
    //         }
    //       },
    //     );
    //     await FirebaseFirestore.instance
    //         .collection(email)
    //         .doc('mobileLogin')
    //         .get()
    //         .then(
    //       (snapshot) {
    //         if (snapshot.data() != null) {
    //           Map<dynamic, dynamic> values = snapshot.data();
    //           values.forEach(
    //             (key, value) {
    //               if (key.toString() == 'loggedIn') {
    //                 if (value.toString() == 'yes') {
    //                   Navigator.push(
    //                       context, ScaleRoute(page: AllCoursesScreen()));
    //                 } else {
    //                   Navigator.push(context, ScaleRoute(page: LoginScreen()));
    //                 }
    //               }
    //             },
    //           );
    //         } else {
    //           Navigator.push(context, ScaleRoute(page: LoginScreen()));
    //         }
    //       },
    //     );
    //   } on FirebaseException {
    //     Navigator.push(context, ScaleRoute(page: LoginScreen()));
    //   }
    // } else {
    //   Navigator.push(context, ScaleRoute(page: LoginScreen()));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3A7FBC),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/logo.png'),
              fit: BoxFit.contain,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
