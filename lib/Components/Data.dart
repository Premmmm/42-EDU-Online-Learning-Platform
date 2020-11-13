import 'package:FortyTwo/Components/CourseDataDetails.dart';
import 'package:FortyTwo/Components/trendingDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Data extends ChangeNotifier {
  String userEmail;
  User user;
  String currentlySelectedCourse;
  String currentlySelectedAuthor;
  String currentlySelectedCourseCategory;
  int primaryIndex, secondaryIndex;
  bool loggedIn = false;
  List<String> categories = [];
  List<CourseCategories> courses = [];
  List<TrendingDetails> trending = [];

  void setTrending(List<TrendingDetails> _trendingDetails) {
    trending = _trendingDetails;
    notifyListeners();
  }

  void setUser(User _currentUser) {
    user = _currentUser;
    notifyListeners();
  }

  void setLoggedIn(bool log) {
    loggedIn = log;
    notifyListeners();
  }

  void setCurrentlySelectedCourse(
      String _course, String _author, String _category) {
    currentlySelectedCourse = _course;
    currentlySelectedAuthor = _author;
    currentlySelectedCourseCategory = _category;
    notifyListeners();
  }

  void setIndexes(int _priIndex, int _secIndex) {
    primaryIndex = _priIndex;
    secondaryIndex = _secIndex;
    notifyListeners();
  }

  void addCourses(List<CourseCategories> _courses) {
    courses = _courses;
    notifyListeners();
  }

  void addCategories(List<String> _category) {
    categories = _category;
    notifyListeners();
  }

  void setUserEmail(String _email) {
    userEmail = _email;
    notifyListeners();
  }
}
