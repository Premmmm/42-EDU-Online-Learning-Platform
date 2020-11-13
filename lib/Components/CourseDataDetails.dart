class CourseDataDetails {
  final String name;
  final String icon;
  final String description;
  final String author;
  final String rating;
  final String reviewers;
  final String duration;
  final String videoscount;

  CourseDataDetails(
      {this.name,
      this.icon,
      this.author,
      this.description,
      this.rating,
      this.reviewers,
      this.duration,
      this.videoscount});
}

class CourseCategories {
  final String category;
  final List<CourseDataDetails> courseDataDetails;
  CourseCategories({this.category, this.courseDataDetails});
}
