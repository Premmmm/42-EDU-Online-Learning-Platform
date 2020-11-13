import 'dart:ui';
import 'package:FortyTwo/Components/Data.dart';
import 'package:FortyTwo/Components/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

final firebasedb = FirebaseDatabase.instance.reference();
final firestoredb = FirebaseFirestore.instance;

class ViewCourseVideosScreen extends StatefulWidget {
  @override
  _ViewCourseVideosScreenState createState() => _ViewCourseVideosScreenState();
}

class _ViewCourseVideosScreenState extends State<ViewCourseVideosScreen>
    with SingleTickerProviderStateMixin {
  String initUrl = '';
  // "https://drive.google.com/uc?export=view&id=18gWIdhRCIjj8wF-HozQVsBjpHxvAeKJ3";

  VlcPlayerController _videoViewController;
  AnimationController _animationController;
  bool isPlaying = true;
  double sliderValue = 0.0;
  double currentPlayerTime = 0;
  double volumeValue = 100;
  String position = "";
  String duration = "";
  List<String> titles = [];
  List<String> videosLink = [];
  int numberOfCaptions = 0;
  int numberOfAudioTracks = 0;
  bool isBuffering = true,
      getCastDeviceBtnEnabled = false,
      isVisible = true,
      isFullscreen = false;

  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 400),
    );

    initializeVideo();
    super.initState();
    getVideoTitlesAndLinks();
  }

  @override
  void dispose() {
    _videoViewController.dispose();
    super.dispose();
  }

  void initializeVideo() {
    try {
      _videoViewController = new VlcPlayerController();
      _videoViewController.addListener(() {
        if (!this.mounted) return;
        if (_videoViewController.initialized) {
          var oPosition = _videoViewController.position;
          var oDuration = _videoViewController.duration;
          if (oDuration.inHours == 0) {
            var strPosition = oPosition.toString().split('.')[0];
            var strDuration = oDuration.toString().split('.')[0];
            position =
                "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
            duration =
                "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
          } else {
            position = oPosition.toString().split('.')[0];
            duration = oDuration.toString().split('.')[0];
          }
          sliderValue = _videoViewController.position.inSeconds.toDouble();
          numberOfCaptions = _videoViewController.spuTracksCount;
          numberOfAudioTracks = _videoViewController.audioTracksCount;

          switch (_videoViewController.playingState) {
            case PlayingState.PAUSED:
              setState(() {
                isBuffering = false;
              });
              print('paused');
              break;

            case PlayingState.STOPPED:
              setState(() {
                isPlaying = false;
                isBuffering = false;
              });
              print('stopped');
              break;
            case PlayingState.BUFFERING:
              setState(() {
                isBuffering = true;
              });
              print('playing');
              break;
            case PlayingState.PLAYING:
              setState(() {
                isBuffering = false;
              });
              print('buffering');
              break;
            case PlayingState.ERROR:
              setState(() {});
              print("VLC encountered error");
              break;
            default:
              setState(() {});
              break;
          }
        }
      });
    } catch (e) {
      print('initializeVideoListner error $e');
    }
  }

  Future<void> getVideoTitlesAndLinks() async {
    final provider = Provider.of<Data>(context, listen: false);
    final String category = provider.currentlySelectedCourseCategory;
    final String course = provider.currentlySelectedCourse;

    String _currentIndex;
    try {
      await firebasedb.child('courses').child(category).once().then(
        (snapshot) {
          if (snapshot.value != null) {
            List<dynamic> allCourses = snapshot.value;
            for (var currentCourse in allCourses) {
              Map<dynamic, dynamic> values = currentCourse;
              values.forEach((key, value) {
                if (key.toString() == 'name' && value.toString() == course) {
                  _currentIndex = allCourses.indexOf(currentCourse).toString();
                }
              });
            }
          }
        },
      );

      await firebasedb
          .child('courses')
          .child(category)
          .child(_currentIndex)
          .once()
          .then(
        (DataSnapshot snapshot) {
          if (snapshot.value != null) {
            Map<dynamic, dynamic> values = snapshot.value;
            values.forEach((key, value) {
              print(key);
              if (key.toString() == 'videosLink') {
                List<dynamic> allVideos = value;
                print('all videos ddaww $allVideos');
                for (var videoLink in allVideos) {
                  videosLink.add(videoLink.toString());
                }
              }
              if (key.toString() == 'videosTitle') {
                print('Inside videos title daw');
                List<dynamic> allTitles = value;
                print('all titles daw $allTitles');
                for (var videoTitle in allTitles) {
                  titles.add(videoTitle.toString());
                }
              }
            });
          }
        },
      );
      print('Category: $category');
      print('Course: $course');
      print('CourseIndex: $_currentIndex');
      print('VideosLink: $videosLink');
      print('Titles: $titles');

      setState(() {
        videosLink = videosLink;
        titles = titles;
      });
      getCurrentVideoIndex();
    } on FirebaseException {
      print('getVideoTitlesAndLinks firebase exception daww');
    } catch (e) {
      print('getVideoTitlesANdLinks catched error daw $e');
    }
  }

  Future<void> getCurrentVideoIndex() async {
    int _currentVideo = 0;
    var provider = Provider.of<Data>(context, listen: false);
    try {
      await firestoredb
          .collection(provider.userEmail)
          .doc(provider.currentlySelectedCourse)
          .get()
          .then((snapshot) {
        if (snapshot.data() != null) {
          Map<dynamic, dynamic> value = snapshot.data();
          value.forEach((key, value) {
            if (key.toString() == 'currentVideo') {
              _currentVideo = int.parse(value.toString());
            }
          });
        }
      });
      print('current video daw $_currentVideo');
      print(videosLink);
      _videoViewController.setStreamUrl(videosLink[_currentVideo]);
      _videoViewController.play();
      _animationController.forward();
    } on FirebaseException {
      print('GetvideoIndex firebase exception daww');
    } catch (e) {
      print('GetVideoIndex catched error daw $e');
    }
  }

  Future<void> setCurrentVideoIndex({int index}) async {
    var provider = Provider.of<Data>(context, listen: false);
    try {
      await firestoredb
          .collection(provider.userEmail)
          .doc(provider.currentlySelectedCourse)
          .update({'currentVideo': '$index'});
    } on FirebaseException {
      print('setVideoindex firebase exception daww');
    } catch (e) {
      print('setVideoindex catched error daw $e');
    }
  }

  void playOrPauseVideo() {
    String state = _videoViewController.playingState.toString();
    _animationController.status == AnimationStatus.completed
        ? _animationController.reverse()
        : _animationController.forward();

    if (state == "PlayingState.PLAYING") {
      _videoViewController.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      _videoViewController.play();
      setState(() {
        isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants().backgroundColor,
      body: Builder(builder: (context) {
        return Container(
          padding: EdgeInsets.only(top: 25),
          child: Column(
            children: <Widget>[
              RotatedBox(
                quarterTurns: isFullscreen ? 1 : 0,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            print('video tapped');
                            setState(() {
                              isVisible = isVisible ? false : true;
                            });
                          },
                          child: SizedBox(
                              height: 250,
                              child: VlcPlayer(
                                aspectRatio: 16 / 9,
                                url: initUrl,
                                isLocalMedia: false,
                                controller: _videoViewController,
                                options: [
                                  '--quiet',
                                  '--no-drop-late-frames',
                                  '--no-skip-frames',
                                  '--rtsp-tcp',
                                ],
                                hwAcc: HwAcc.DISABLED,
                                placeholder: Container(
                                  height: 250.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      CircularProgressIndicator()
                                    ],
                                  ),
                                ),
                              )),
                        ),
                        AnimatedOpacity(
                          opacity: isVisible ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 100),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isVisible = isVisible ? false : true;
                              });
                            },
                            child: SizedBox(
                              height: 250,
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  alignment: Alignment.center,
                                  color: Colors.black.withOpacity(0.5),
                                  width: width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        iconSize: 40,
                                        icon: Icon(Icons.replay_10_outlined),
                                        onPressed: isVisible
                                            ? () {
                                                _videoViewController.setTime(
                                                    sliderValue.toInt() * 1000 -
                                                        10000);
                                              }
                                            : null,
                                      ),
                                      IconButton(
                                        splashRadius: 20,
                                        iconSize: 70,
                                        icon: AnimatedIcon(
                                            icon: AnimatedIcons.play_pause,
                                            progress: _animationController),
                                        onPressed: isVisible
                                            ? () {
                                                playOrPauseVideo();
                                              }
                                            : null,
                                      ),
                                      IconButton(
                                        iconSize: 40,
                                        icon: Icon(Icons.forward_10_outlined),
                                        onPressed: isVisible
                                            ? () {
                                                _videoViewController.setTime(
                                                    sliderValue.toInt() * 1000 +
                                                        10000);
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: width * 0.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Text(position),
                              Expanded(
                                child: Slider(
                                  activeColor: Colors.blue,
                                  value: sliderValue,
                                  min: 0.0,
                                  max: _videoViewController.duration == null
                                      ? 1.0
                                      : _videoViewController.duration.inSeconds
                                          .toDouble(),
                                  onChanged: (progress) {
                                    setState(() {
                                      sliderValue = progress.floor().toDouble();
                                    });
                                    //convert to Milliseconds since VLC requires MS to set time
                                    _videoViewController
                                        .setTime(sliderValue.toInt() * 1000);
                                  },
                                ),
                              ),
                              Text(duration),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.fullscreen_sharp,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              isFullscreen = isFullscreen ? false : true;
                            });
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  color: Color(0xFF13161D),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Provider.of<Data>(context)
                                    .currentlySelectedCourse,
                                style: TextStyle(
                                    fontSize: 20, fontFamily: 'Montserrat'),
                              ),
                              SizedBox(height: 10),
                              Text(
                                Provider.of<Data>(context)
                                    .currentlySelectedAuthor,
                                style: TextStyle(
                                    fontSize: 15, fontFamily: 'Montserrat'),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        titles.length == 0
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(
                                child: Column(
                                  children: [
                                    for (int i = 0; i < titles.length; i++)
                                      InkWell(
                                        onTap: () {
                                          _videoViewController.stop();
                                          setCurrentVideoIndex(index: i);
                                          _videoViewController
                                              .setStreamUrl(videosLink[i]);
                                        },
                                        child: VideoTitleListTile(
                                          title: titles[i],
                                          index: i,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}

// ignore: must_be_immutable
class VideoTitleListTile extends StatelessWidget {
  final String title;
  int index;
  VideoTitleListTile({this.title, this.index});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text('${index + 1}'),
      title: Text(title),
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}

// https://drive.google.com/file/d/1LWfYLJr9dL4AVLCaQjKPqvXy1yPoPyTJ/view?usp=sharing
// 1LWfYLJr9dL4AVLCaQjKPqvXy1yPoPyTJ

// class _ViewCourseVideosScreenState extends State<ViewCourseVideosScreen>
//   with SingleTickerProviderStateMixin {
// final String urlToStreamVideo =
//     "https://drive.google.com/uc?export=view&id=1lrfJtZQIh7-TTdgqEl9863AEtJCksiUq";
// // https://www.youtube.com/watch?v=L3SflBuI8Rk
// // 'http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_60fps_normal.mp4';

// VlcPlayerController controller;
// AnimationController _animationController;
// @override
// void initState() {
//   super.initState();
//   _animationController = AnimationController(
//     vsync: this,
//     duration: Duration(milliseconds: 300),
//     reverseDuration: Duration(milliseconds: 400),
//   );
//   controller = VlcPlayerController(
//     onInit: () {
//       controller.pause();
//     },
//   );
// }

// @override
// void dispose() {
//   controller.pause();
//   super.dispose();
// }

// @override
// Widget build(BuildContext context) {
//   final double playerWidth = 640;
//   final double playerHeight = 360;

//   return WillPopScope(
//     onWillPop: () {
//       controller.stop();
//       Navigator.pop(context);
//       return;
//     },
//     child: Scaffold(
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.white,
//         onPressed: () {
//           _animationController.status == AnimationStatus.completed
//               ? _animationController.reverse()
//               : _animationController.forward();

//           setState(() async {
//             await controller.isPlaying()
//                 ? controller.pause()
//                 : controller.play();
//           });
//         },
//         child: AnimatedIcon(
//           size: 30,
//           color: Colors.blue,
//           icon: AnimatedIcons.pause_play,
//           progress: _animationController,
//         ),
//       ),
//       body: Stack(
//         // mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             height: playerHeight,
//             width: playerWidth,
//             child: new VlcPlayer(
//               aspectRatio: 16 / 9,
//               url: urlToStreamVideo,
//               controller: controller,
//               options: ['String', 'Haa'],
//               autoplay: true,
//               placeholder: Container(
//                 height: 250.0,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[CircularProgressIndicator()],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
// }

// class ViewCourseVideosScreen extends StatefulWidget {
//   final title;
//   final index;
//   ViewCourseVideosScreen({this.title, this.index});
//   @override
//   _ViewCourseVideosScreenState createState() => _ViewCourseVideosScreenState();
// }

// class _ViewCourseVideosScreenState extends State<ViewCourseVideosScreen> {
//   VideoPlayerController _controller;
//   Future<void> _initialiseVideoPlayerFuture;

//   @override
//   void initState() {
//     _controller = VideoPlayerController.network(
//         "https://drive.google.com/uc?export=view&id=1lrfJtZQIh7-TTdgqEl9863AEtJCksiUq");
//     // 'https://drive.google.com/uc?export=view&id=1v3t4MTfNgFU23WKck6v8bLbAuvtqgDiE');
//     _initialiseVideoPlayerFuture = _controller.initialize();
//     _controller.setLooping(true);
//     _controller.setVolume(1.0);
//     super.initState();

//     if (widget.index == 4) {
//       setRewards();
//     }
//   }

//   Future<void> setRewards() {
//     int rewards = 0;
//     FirebaseFirestore.instance
//         .collection(Provider.of<Data>(context, listen: false).userEmail)
//         .doc('rewards')
//         .get()
//         .then(
//       (snapshot) {
//         if (snapshot.data() != null) {
//           Map<dynamic, dynamic> values = snapshot.data();
//           values.forEach(
//             (key, value) {
//               if (key.toString() == 'rewards') {
//                 rewards = int.parse(value.toString());
//               }
//             },
//           );
//         }
//       },
//     );

//     FirebaseFirestore.instance
//         .collection(Provider.of<Data>(context, listen: false).userEmail)
//         .doc('rewards')
//         .set({'rewards': '${rewards + 10}'});
//   }

//   @override
//   void dispose() {
//     // _controller.pause();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
// appBar: AppBar(
//   leading: Container(),
//   leadingWidth: 0.0,
//   centerTitle: true,
//   title: Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: Hero(
//       tag: widget.title.toString(),
//       child: Material(
//         color: Colors.transparent,
//         child: Text(widget.title.toString(),
//             style: TextStyle(fontFamily: 'MontserratBold', fontSize: 15)),
//       ),
//     ),
//   ),
// ),
//       body: SafeArea(
//         child: FutureBuilder(
//             future: _initialiseVideoPlayerFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 return Center(
//                   child: AspectRatio(
//                     aspectRatio: _controller.value.aspectRatio,
//                     child: VideoPlayer(_controller),
//                   ),
//                 );
//               } else {
//                 return Center(child: CircularProgressIndicator());
//               }
//             }),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 30.0),
//         child: FloatingActionButton(
//           onPressed: () {
//             setState(
//               () {
//                 _controller.value.isPlaying
//                     ? _controller.pause()
//                     : _controller.play();
//               },
//             );
//           },
//           child: Icon(
//             _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//           ),
//         ),
//       ),
//     );
//   }
// }
