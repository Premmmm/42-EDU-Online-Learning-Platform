// import 'dart:io';
// import 'package:FortyTwo/Components/Data.dart';
// import 'package:FortyTwo/MySlide.dart';
// import 'package:FortyTwo/Screens/AllCoursesScreen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:modal_progress_hud/modal_progress_hud.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vibration/vibration.dart';

// final _fireStoreDatabase = FirebaseFirestore.instance;

// class SignUpScreen extends StatefulWidget {
//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   String email;
//   String password;
//   String name;
//   bool isConnected;
//   bool isSpinning = false;
//   bool obscurePassword = true;
//   bool errorTextPassword = false;
//   bool errorTextEmail = false;
//   bool errorTextName = false;
//   bool errorTextMobileNumber = false;

//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//   TextEditingController _nameController = TextEditingController();

//   Future<void> checkConnection() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         setState(() {
//           isConnected = true;
//         });
//         return;
//       }
//     } on SocketException catch (_) {
//       setState(() {
//         isConnected = false;
//       });
//       return;
//     }
//   }

//   Future<void> signUp() async {
//     try {
//       UserCredential k = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);
//       if (k != null) {
//         await _fireStoreDatabase
//             .collection(email)
//             .doc('credentials')
//             .set({'name': '$name', 'email': '$email'});
//         var prefs1 = await SharedPreferences.getInstance();
//         var prefs2 = await SharedPreferences.getInstance();
//         await prefs1.setString('loginEmail', email);
//         await prefs2.setString('loginPassword', password);

//         setState(() {
//           isSpinning = false;
//         });
//         Provider.of<Data>(context, listen: false).setUserEmail(email);
//         Navigator.push(context, ScaleRoute(page: AllCoursesScreen()));
//       }
//     } on PlatformException {
//       setState(() {
//         isSpinning = false;
//       });
//       _scaffoldKey.currentState.showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 2),
//           content: Container(
//             height: 40,
//             child: Center(
//               child: Text(
//                 'Incorrect email or password',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//               ),
//             ),
//           ),
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         isSpinning = false;
//       });
//       _scaffoldKey.currentState.showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 2),
//           content: Container(
//             height: 40,
//             child: Center(
//               child: Text(
//                 'An error occurred while signing up',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//               ),
//             ),
//           ),
//         ),
//       );
//       print('Sign Up la error ${e.message}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     return ModalProgressHUD(
//       inAsyncCall: isSpinning,
//       child: Scaffold(
//         key: _scaffoldKey,
//         body: SafeArea(
//             child: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/images/BookBackground.png'),
//               fit: BoxFit.fill,
//             ),
//           ),
//           child: ListView(
//             reverse: true,
//             children: [
//               Container(
//                 height: height * 0.55,
//                 padding: EdgeInsets.symmetric(vertical: 25, horizontal: 5),
//                 margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Colors.white,
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: <Widget>[
//                     Padding(
//                       padding: const EdgeInsets.only(left: 10, bottom: 10),
//                       child: Text(
//                         'SIGN UP ',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 30),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: TextField(
//                         controller: _nameController,
//                         decoration: InputDecoration(
//                           labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                           labelText: 'Name',
//                           errorText:
//                               errorTextName ? 'Enter a valid name' : null,
//                           errorStyle: TextStyle(color: Colors.red),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                         onChanged: (value) {
//                           setState(() {
//                             errorTextName = false;
//                           });
//                           name = value;
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: TextField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                           labelText: 'Email',
//                           errorText: errorTextEmail
//                               ? 'Enter a valid email address'
//                               : null,
//                           errorStyle: TextStyle(color: Colors.red),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                         onChanged: (value) {
//                           setState(() {
//                             errorTextEmail = false;
//                           });
//                           email = value;
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(left: 10, right: 10, bottom: 25),
//                       child: TextField(
//                         controller: _passwordController,
//                         obscureText: obscurePassword,
//                         decoration: InputDecoration(
//                           labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                           labelText: 'Password',
//                           errorText: errorTextPassword
//                               ? 'Password should be of minimum 7 characters'
//                               : null,
//                           errorStyle: TextStyle(color: Colors.red),
//                           suffixIcon: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   obscurePassword =
//                                       obscurePassword ? false : true;
//                                 });
//                               },
//                               child: Icon(Icons.remove_red_eye)),
//                         ),
//                         onChanged: (value) {
//                           setState(() {
//                             errorTextPassword = false;
//                           });
//                           password = value;
//                         },
//                       ),
//                     ),
//                     Container(
//                       height: 55,
//                       margin:
//                           EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                       decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                               begin: Alignment.centerLeft,
//                               end: Alignment.centerRight,
//                               colors: [Colors.indigo, Colors.blue]),
//                           color: Colors.indigo,
//                           borderRadius: BorderRadius.circular(20)),
//                       child: FlatButton(
//                         onPressed: () async {
//                           await checkConnection();
//                           if (isConnected) {
//                             if (name != null &&
//                                 email != null &&
//                                 password != null) {
//                               if (password.length > 6) {
//                                 setState(() {
//                                   isSpinning = true;
//                                 });
//                                 signUp();
//                               } else {
//                                 setState(() {
//                                   errorTextPassword = true;
//                                 });
//                               }
//                             } else {
//                               if (name == null) {
//                                 setState(() {
//                                   errorTextName = true;
//                                 });
//                               } else if (email == null) {
//                                 setState(() {
//                                   errorTextEmail = true;
//                                 });
//                               } else if (password == null) {
//                                 setState(() {
//                                   errorTextPassword = true;
//                                 });
//                               }
//                             }
//                           }
//                         },
//                         child: Center(
//                           child: Text(
//                             'SIGN UP',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       height: 20,
//                       margin:
//                           EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20)),
//                       child: Center(
//                         child: InkWell(
//                           onTap: () {
//                             Vibration.vibrate(duration: 30);
//                             FocusManager.instance.primaryFocus.unfocus();
//                             Navigator.pop(context);
//                           },
//                           child: Text(
//                             "Already have an account ? Sign In",
//                             style: TextStyle(color: Colors.black),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         )),
//       ),
//     );
//   }
// }
