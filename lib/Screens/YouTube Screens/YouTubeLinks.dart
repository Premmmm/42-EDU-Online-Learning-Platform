import 'package:FortyTwo/Components/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final _realtimedatabase = FirebaseDatabase.instance.reference();

class YouTubeLinksScreen extends StatefulWidget {
  final title;
  YouTubeLinksScreen({this.title});
  @override
  _YouTubeLinksScreenState createState() => _YouTubeLinksScreenState();
}

class _YouTubeLinksScreenState extends State<YouTubeLinksScreen> {
  List name = [];
  List links = [];
  @override
  void initState() {
    super.initState();

    getNameAndLinks();
  }

  Future<void> getNameAndLinks() async {
    await _realtimedatabase.child(widget.title.toString()).once().then((snap) {
      if (snap.value != null) {
        Map<dynamic, dynamic> values = snap.value;
        values.forEach((key, value) {
          setState(() {
            name.add(key.toString());
            links.add(value.toString());
          });

          print(value.toString());
        });
      }
    });

    setState(() {
      links = links;
      name = name;
    });
  }

  _openDocs(String _url) async {
    var url = _url;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants().backgroundColor,
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0.0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Hero(
            tag: widget.title.toString(),
            child: Material(
              color: Colors.transparent,
              child: Text(widget.title.toString(),
                  style: TextStyle(fontFamily: 'MontserratBold', fontSize: 15)),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (widget.title == 'JavaScript')
                _openDocs("https://www.javascript.com/");
              else if (widget.title == 'Java')
                _openDocs("https://www.java.com/en/");
              else if (widget.title == 'Flutter')
                _openDocs("https://flutter.dev/");
              else if (widget.title == 'Deep Learning')
                _openDocs(
                    "https://peltarion.com/?gclid=Cj0KCQjwt4X8BRCPARIsABmcnOoVBhcS5zmMLMrrYevrfyqtTMARs8ic23buKNk4kpt9g9wplcV4u1kaAg1mEALw_wcB");
            },
            icon: Icon(
              Icons.book,
              size: 20,
            ),
          )
        ],
      ),
      body: SafeArea(
          child: ListView(
        children: [
          for (int i = 0; i < links.length; i++)
            YouTubeLauncherListTile(
              name: name[i],
              link: links[i],
            ),
        ],
      )),
    );
  }
}

class YouTubeLauncherListTile extends StatelessWidget {
  final name;
  final link;
  YouTubeLauncherListTile({this.name, this.link});

  _openYoutube(String _url) async {
    var url = _url;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        _openYoutube(link);
      },
      title: Text(
        name,
        style: TextStyle(fontFamily: 'Montserrat'),
      ),
      trailing: Icon(Icons.video_label),
    );
  }
}
