import 'package:FortyTwo/Components/constants.dart';
import 'package:flutter/material.dart';

class About42Edu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants().backgroundColor,
      appBar: AppBar(
        leadingWidth: 0,
        backgroundColor: Colors.transparent,
        leading: Container(),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'About 42EDU',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'MontserratBold',
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    '42 EDU',
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 30),
                  ),
                ),
                Center(
                  child: Text(
                    'v 1.0.0',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: Text(
                    'Welcome to 42 EDU!\n42 EDU is an online learning platform for all with a variety of courses, documentation and more in a single mobile app.\nMade exclusively for the love of tech and fun !',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
                  ),
                ),
                SizedBox(height: 100),
                Center(
                  child: Text(
                    'from',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                ),
                Center(
                  child: Text(
                    'S. PREM RAJ',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        letterSpacing: 2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
