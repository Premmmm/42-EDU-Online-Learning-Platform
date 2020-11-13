import 'package:FortyTwo/Components/Data.dart';
import 'package:FortyTwo/Components/MySlide.dart';
import 'package:FortyTwo/Components/constants.dart';
import 'package:FortyTwo/Screens/YouTube%20Screens/YouTubeLinks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class YouTubeScreen extends StatefulWidget {
  @override
  _YouTubeScreenState createState() => _YouTubeScreenState();
}

class _YouTubeScreenState extends State<YouTubeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants().backgroundColor,
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0.0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'YOUTUBE REFERENCES',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              for (int i = 0;
                  i <
                      Provider.of<Data>(context, listen: false)
                          .categories
                          .length;
                  i++)
                CategoriesListTile(
                  index: i,
                  title:
                      Provider.of<Data>(context, listen: false).categories[i],
                )
            ],
          ),
        ),
      ),
    );
  }
}

class CategoriesListTile extends StatelessWidget {
  final title;
  final index;
  CategoriesListTile({this.title, this.index});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            SlideRightRoute(
              page: YouTubeLinksScreen(
                title: title.toString(),
              ),
            ),
          );
        },
        title: Hero(
            tag: title.toString(),
            child: Material(color: Colors.transparent, child: Text(title))),
        trailing: Icon(Icons.keyboard_arrow_right),
      ),
    );
  }
}
