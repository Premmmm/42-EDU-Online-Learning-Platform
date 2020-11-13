import 'package:FortyTwo/Components/CourseDataDetails.dart';
import 'package:FortyTwo/Components/Data.dart';
import 'package:FortyTwo/Components/MySlide.dart';
import 'package:FortyTwo/Components/constants.dart';
import 'package:FortyTwo/Screens/Main%20Screens/CourseDetailsViewScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CategorySpecificCoursesScreen extends StatelessWidget {
  List<CourseDataDetails> currentCategoryCourses = [];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<Data>(context, listen: false);
    String currentCategory = provider.currentlySelectedCourseCategory;
    List<CourseCategories> courses = provider.courses;
    for (var i in courses) {
      if (i.category == currentCategory) {
        Provider.of<Data>(context, listen: false)
            .setIndexes(courses.indexOf(i), 0);
        currentCategoryCourses = i.courseDataDetails;
      }
    }
    return Scaffold(
      backgroundColor: Constants().backgroundColor,
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Courses on ${Provider.of<Data>(context).currentlySelectedCourseCategory}',
            style: TextStyle(fontFamily: 'MontserratBold'),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
          children: [
            for (int i = 0; i < currentCategoryCourses.length; i++)
              _CourseContainerWidget(
                primaryIndex: Provider.of<Data>(context).primaryIndex,
                secondaryIndex: i,
                course: currentCategoryCourses[i],
              )
          ],
        )),
      ),
    );
  }
}

class _CourseContainerWidget extends StatelessWidget {
  final CourseDataDetails course;
  final int primaryIndex;
  final int secondaryIndex;
  _CourseContainerWidget({this.course, this.primaryIndex, this.secondaryIndex});
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.fromLTRB(5, 6, 0, 20),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: () {
          Provider.of<Data>(context, listen: false)
              .setIndexes(primaryIndex, secondaryIndex);
          Navigator.push(
            context,
            SlideRightRoute(
              page: CourseDetailsViewScreen(
                course: course,
                primaryIndex: primaryIndex,
                secondaryIndex: secondaryIndex,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: '${course.icon}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: height * 0.25,
                    width: width * 0.9,
                    child: Image.network(
                      course.icon,
                      fit: BoxFit.cover,
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
              ),
              Hero(
                tag: '${course.name}',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                    width: width * 0.9,
                    child: Text(
                      course.name,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                ),
              ),
              Hero(
                tag: '${course.author}',
                child: Text(
                  course.author,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 12),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Container(
                    child: RatingBar(
                      initialRating: double.parse(course.rating),
                      minRating: 1,
                      itemSize: 20,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      glowRadius: 0.0,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 10,
                      ),
                      onRatingUpdate: null,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text('${course.rating}',
                      style: TextStyle(fontFamily: 'Montserrat')),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    '( ${course.reviewers}  Reviews )',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
