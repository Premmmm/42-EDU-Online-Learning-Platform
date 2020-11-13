import 'package:FortyTwo/Components/CourseDataDetails.dart';
import 'package:FortyTwo/Components/Data.dart';
import 'package:FortyTwo/Components/constants.dart';
import 'package:FortyTwo/Components/MySlide.dart';
import 'package:FortyTwo/Components/trendingDetails.dart';
import 'package:FortyTwo/Screens/Main%20Screens/CategorySpecificCoursesScreen.dart';
import 'package:FortyTwo/Screens/Main%20Screens/CourseDetailsViewScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

final _realTimeDataBase = FirebaseDatabase.instance.reference();

class FeaturedScreen extends StatefulWidget {
  @override
  _FeaturedScreenState createState() => _FeaturedScreenState();
}

class _FeaturedScreenState extends State<FeaturedScreen> {
  final currentPage = 'FeaturedScreen';

  @override
  void initState() {
    super.initState();
    if (!Provider.of<Data>(context, listen: false).loggedIn) getTrending();
  }

  Future<void> getTrending() async {
    try {
      List<TrendingDetails> trendingCourses = [];
      await _realTimeDataBase
          .child('trending')
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          Map<dynamic, dynamic> values = snapshot.value;
          values.forEach((key, value1) {
            trendingCourses.add(TrendingDetails(
              category: key.toString(),
              imageUrl: value1.toString(),
            ));
          });
        }
      });
      Provider.of<Data>(context, listen: false).setTrending(trendingCourses);
      getCategories();
    } on FirebaseException {
      print('Trending Firebase Extentionnnn !!!');
    } catch (e) {
      print('Trending catch:  $e');
    }
  }

  Future<void> getCategories() async {
    print('getting categories daw ');
    List<String> _categories = [];
    List<CourseCategories> _courses = [];
    try {
      await _realTimeDataBase.child('categories').once().then(
        (snapshot) {
          if (snapshot.value != null) {
            Map<dynamic, dynamic> values = snapshot.value;
            values.forEach(
              (key, value) {
                _categories.add(key.toString());
              },
            );
            Provider.of<Data>(context, listen: false)
                .addCategories(_categories);
          }
        },
      );
    } on FirebaseException {
      print('Categories Firebase Extentionnnn !!!');
    } catch (e) {
      print('Categories catch:  $e');
    }

    for (int i = 0; i < _categories.length; i++) {
      List<CourseDataDetails> _courseDataDetails = [];
      List<String> _author = [];
      List<String> _name = [];
      List<String> _icon = [];
      List<String> _description = [];
      List<String> _rating = [];
      List<String> _reviewers = [];
      List<String> _duration = [];
      List<String> _videoscount = [];
      int len = 0;

      try {
        await _realTimeDataBase
            .child('courses')
            .child(_categories[i])
            .once()
            .then(
          (snapshot) {
            if (snapshot.value != null) {
              List<dynamic> snapshot1 = snapshot.value;
              for (var cat in snapshot1) {
                Map<dynamic, dynamic> values = cat;
                values.forEach(
                  (key, value) {
                    if (key.toString() == 'duration') {
                      _duration.add(value.toString());
                    }
                    if (key.toString() == 'videoscount') {
                      _videoscount.add(value.toString());
                    }
                    if (key.toString() == 'author') {
                      len += 1;
                      _author.add(value.toString());
                    } else if (key.toString() == 'icon')
                      _icon.add(value.toString());
                    else if (key.toString() == 'name')
                      _name.add(value.toString());
                    else if (key.toString() == 'rating')
                      _rating.add(value.toString());
                    else if (key.toString() == 'reviewers')
                      _reviewers.add(value.toString());
                    else if (key.toString() == 'description')
                      _description.add(value.toString());
                  },
                );
              }
            }
          },
        );
      } on FirebaseException {
        print('Course Details Firebase Exception !!!');
      } catch (e) {
        print('Course details catch:  $e');
      }

      for (int k = 0; k < len; k++) {
        _courseDataDetails.insert(
          k,
          CourseDataDetails(
            author: _author[k],
            icon: _icon[k],
            name: _name[k],
            videoscount: _videoscount[k],
            duration: _duration[k],
            rating: _rating[k],
            reviewers: _reviewers[k],
            description: _description[k],
          ),
        );
      }
      len = 0;
      _courses.insert(
          i,
          CourseCategories(
              category: _categories[i], courseDataDetails: _courseDataDetails));
    }
    Provider.of<Data>(context, listen: false).addCourses(_courses);
    Provider.of<Data>(context, listen: false).setLoggedIn(true);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final providerNoListen = Provider.of<Data>(context);
    return Scaffold(
      backgroundColor: Constants().backgroundColor,
      appBar: AppBar(
        leadingWidth: 0,
        backgroundColor: Color(0xff1B1B1B),
        leading: Container(),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '42 EDU',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'MontserratBold',
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            _SearchBar(),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Trending',
                    style:
                        TextStyle(fontSize: 25, fontFamily: 'MontserratBold')),
              ),
            ),
            if (Provider.of<Data>(context).trending.length != 0)
              _CarouselSliderWidget(
                  height, Provider.of<Data>(context).trending),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Categories',
                    style:
                        TextStyle(fontSize: 25, fontFamily: 'MontserratBold')),
              ),
            ),
            _CategoriesListWidget(),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Featured',
                    style:
                        TextStyle(fontSize: 25, fontFamily: 'MontserratBold')),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            providerNoListen.courses.length == 0
                ? Center(child: CircularProgressIndicator())
                : _FeaturedCategoriesAndCourses(),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}

