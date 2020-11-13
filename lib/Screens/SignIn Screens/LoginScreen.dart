import 'dart:io';
import 'package:FortyTwo/Components/Data.dart';
import 'package:FortyTwo/Screens/Main%20Screens/AllCoursesScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final realTimeDataBase = FirebaseDatabase.instance.reference();
final fireStoreDataBase = FirebaseFirestore.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  bool obscurePassword = true;
  bool errorTextPassword = false;
  bool errorTextEmail = false;
  bool isSpinning = false;
  bool isConnected;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // TextEditingController _emailController = TextEditingController();
  // TextEditingController _passwordController = TextEditingController();

  Future<void> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isConnected = true;
        });
        return;
      }
    } on SocketException catch (_) {
      setState(() {
        isConnected = false;
      });
      return;
    }
  }

  // Future<void> signIn() async {
  //   try {
  //     UserCredential k = await FirebaseAuth.instance
  //         .signInWithEmailAndPassword(email: email, password: password);
  //     if (k != null) {
  //       var prefs1 = await SharedPreferences.getInstance();
  //       await prefs1.setString('loginEmailFortyTwo', email);
  //       await fireStoreDataBase
  //           .collection(email.toString())
  //           .doc('mobileLogin')
  //           .set({'loggedIn': 'yes'});
  //       setState(() {
  //         isSpinning = false;
  //       });
  //       Provider.of<Data>(context, listen: false).setUserEmail(email);
  //       Navigator.push(context, ScaleRoute(page: AllCoursesScreen()));
  //     }
  //   } on PlatformException {
  //     setState(() {
  //       isSpinning = false;
  //     });
  //     _scaffoldKey.currentState.showSnackBar(
  //       SnackBar(
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 2),
  //         content: Container(
  //           height: 40,
  //           child: Center(
  //             child: Text(
  //               'Incorrect email or password',
  //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     setState(() {
  //       isSpinning = false;
  //     });
  //     _scaffoldKey.currentState.showSnackBar(
  //       SnackBar(
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 2),
  //         content: Container(
  //           height: 40,
  //           child: Center(
  //             child: Text(
  //               'An error occurred while signing in',
  //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //     print('Sign in la error ${e.message}');
  //   }
  // }

  // ignore: missing_return
  Future<String> signInWithGoogle() async {
    setState(() {
      isSpinning = true;
    });
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User user = authResult.user;

      if (user != null) {
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);
        final User currentUser = _auth.currentUser;
        assert(user.uid == currentUser.uid);
        print(user.uid);
        var prefs1 = await SharedPreferences.getInstance();
        await prefs1.setString('loginEmailFortyTwo', user.email.toString());
        await fireStoreDataBase
            .collection(user.email.toString())
            .doc('credentials')
            .set({
          'name': user.displayName.toString(),
          'email': user.email.toString(),
          'photoUrl': user.photoURL.toString(),
          'uid': user.uid.toString()
        });
        await fireStoreDataBase
            .collection(user.email.toString())
            .doc('mobileLogin')
            .set({'loggedIn': 'yes'});
        // await fireStoreDataBase
        //     .collection(user.email.toString())
        //     .doc('credentials')
        //     .get()
        //     .then((snapshot) {
        //   if (snapshot.data() != null) {
        //     Map<dynamic, dynamic> values = snapshot.data();
        //     values.forEach((key, value) {
        //       if (key.toString() == 'photoUrl') {
        //         Provider.of<Data>(context, listen: false)
        //             .setPhotoUrl(value.toString());
        //       }
        //     });
        //   }
        // });
        Provider.of<Data>(context, listen: false).setUser(user);
        Provider.of<Data>(context, listen: false).setUserEmail(user.email);
        print('Sign in with GOOGLE SUCCEDEED');
        print('DISPLAY NAME:   ${user.displayName}');
        print('EMAIL:  ${user.email}');
        return '$user';
      }

      return null;
    } on NoSuchMethodError {
      setState(() {
        isSpinning = false;
      });
    } catch (e) {
      setState(() {
        isSpinning = false;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          content: Container(
            height: 40,
            child: Center(
              child: Text(
                'An error occurred while signing in',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
        ),
      );
      print('The google sign in error is $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return;
      },
      child: ModalProgressHUD(
        inAsyncCall: isSpinning,
        child: Scaffold(
          key: _scaffoldKey,
          body: SafeArea(
            child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/BookBackground.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: height * 0.15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        '42 EDU',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MontserratBold',
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: height * 0.2,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'WELCOME BACK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 35,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: height * 0.1,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 55,
                      margin: EdgeInsets.only(
                          left: 30, right: 30, bottom: 10, top: 10),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Colors.indigo, Colors.blue]),
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(10)),
                      child: FlatButton(
                        onPressed: () async {
                          await checkConnection();
                          if (isConnected) {
                            FocusScope.of(context).unfocus();
                            googleSignIn.signOut();
                            signInWithGoogle().then(
                              (result) {
                                if (result != null) {
                                  setState(() {
                                    isSpinning = false;
                                  });
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AllCoursesScreen();
                                      },
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    isSpinning = false;
                                  });
                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red[200],
                                      duration: Duration(seconds: 2),
                                      content: Container(
                                        height: 40,
                                        child: Center(
                                          child: Text(
                                            'An error occurred while signing in',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat',
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          }
                        },
                        child: ListTile(
                          leading: Image.asset(
                            'assets/images/GoogleLogo.png',
                            height: 25,
                            width: 25,
                          ),
                          title: Text(
                            'SIGN IN WITH GOOGLE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'MontserratBold'),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Container(
                  //   height: height * 0.53,
                  //   padding: EdgeInsets.symmetric(vertical: 25, horizontal: 5),
                  //   margin: EdgeInsets.only(left: 10, right: 10, bottom: 30),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10),
                  //     color: Colors.white,
                  //   ),
                  //   child: ListView(
                  //     children: <Widget>[

                  //       // Padding(
                  //       //   padding: const EdgeInsets.symmetric(horizontal: 10),
                  //       //   child: TextField(
                  //       //     style: TextStyle(color: Colors.grey[850]),
                  //       //     controller: _emailController,
                  //       //     decoration: InputDecoration(
                  //       //       enabledBorder: UnderlineInputBorder(
                  //       //           borderSide:
                  //       //               BorderSide(color: Colors.grey[800])),
                  //       //       labelStyle: TextStyle(
                  //       //           fontWeight: FontWeight.bold,
                  //       //           color: Colors.grey[800],
                  //       //           fontFamily: 'Montserrat'),
                  //       //       labelText: 'Email',
                  //       //       errorText: errorTextEmail
                  //       //           ? 'Please enter valid email address'
                  //       //           : null,
                  //       //       errorStyle: TextStyle(color: Colors.red),
                  //       //     ),
                  //       //     keyboardType: TextInputType.emailAddress,
                  //       //     onChanged: (value) {
                  //       //       setState(() {
                  //       //         errorTextEmail = false;
                  //       //       });
                  //       //       email = value;
                  //       //     },
                  //       //   ),
                  //       // ),
                  //       // Padding(
                  //       //   padding: const EdgeInsets.symmetric(horizontal: 10),
                  //       //   child: TextField(
                  //       //     style: TextStyle(color: Colors.grey[850]),
                  //       //     controller: _passwordController,
                  //       //     obscureText: obscurePassword,
                  //       //     decoration: InputDecoration(
                  //       //       enabledBorder: UnderlineInputBorder(
                  //       //           borderSide:
                  //       //               BorderSide(color: Colors.grey[800])),
                  //       //       labelStyle: TextStyle(
                  //       //         fontWeight: FontWeight.bold,
                  //       //         color: Colors.grey[800],
                  //       //         fontFamily: 'Montserrat',
                  //       //       ),
                  //       //       labelText: 'Password',
                  //       //       errorText: errorTextPassword
                  //       //           ? 'Password should be of minimum 7 characters'
                  //       //           : null,
                  //       //       errorStyle: TextStyle(color: Colors.red),
                  //       //       suffixIcon: InkWell(
                  //       //           onTap: () {
                  //       //             setState(() {
                  //       //               obscurePassword =
                  //       //                   obscurePassword ? false : true;
                  //       //             });
                  //       //           },
                  //       //           child: Icon(
                  //       //             Icons.remove_red_eye,
                  //       //             color: Colors.grey[800],
                  //       //           )),
                  //       //     ),
                  //       //     onChanged: (value) {
                  //       //       setState(() {
                  //       //         errorTextPassword = false;
                  //       //       });
                  //       //       password = value;
                  //       //     },
                  //       //   ),
                  //       // ),
                  //       // Align(
                  //       //   alignment: Alignment.centerLeft,
                  //       //   child: TextButton(
                  //       //     onPressed: () async {
                  //       //       if (email != null) {
                  //       //         try {
                  //       //           FocusManager.instance.primaryFocus.unfocus();
                  //       //           await FirebaseAuth.instance
                  //       //               .sendPasswordResetEmail(email: email);
                  //       //           _scaffoldKey.currentState.showSnackBar(
                  //       //             SnackBar(
                  //       //               backgroundColor: Colors.red,
                  //       //               duration: Duration(seconds: 2),
                  //       //               content: Container(
                  //       //                 height: 40,
                  //       //                 child: Center(
                  //       //                   child: Text(
                  //       //                     'Check mail to reset password',
                  //       //                     style: TextStyle(
                  //       //                         fontWeight: FontWeight.bold,
                  //       //                         fontSize: 20),
                  //       //                   ),
                  //       //                 ),
                  //       //               ),
                  //       //             ),
                  //       //           );
                  //       //         } on PlatformException {
                  //       //           setState(() {
                  //       //             errorTextEmail = true;
                  //       //           });
                  //       //         } catch (e) {
                  //       //           setState(() {
                  //       //             errorTextEmail = true;
                  //       //           });
                  //       //         }
                  //       //       } else {
                  //       //         setState(() {
                  //       //           errorTextEmail = true;
                  //       //         });
                  //       //       }
                  //       //     },
                  //       //     child: Text(
                  //       //       'Forgot password ?',
                  //       //       style: TextStyle(
                  //       //           color: Colors.indigo,
                  //       //           fontFamily: 'Montserrat',
                  //       //           fontWeight: FontWeight.bold),
                  //       //     ),
                  //       //   ),
                  //       // ),
                  //       // Container(
                  //       //   height: 55,
                  //       //   margin: EdgeInsets.only(
                  //       //       left: 10, right: 10, bottom: 10, top: 25),
                  //       //   decoration: BoxDecoration(
                  //       //       gradient: LinearGradient(
                  //       //           begin: Alignment.centerLeft,
                  //       //           end: Alignment.centerRight,
                  //       //           colors: [Colors.indigo, Colors.blue]),
                  //       //       color: Colors.indigo,
                  //       //       borderRadius: BorderRadius.circular(20)),
                  //       //   child: FlatButton(
                  //       //     onPressed: () async {
                  //       //       await checkConnection();
                  //       //       if (isConnected) {
                  //       //         if (password != null && password.length > 6) {
                  //       //           setState(() {
                  //       //             isSpinning = true;
                  //       //           });
                  //       //           FocusScope.of(context).unfocus();
                  //       //           signIn();
                  //       //         } else {
                  //       //           setState(() {
                  //       //             errorTextPassword = true;
                  //       //           });
                  //       //         }
                  //       //       }
                  //       //     },
                  //       //     child: Center(
                  //       //       child: Text(
                  //       //         'SIGN IN',
                  //       //         style: TextStyle(
                  //       //           color: Colors.white,
                  //       //           fontFamily: 'Montserrat',
                  //       //           fontWeight: FontWeight.w600,
                  //       //         ),
                  //       //       ),
                  //       //     ),
                  //       //   ),
                  //       // ),

                  //       // TextButton(
                  //       //   onPressed: () {
                  //       //     Vibration.vibrate(duration: 30);
                  //       //     FocusManager.instance.primaryFocus.unfocus();
                  //       //     Navigator.push(
                  //       //         context, ScaleRoute(page: SignUpScreen()));
                  //       //   },
                  //       //   child: Text(
                  //       //     "Don't have an account ? Sign Up",
                  //       //     style: TextStyle(color: Colors.black),
                  //       //   ),
                  //       // ),
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
