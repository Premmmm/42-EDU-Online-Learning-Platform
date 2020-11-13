import 'package:FortyTwo/Components/constants.dart';
import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants().backgroundColor,
       appBar: AppBar(
        leadingWidth: 0,

        backgroundColor: Color(0xff1B1B1B),
        leading: Container(),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Account Settings',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'MontserratBold',
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
