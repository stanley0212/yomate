import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:yomate/models/user.dart';
import 'package:yomate/providers/user_provider.dart';
import 'package:yomate/responsive/firestore_methods.dart';
import 'package:yomate/screens/comments_screen.dart';
import 'package:yomate/screens/follow_profile_screen.dart';
import 'package:yomate/screens/message_screen.dart';
import 'package:yomate/screens/profile_screen.dart';
import 'package:yomate/utils/colors.dart';
import 'package:yomate/utils/global_variables.dart';
import 'package:yomate/utils/utils.dart';
import 'package:yomate/widgets/comment_card.dart';
import 'package:yomate/widgets/like_animation.dart';
import 'package:yomate/widgets/save_animation.dart';

import '../screens/open_images.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLen = 0;
  int activeIndex = 0;
  List<String> images = [];
  //Show Video
  bool isPlaying = true;
  bool isPlayingLoop = true;
  VideoPlayerController? _controller;
  String data = 'video';
  ChewieController? _chewieController;
  late TextEditingController reportController;

  @override
  void initState() {
    super.initState();
    getComments();
    getImages();
    reportController = TextEditingController();

    if (widget.snap['imageType'] != 'image') {
      _chewieController = ChewieController(
        videoPlayerController:
            VideoPlayerController.network(widget.snap['postimage']),
        //aspectRatio: 16 / 9,
        autoInitialize: true,
        autoPlay: false,
        looping: false,
        showControls: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        },
      );
    }
  }

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.snap['postid'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }

  getImages() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.snap['postid'])
        .get();
    final images = List<String>.from(docSnapshot.data()?['postImages'] ?? []);
    this.images.addAll(images);

    setState(() {});
  }

  savePost(String PostID, String UID) async {
    await FirebaseFirestore.instance
        .collection('Saves')
        .doc(UID)
        .set({PostID: true});
  }

  @override
  void dispose() {
    //_controller!.dispose();
    _chewieController?.videoPlayerController.dispose();
    _chewieController?.dispose();
    reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    //Provider.of<UserProvider>(context).refreshUser();
    final User user = Provider.of<UserProvider>(context).getUser;
    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
          border: Border.all(
            color:
                width > webScreenSize ? secondaryColor : mobileBackgroundColor,
          ),
          color: mobileBackgroundColor),
      //color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          //HEADER SECTION
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8)
                .copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(widget.snap['profile_image']),
                  backgroundColor: Colors.white54,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FollowProfileScreen(
                                uid: widget.snap['publisher'],
                              ),
                            ),
                          ),
                          child: Text(
                            widget.snap['username'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: wordColor,
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.snap['publisher'].toString() == user.id
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ListView(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shrinkWrap: true,
                                    children: [
                                      'Delete',
                                    ]
                                        .map(
                                          (e) => InkWell(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Text(e),
                                              ),
                                              onTap: () {
                                                FirestoreMethods().deletePost(
                                                  widget.snap['postid']
                                                      .toString(),
                                                );
                                                // remove the dialog box
                                                Navigator.of(context).pop();
                                              }),
                                        )
                                        .toList()),
                              );
                            },
                          );
                        },
                        icon: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white54,
                            child: Icon(Icons.more_vert)),
                      )
                    : Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            cardColor: Colors.grey[200],
                          ),
                          child: PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.black,
                              ),
                              itemBuilder: (context) {
                                return <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'Report',
                                    child: const Text(
                                      'Report',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                            'Report Post',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: TextField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Enter report information',
                                            ),
                                            controller: reportController,
                                            autofocus: true,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                FirestoreMethods().reportPost(
                                                    widget.snap['postid'],
                                                    reportController.text,
                                                    user.id);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                'Submit',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ];
                              }),
                        ),
                      )
              ],
            ),
          ),
          //IMAGE SECTION
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                widget.snap['postid'],
                user.id,
                widget.snap['like'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: SizedBox(
                      //height: MediaQuery.of(context).size.height * 0.5,
                      //width: double.infinity,
                      child: widget.snap['imageType'] == 'image'
                          ? InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => OpenImageScreen(
                                    postid: widget.snap['postid'],
                                  ),
                                ),
                              ),
                              // child: Image.network(
                              //   widget.snap['postimage'],
                              //   fit: BoxFit.cover,
                              // ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CarouselSlider(
                                    items: images
                                        .map((item) => Container(
                                              // margin: EdgeInsets.symmetric(
                                              //     horizontal: 24),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  image: DecorationImage(
                                                    image: NetworkImage(item),
                                                    fit: BoxFit.cover,
                                                  )),
                                            ))
                                        .toList(),
                                    options: CarouselOptions(
                                      disableCenter: true,
                                      height: 250,
                                      autoPlay: false,
                                      enlargeCenterPage: true,
                                      viewportFraction: 1,
                                      // enlargeStrategy:
                                      //     CenterPageEnlargeStrategy.height,
                                      onPageChanged: (index, reason) =>
                                          setState(() => activeIndex = index),
                                    ),
                                  ),
                                  AnimatedSmoothIndicator(
                                    activeIndex: activeIndex,
                                    count: images.length,
                                    effect: JumpingDotEffect(
                                        dotHeight: 12,
                                        dotWidth: 12,
                                        dotColor:
                                            Colors.deepOrange.withOpacity(0.5),
                                        activeDotColor: Colors.deepOrange),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: SizedBox(
                                height: 400,
                                child: Chewie(controller: _chewieController!),
                              ),
                            )),
                ),
              ],
            ),
          ),
          //LIKE & COMMENT SECTION
          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap['like'].contains(user.id),
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    await FirestoreMethods().likePost(
                      widget.snap['postid'],
                      user.id,
                      widget.snap['like'],
                    );
                  },
                  icon: widget.snap['like'].contains(user.id)
                      ? const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white54,
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                        )
                      : const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white54,
                          child: Icon(
                            Icons.favorite_border,
                          ),
                        ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentScreen(
                      snap: widget.snap,
                    ),
                  ),
                ),
                icon: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white54,
                  child: Icon(
                    Icons.comment_outlined,
                  ),
                ),
              ),
              //Stanley 08/04/2022 Mark
              // CircleAvatar(
              //   radius: 20,
              //   backgroundColor: Colors.white54,
              //   child: IconButton(
              //     onPressed: () {
              //       // Navigator.of(context).push(
              //       //   MaterialPageRoute(
              //       //     builder: (context) => MessageScreen(),
              //       //   ),
              //       // );
              //       showDialog(
              //         useRootNavigator: false,
              //         context: context,
              //         builder: (context) {
              //           return Dialog(
              //             child: ListView(
              //               padding: const EdgeInsets.symmetric(vertical: 16),
              //               shrinkWrap: true,
              //               children: const [
              //                 Padding(
              //                   padding: EdgeInsets.all(8.0),
              //                   child: Text('123'),
              //                 ),
              //               ],
              //             ),
              //           );
              //         },
              //       );
              //     },
              //     icon: const Icon(
              //       Icons.send,
              //     ),
              //   ),
              // ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    // onPressed: () => savePost(widget.snap['postid'], user.id),
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_border),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SaveAnimation(
                    child: IconButton(
                      onPressed: () => FirestoreMethods().savePost(
                        widget.snap['postid'].toString(),
                        user.id,
                        widget.snap['saves'],
                      ),
                      icon: widget.snap['saves'].contains(user.id)
                          ? const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white54,
                              child: Icon(
                                Icons.bookmark,
                                color: Colors.red,
                              ),
                            )
                          : const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white54,
                              child: Icon(
                                Icons.bookmark_border,
                              ),
                            ),
                    ),
                    isAnimating: widget.snap['saves'].contains(user.id),
                    smallSave: true,
                  )
                  // Align(
                  //   alignment: Alignment.bottomRight,
                  //   child: IconButton(
                  //     // onPressed: () => savePost(widget.snap['postid'], user.id),
                  //     onPressed: () {},
                  //     icon: const Icon(Icons.bookmark_border),
                  //   ),
                  // )
                ],
              )
            ],
          ),
          //DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    '${widget.snap['like'].length} likes',
                    // style: Theme.of(context).textTheme.bodyText2,
                    style: const TextStyle(fontSize: 12, color: wordColor),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  // child: RichText(
                  //   text: TextSpan(
                  //     style: const TextStyle(color: primaryColor),
                  //     children: [
                  //       // TextSpan(
                  //       //   text: widget.snap['username'],
                  //       //   style: const TextStyle(fontWeight: FontWeight.bold),
                  //       // ),
                  //       TextSpan(
                  //         text: '${widget.snap['description']}',
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  child: ReadMoreText(
                    '${widget.snap['description']}',
                    trimLines: 2,
                    style: const TextStyle(
                      fontSize: 14,
                      color: wordColor,
                    ),
                    colorClickableText: Colors.pink,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: '... show more',
                    trimExpandedText: '...show less',
                    moreStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: wordColor,
                    ),
                    lessStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: wordColor,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentScreen(
                        snap: widget.snap,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'View all $commentLen comments',
                      style: const TextStyle(fontSize: 16, color: wordColor),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMd().format(widget.snap['time'].toDate()),
                    style: const TextStyle(fontSize: 16, color: wordColor),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