class _FeaturedCategoriesAndCourses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final providerNoListen = Provider.of<Data>(context);
    final List<String> _categories = providerNoListen.categories;
    return Column(
      children: [
        for (int i = 0; i < _categories.length; i++)
          _CategoryContainerWidget(
            categoryName: _categories[i],
            index: i,
          )
      ],
    );
  }
}

class _CategoryContainerWidget extends StatelessWidget {
  final categoryName;
  final int index;
  _CategoryContainerWidget({this.categoryName, this.index});
  @override
  Widget build(BuildContext context) {
    final providerNoListen = Provider.of<Data>(context);
    final List<CourseCategories> _courses = providerNoListen.courses;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(categoryName,
                style: TextStyle(fontSize: 20, fontFamily: 'MontserratBold')),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int j = 0;
                    j < _courses[index].courseDataDetails.length;
                    j++)
                  _CourseContainerWidget(
                    course: _courses[index].courseDataDetails[j],
                    primaryIndex: index,
                    secondaryIndex: j,
                  )
              ],
            ),
          )
        ],
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
          Provider.of<Data>(context, listen: false)
              .setIndexes(primaryIndex, secondaryIndex);
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
                    height: height * 0.22,
                    width: width * 0.7,
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
                    width: width * 0.7,
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

class _CategoriesListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> _categories = Provider.of<Data>(context).categories;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < _categories.length; i++)
            _CategoriesContainerWidget(
              categoryName: _categories[i],
            )
        ],
      ),
    );
  }
}

class _CategoriesContainerWidget extends StatelessWidget {
  final categoryName;
  _CategoriesContainerWidget({this.categoryName});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(20)),
      child: TextButton(
        child: Text(
          categoryName,
          style: TextStyle(fontFamily: 'Montserrat', color: Colors.grey),
        ),
        onPressed: () {
          Provider.of<Data>(context, listen: false)
              .setCurrentlySelectedCourse(' ', ' ', categoryName);
          Navigator.push(
              context, SlideRightRoute(page: CategorySpecificCoursesScreen()));
        },
      ),
    );
  }
}

class _CarouselSliderWidget extends StatelessWidget {
  final height;
  final List<TrendingDetails> trendingCourses;
  _CarouselSliderWidget(this.height, this.trendingCourses);
  @override
  Widget build(BuildContext context) {
    final List<Widget> trendingCourseImageUrl = [];
    for (var i in trendingCourses) {
      trendingCourseImageUrl.add(
        InkWell(
          onTap: () {
            Provider.of<Data>(context, listen: false)
                .setCurrentlySelectedCourse(' ', ' ', i.category);
            Navigator.push(context,
                SlideRightRoute(page: CategorySpecificCoursesScreen()));
          },
          child: Image.network(
            i.imageUrl,
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
      );
    }

    return Container(
      height: height * 0.25,
      child: CarouselSlider(
        items: trendingCourseImageUrl,
        options: CarouselOptions(
          height: 400,
          aspectRatio: 16 / 9,
          viewportFraction: 0.8,
          initialPage: 0,
          enableInfiniteScroll: true,
          reverse: false,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
          autoPlayAnimationDuration: Duration(seconds: 1, milliseconds: 500),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(30, 30, 30, 0),
      decoration: BoxDecoration(
        border: Border.all(width: .5, color: Colors.grey),
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        decoration: InputDecoration(
            border: InputBorder.none,
            labelText: 'Search',
            suffixIcon: Icon(Icons.search, color: Colors.grey[850]),
            contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            labelStyle: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                color: Colors.grey[850],
                fontSize: 16)),
        onChanged: (value) {},
      ),
    );
  }
}
