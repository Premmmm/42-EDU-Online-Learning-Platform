import 'package:FortyTwo/Screens/Main%20Screens/FeaturedScreen.dart';
import 'package:FortyTwo/Screens/My%20Courses%20Screens/MyCoursesScreen.dart';
import 'package:FortyTwo/Screens/Profile%20Screens/ProfileScreen.dart';
import 'package:FortyTwo/Screens/YouTube%20Screens/YouTubeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class AllCoursesScreen extends StatefulWidget {
  @override
  _AllCoursesScreenState createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen> {
  final double minWidth = 22;
  PageController pageController = PageController(initialPage: 0);
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    Future<bool> _onBackPressed() {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)), //this right here
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
                      'This will close the application',
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
                            SystemNavigator.pop();
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

    final height = MediaQuery.of(context).size.height * 0.1;
    return WillPopScope(
      onWillPop: () {
        return _onBackPressed();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: pageController,
                physics: ScrollPhysics(parent: NeverScrollableScrollPhysics()),
                children: [
                  FeaturedScreen(),
                  MyCoursesScreen(),
                  YouTubeScreen(),
                  ProfileScreen(),
                ],
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: height * 0.7,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  color: Color(0xFF13161D),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FlatButton(
                        minWidth: minWidth,
                        onPressed: () {
                          pageController.jumpToPage(0);
                          setState(() {
                            currentPageIndex = 0;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              currentPageIndex == 0
                                  ? Icons.star
                                  : Icons.star_border_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            Text(
                              'Featured',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                letterSpacing: 1,
                              ),
                            )
                          ],
                        ),
                      ),
                      FlatButton(
                        minWidth: minWidth,
                        onPressed: () {
                          pageController.jumpToPage(1);
                          setState(() {
                            currentPageIndex = 1;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              currentPageIndex == 1
                                  ? Icons.play_circle_filled_rounded
                                  : Icons.play_circle_outline_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            Text(
                              'My Courses',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                letterSpacing: 1,
                              ),
                            )
                          ],
                        ),
                      ),
                      FlatButton(
                        minWidth: minWidth,
                        onPressed: () {
                          pageController.jumpToPage(2);
                          setState(() {
                            currentPageIndex = 2;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              'assets/icons/youtubelogo.png',
                              width: 28,
                              height: 28,
                            ),
                            Text(
                              'Youtube',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FlatButton(
                        minWidth: minWidth,
                        onPressed: () {
                          pageController.jumpToPage(3);
                          setState(() {
                            currentPageIndex = 3;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              currentPageIndex == 3
                                  ? Icons.person
                                  : Icons.person_outline,
                              size: 28,
                              color: Colors.white,
                            ),
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 120.0),
//                   child: ElevatedButton(
//                       onPressed: () {
//                         // Vibration.vibrate(duration: 30);
//                         // FirebaseAuth.instance.signOut();
//                         // googleSignIn.signOut();
//                         // print(
//                         //     Provider.of<Data>(context, listen: false).userEmail);
//                         // Navigator.pop(context);
//                         print(Provider.of<Data>(context, listen: false)
//                             .userEmail);
//                       },
//                       child: Text('Sign Out')),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 120.0),
//                   child: ElevatedButton(
//                       onPressed: () {
//                         User user = FirebaseAuth.instance.currentUser;
//                         user.delete();
//                         _fireStoreDatabase
//                             .collection(
//                                 Provider.of<Data>(context, listen: false)
//                                     .userEmail)
//                             .doc('credentials')
//                             .delete();
//                       },
//                       child: Text('Delete Account')),
//                 ),
