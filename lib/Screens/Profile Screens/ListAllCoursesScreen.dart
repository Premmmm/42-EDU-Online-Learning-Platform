import 'package:FortyTwo/Components/Data.dart';
import 'package:FortyTwo/Components/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListAllCoursesScreen extends StatefulWidget {
  @override
  _ListAllCoursesScreenState createState() => _ListAllCoursesScreenState();
}

class _ListAllCoursesScreenState extends State<ListAllCoursesScreen> {
  final _firestoredb = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getCourses();
  }

  Future<void> _getCourses() async {
    User _user = Provider.of<Data>(context, listen: false).user;
    _firestoredb.collection(_user.email).get().then((snapshot) {
      for (var i in snapshot.docs) {
        if(i.id!='credentials' && i.id!='mobileLogin'){

        }
      }
    });
  }

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
            'Your Courses',
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
