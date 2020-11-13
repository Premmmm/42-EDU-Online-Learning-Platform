import 'package:FortyTwo/Components/CourseDataDetails.dart';
import 'package:FortyTwo/Components/Data.dart';
import 'package:FortyTwo/Components/FlushBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FortyTwo/Screens/SignIn%20Screens/LoginScreen.dart';

class CourseDetailsViewScreen extends StatefulWidget {
  final CourseDataDetails course;
  final int primaryIndex;
  final int secondaryIndex;
  CourseDetailsViewScreen(
      {this.course, this.primaryIndex, this.secondaryIndex});

  @override
  _CourseDetailsViewScreenState createState() =>
      _CourseDetailsViewScreenState();
}

class _CourseDetailsViewScreenState extends State<CourseDetailsViewScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final int primaryIndex = Provider.of<Data>(context).primaryIndex;
    final int secondaryIndex = Provider.of<Data>(context).secondaryIndex;
    final course = Provider.of<Data>(context)
        .courses[primaryIndex]
        .courseDataDetails[secondaryIndex];
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _BackGroundContainer(
              height: height,
              width: width,
            ),
            _CourseName(
              tag: course.name,
              height: height,
            ),
            _CourseIcon(
              height: height,
              width: width,
              tag: course.icon,
              icon: '${course.icon}',
            ),
            _EnrollButton(
              height: height,
              width: width,
              course: course,
            ),
            _CourseDetails(
              height: height,
              width: width,
              course: course,
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseDetails extends StatelessWidget {
  final height;
  final width;

  final CourseDataDetails course;
  _CourseDetails({this.height, this.width, this.course});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: height * .45,
      left: 30,
      right: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Author',
            style: TextStyle(
                fontFamily: 'MontserratBold',
                color: Colors.grey[800],
                fontSize: 25,
                letterSpacing: 1.5),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            course.author,
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.grey[800],
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Course Description',
            style: TextStyle(
                fontFamily: 'MontserratBold',
                color: Colors.grey[800],
                fontSize: 25,
                letterSpacing: 1.5),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            course.description,
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.grey[800],
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Tutorial Videos',
            style: TextStyle(
                fontFamily: 'MontserratBold',
                color: Colors.grey[800],
                fontSize: 25,
                letterSpacing: 1.5),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            '${course.videoscount} videos',
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.grey[800],
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Duration',
            style: TextStyle(
                fontFamily: 'MontserratBold',
                color: Colors.grey[800],
                fontSize: 25,
                letterSpacing: 1.5),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            course.duration,
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.grey[800],
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EnrollButton extends StatefulWidget {
  final height;
  final width;
  final CourseDataDetails course;
  _EnrollButton({this.height, this.width, this.course});

  @override
  __EnrollButtonState createState() => __EnrollButtonState();
}

class __EnrollButtonState extends State<_EnrollButton> {
  bool enrolled = false;
  bool isSpinning = true;

  // final fireStoreDatabse

  ShowFlushBar showFlushBar = ShowFlushBar();

  @override
  void initState() {
    super.initState();
    checkEnrollment();
  }

  Future<void> checkEnrollment() async {
    String email = Provider.of<Data>(context, listen: false).userEmail;
    await fireStoreDataBase
        .collection(email)
        .doc(widget.course.name)
        .get()
        .then(
      (snapshot) {
        if (snapshot.data() != null) {
          Map<dynamic, dynamic> value = snapshot.data();
          value.forEach(
            (key, value) {
              if (key.toString() == 'enrolled') {
                if (value.toString() == 'yes') {
                  setState(() {
                    enrolled = true;
                    isSpinning = false;
                  });
                  showFlushBar.showFlushBar(context, "Alert",
                      'You have alreay enrolled to this course, kindly proceed to MyCourses page');
                } else {
                  setState(() {
                    enrolled = false;
                    isSpinning = false;
                  });
                }
              }
            },
          );
        } else {
          setState(() {
            enrolled = false;
            isSpinning = false;
          });
        }
      },
    );
  }

  Future<void> setEnrollment() async {
    final int _primaryIndex =
        Provider.of<Data>(context, listen: false).primaryIndex;

    final _course =
        Provider.of<Data>(context, listen: false).courses[_primaryIndex];
    setState(() {
      isSpinning = true;
    });
    String email = Provider.of<Data>(context, listen: false).userEmail;
    await fireStoreDataBase.collection(email).doc(widget.course.name).set({
      'enrolled': 'yes',
      'completion': '0',
      'category': _course.category,
      'duration': widget.course.duration.toString(),
      'videosCount': widget.course.videoscount.toString(),
      'author': widget.course.author.toString(),
      'currentVideo': '0',
      'description': widget.course.description.toString(),
    });
    showFlushBar.showFlushBar(context, "Alert",
        'You have successfully enrolled to this course, kindly proceed to MyCourses page');
    setState(() {
      enrolled = true;
      isSpinning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: widget.width * 0.32,
      right: widget.width * 0.32,
      child: RaisedButton(
        color: Color(0xFF13161D),
        onPressed: enrolled
            ? () {}
            : () {
                setEnrollment();
              },
        child: isSpinning
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                enrolled ? 'Enrolled' : 'Enroll',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
      ),
    );
  }
}

class _CourseIcon extends StatelessWidget {
  final height;
  final width;
  final tag;
  final icon;
  _CourseIcon({this.height, this.icon, this.tag, this.width});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: height * 0.13,
      left: 50,
      right: 50,
      child: Hero(
        tag: tag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: height * 0.22,
            width: width * 0.6,
            decoration: BoxDecoration(
              image:
                  DecorationImage(image: NetworkImage(icon), fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseName extends StatelessWidget {
  final tag;
  final height;
  _CourseName({this.tag, this.height});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: height * 0.04,
      left: 8,
      right: 8,
      child: Hero(
        tag: tag,
        child: Material(
          color: Colors.transparent,
          child: Center(
              child: Text(
            tag,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontFamily: 'MontserratBold'),
          )),
        ),
      ),
    );
  }
}

class _BackGroundContainer extends StatelessWidget {
  final height;
  final width;
  _BackGroundContainer({this.height, this.width});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50))),
        height: height * 0.70,
      ),
    );
  }
}
