import 'package:FortyTwo/Screens/Main%20Screens/FeaturedScreen.dart';
import 'package:FortyTwo/Screens/Profile%20Screens/ProfileScreen.dart';
import 'package:flutter/material.dart';

class BottomAppBarr extends StatelessWidget {
  final double height;
  final double width;
  final String currentScreen;
  BottomAppBarr({this.height, this.width, this.currentScreen});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 2,
      right: 2,
      child: Material(
        elevation: 5,
        color: Colors.blueGrey,
        child: Container(
          height: height * 0.7,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FlatButton(
                onPressed: () {
                  if(currentScreen!='FeaturedScreen')
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FeaturedScreen()));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.star_border_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                    Text(
                      'Featured',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Montserrat'),
                    )
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.play_circle_filled_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    Text(
                      'My Courses',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Montserrat'),
                    )
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      'assets/icons/youtube.png',
                      width: 33,
                      height: 33,
                    ),
                    Text(
                      'Youtube',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Montserrat'),
                    ),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  if (currentScreen != 'ProfileScreen')
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.person, size: 32, color: Colors.white),
                    Text(
                      'Profile',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Montserrat'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
