import 'dart:ui';
import 'package:FortyTwo/Components/Data.dart';
import 'package:FortyTwo/Components/FlushBarWidget.dart';
import 'package:FortyTwo/Components/MySlide.dart';
import 'package:FortyTwo/Components/constants.dart';
import 'package:FortyTwo/Screens/Profile%20Screens/About42Edu.dart';
import 'package:FortyTwo/Screens/Profile%20Screens/AccountSettingsScreen.dart';
import 'package:FortyTwo/Screens/Profile%20Screens/ListAllCoursesScreen.dart';
import 'package:FortyTwo/Screens/SignIn%20Screens/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibration/vibration.dart';

final _fireStoreDatabase = FirebaseFirestore.instance;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentPage = "ProfileScreen";
  int rewards = 0;
  @override
  void initState() {
    super.initState();
    getRewards();
  }

  Future<void> getRewards() async {
    _fireStoreDatabase
        .collection(Provider.of<Data>(context, listen: false).userEmail)
        .doc('rewards')
        .get()
        .then(
      (snapshot) {
        if (snapshot.data() != null) {
          Map<dynamic, dynamic> values = snapshot.data();
          values.forEach(
            (key, value) {
              if (key.toString() == 'rewards') {
                setState(() {
                  rewards = int.parse(value.toString());
                });
              }
            },
          );
        }
      },
    );
  }

  void deleteAccount() async {
    User user = FirebaseAuth.instance.currentUser;
    user.delete();
    try {
      print(googleSignIn.disconnect());
      await _fireStoreDatabase
          .collection(Provider.of<Data>(context, listen: false).userEmail)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } on FirebaseException {
      print('Profile delete account firebase exception daw');
      ShowFlushBar().showFlushBar(
          context, 'Alert', 'An error occured while trying to delete account');
    } catch (e) {
      print('Profile screen delete account exeption daw $e');
      ShowFlushBar().showFlushBar(
          context, 'Alert', 'An error occured while trying to delete account');
    }
  }

  void signOut() async {
    Vibration.vibrate(duration: 30);
    FirebaseAuth.instance.signOut();
    try {
      googleSignIn.signOut();
      await _fireStoreDatabase
          .collection(
              Provider.of<Data>(context, listen: false).userEmail.toString())
          .doc('mobileLogin')
          .update(
        {'loggedIn': 'no'},
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } on FirebaseException {
      print('Profile screeen sign out firebase exception daw');
      ShowFlushBar().showFlushBar(
          context, 'Alert', 'An error occured while trying to sign out');
    } catch (e) {
      print('Profile screen sign out exeption daw $e');
      ShowFlushBar().showFlushBar(
          context, 'Alert', 'An error occured while trying to sign out');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final User _user = Provider.of<Data>(context, listen: false).user;

    Future<bool> _conformationAlertDialog(String _message, String _command) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Container(
              height: 230,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'ARE YOU SURE?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red[900],
                        fontWeight: FontWeight.w600,
                        fontFamily: 'MontserratBold',
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Icon(
                            Icons.clear,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            if (_command == 'delete') {
                              deleteAccount();
                            } else {
                              signOut();
                            }
                          },
                          child: Icon(
                            Icons.check,
                            color: Colors.red[800],
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Constants().backgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0xff1B1B1B),
        leading: Container(),
        leadingWidth: 0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'PROFILE',
            style: TextStyle(fontFamily: 'MontserratBold'),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              children: [
                Center(
                  child: Text(
                    '$rewards',
                    style:
                        TextStyle(fontFamily: 'MontserratBold', fontSize: 17),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Center(
                    child: Icon(
                  Icons.star,
                  size: 20,
                )),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Container(
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: height * 0.2,
                  width: width * 0.43,
                  child: Image.network(
                    _user.photoURL,
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Center(
                child: Text(
                  _user.displayName.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'MontserratBold',
                    fontSize: 25,
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              ListTile(
                title: Text(
                  'Account Settings',
                  style:
                      TextStyle(fontFamily: 'Montserrat', color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                      context, SlideRightRoute(page: AccountSettingsScreen()));
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey,
                ),
              ),
              ListTile(
                title: Text(
                  'Your Courses',
                  style:
                      TextStyle(fontFamily: 'Montserrat', color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                      context, SlideRightRoute(page: ListAllCoursesScreen()));
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey,
                ),
              ),
              ListTile(
                title: Text(
                  'About 42 EDU',
                  style:
                      TextStyle(fontFamily: 'Montserrat', color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(context, SlideRightRoute(page: About42Edu()));
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey,
                ),
              ),
              ListTile(
                title: Text(
                  'Delete Account',
                  style:
                      TextStyle(fontFamily: 'Montserrat', color: Colors.grey),
                ),
                onTap: () {
                  _conformationAlertDialog(
                      'This will delete all your courses and progress',
                      'delete');
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey,
                ),
              ),
              TextButton(
                  onPressed: () {
                    _conformationAlertDialog(
                        'This will log you out of the current session',
                        'signout');
                  },
                  child: Text('Sign Out')),
            ],
          ),
        ),
      )),
    );
  }
}
