import 'package:FortyTwo/Components/Data.dart';
import 'package:FortyTwo/Components/MySlide.dart';
import 'package:FortyTwo/Components/constants.dart';
import 'package:FortyTwo/Screens/My%20Courses%20Screens/ViewCourseVideosScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final realTimeDataBase = FirebaseDatabase.instance.reference();
final fireStoreDataBase = FirebaseFirestore.instance;

class MyCoursesScreen extends StatefulWidget {
  @override
  _MyCoursesScreenState createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  List<String> myCourses = [];
  List<String> author = [];
  List<String> category = [];
  bool isSpinning = false;
  bool noCourses = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isSpinning = true;
    });
    _checkCourses();
  }

  Future<void> _checkCourses() async {
    print('Getting all courses and their details !');
    QuerySnapshot querySnapshot = await fireStoreDataBase
        .collection(Provider.of<Data>(context, listen: false).userEmail)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      if (a.id != 'credentials' && a.id != 'mobileLogin' && a.id != 'rewards') {
        myCourses.add(a.id.toString());
      }
    }

    for (String course in myCourses) {
      await fireStoreDataBase
          .collection(Provider.of<Data>(context, listen: false).userEmail)
          .doc(course)
          .get()
          .then(
        (snapshot) {
          if (snapshot.data() != null) {
            Map<dynamic, dynamic> values = snapshot.data();
            values.forEach(
              (key, value) {
                if (key.toString() == 'author') {
                  author.add(value.toString());
                } else if (key.toString() == 'category') {
                  category.add(value.toString());
                }
              },
            );
          }
        },
      );
    }
    setState(() {
      if (myCourses.length == 0) {
        noCourses = true;
      }
      noCourses = false;
      isSpinning = false;
      myCourses = myCourses;
      author = author;
      category = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (noCourses == true && isSpinning == false) {
      return Scaffold(
        backgroundColor: Constants().backgroundColor,
        appBar: AppBar(
          leading: Container(),
          backgroundColor: Constants().appBarBackgroundColor,
          leadingWidth: 0.0,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'MY COURSES',
              style: TextStyle(fontFamily: 'MontserratBold'),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'No courses availabe',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 25,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isSpinning == true && noCourses == false)
      return Scaffold(
        backgroundColor: Colors.black54,
        appBar: AppBar(
          leading: Container(),
          leadingWidth: 0.0,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'MY COURSES',
              style: TextStyle(fontFamily: 'MontserratBold'),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      );
    else
      return Scaffold(
        backgroundColor: Colors.black54,
        appBar: AppBar(
          leading: Container(),
          leadingWidth: 0.0,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'MY COURSES',
              style: TextStyle(fontFamily: 'MontserratBold'),
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              _CourseListWidget(
                myCourses: myCourses,
                authors: author,
                category: category,
              ),
            ],
          ),
        ),
      );
  }
}

class _CourseListWidget extends StatelessWidget {
  final List<String> myCourses;
  final List<String> authors;
  final List<String> category;
  _CourseListWidget({this.myCourses, this.authors, this.category});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < myCourses.length; i++)
            _MyCourseListTile(
              name: myCourses[i],
              author: authors[i],
              category: category[i],
            )
        ],
      ),
    );
  }
}

class _MyCourseListTile extends StatelessWidget {
  final String name;
  final String author;
  final String category;
  _MyCourseListTile({this.name, this.author, this.category});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () {
          Provider.of<Data>(context, listen: false)
              .setCurrentlySelectedCourse(name, author, category);
          Navigator.push(
            context,
            SlideRightRoute(
              page: ViewCourseVideosScreen(),
            ),
          );
        },
        title: Hero(
          tag: name.toString(),
          child: Material(
            color: Colors.transparent,
            child: Text(
              name,
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          color: Colors.white,
        ),
      ),
    );
  }
}
