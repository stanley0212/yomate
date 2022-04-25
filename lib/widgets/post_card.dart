import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:yomate/models/user.dart';
import 'package:yomate/providers/user_provider.dart';
import 'package:yomate/responsive/firestore_methods.dart';
import 'package:yomate/screens/comments_screen.dart';
import 'package:yomate/screens/profile_screen.dart';
import 'package:yomate/utils/colors.dart';
import 'package:yomate/utils/global_variables.dart';
import 'package:yomate/utils/utils.dart';
import 'package:yomate/widgets/comment_card.dart';
import 'package:yomate/widgets/like_animation.dart';
import 'package:yomate/widgets/save_animation.dart';

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
  //Show Video
  late final VideoPlayerController _videoPlayerController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    getComments();
    // _videoPlayerController =
    //     VideoPlayerController.network(widget.snap['postimage'])
    //       ..addListener(
    //         () {
    //           final bool isPlaying = _videoPlayerController.value.isPlaying;
    //           if (isPlaying != _isPlaying) {
    //             setState(
    //               () {
    //                 _isPlaying = isPlaying;
    //               },
    //             );
    //           }
    //         },
    //       )
    //       ..initialize().then(
    //         (_) {
    //           Timer(
    //             Duration(milliseconds: 0),
    //             () {
    //               if (!mounted) return;

    //               setState(() {});
    //               _videoPlayerController.play();
    //             },
    //           );
    //         },
    //       );
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

  savePost(String PostID, String UID) async {
    await FirebaseFirestore.instance
        .collection('Saves')
        .doc(UID)
        .set({PostID: true});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          //HEADER SECTION
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                .copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.snap['profile_image']),
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
                              builder: (context) => ProfileScreen(
                                uid: widget.snap['publisher'],
                              ),
                            ),
                          ),
                          child: Text(
                            widget.snap['username'],
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                                                  widget.snap['postId']
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
                        icon: const Icon(Icons.more_vert),
                      )
                    : Container(),
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: widget.snap['imageType'] == 'image'
                      ? Image.network(
                          widget.snap['postimage'],
                          //widget.snap['postimage'],
                          fit: BoxFit.cover,
                        )
                      : Image.network(widget.snap['profile_image']),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 120,
                    ),
                    isAnimating: isLikeAnimating,
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                  ),
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
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border,
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
                icon: const Icon(
                  Icons.comment_outlined,
                ),
              ),
              //Stanley 08/04/2022 Mark
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(
              //     Icons.send,
              //   ),
              // ),
              // Expanded(
              //   child: Align(
              //     alignment: Alignment.bottomRight,
              //     child: IconButton(
              //       // onPressed: () => savePost(widget.snap['postid'], user.id),
              //       onPressed: () {},
              //       icon: const Icon(Icons.bookmark_border),
              //     ),
              //   ),
              // )
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
                          ? const Icon(
                              Icons.bookmark,
                              color: Colors.red,
                            )
                          : const Icon(
                              Icons.bookmark_border,
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
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '  ${widget.snap['description']}',
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'View all $commentLen comments',
                      style:
                          const TextStyle(fontSize: 16, color: secondaryColor),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMd().format(widget.snap['time'].toDate()),
                    style: const TextStyle(fontSize: 16, color: secondaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVideo() => buildVideoPlayer();
  Widget buildVideoPlayer() => VideoPlayer(_videoPlayerController);
}
