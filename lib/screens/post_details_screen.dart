import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:video_player/video_player.dart';
import 'package:yomate/utils/global_variables.dart';

import '../responsive/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/comment_card.dart';
import 'comments_screen.dart';
import 'noti_comments_screen.dart';
import 'open_images.dart';

class PostDetailScreen extends StatefulWidget {
  String postid;
  PostDetailScreen({Key? key, required this.postid}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  var userData = {};
  List<String> images = [];
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  late TextEditingController reportController;
  int commentLen = 0;
  String profile_image = '';
  String username = '';
  String imageType = '';
  String postimage = '';
  String description = '';
  getUserData() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.postid)
          .get();
      print(userSnap);
      userData = userSnap.data()!;
      setState(() {
        username = userData['username'];
        profile_image = userData['profile_image'];
        imageType = userData['imageType'];
        postimage = userData['postimage'];
        description = userData['description'];
      });
    } catch (e) {}
  }

  getImages() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.postid)
        .get();
    final images = List<String>.from(docSnapshot.data()?['postImages'] ?? []);
    this.images.addAll(images);
    //print(images.length);

    setState(() {});
  }

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.postid)
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }

  void initState() {
    super.initState();
    getUserData();
    getImages();
    getComments();
    if (imageType != 'image') {
      _chewieController = ChewieController(
        videoPlayerController: VideoPlayerController.network(postimage),
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
              ),
            ),
      body: Container(
        // boundary needed for web
        decoration: BoxDecoration(
            border: Border.all(
              color: width > webScreenSize
                  ? secondaryColor
                  : mobileBackgroundColor,
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
                    backgroundImage: NetworkImage(profile_image),
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
                            child: Text(
                              username,
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
                ],
              ),
            ),
            //IMAGE SECTION
            GestureDetector(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: SizedBox(
                        child: imageType == 'image'
                            ? Container(
                                child: InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => OpenImageScreen(
                                        postid: widget.postid,
                                      ),
                                    ),
                                  ),
                                  child: images.length > 1
                                      ? Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            SizedBox(
                                              height: 250,
                                              width: double.infinity,
                                              child: Image.network(
                                                postimage,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            IconButton(
                                              color: Colors.orange,
                                              onPressed: () =>
                                                  Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OpenImageScreen(
                                                    postid: widget.postid,
                                                  ),
                                                ),
                                              ),
                                              icon: Icon(Icons.filter),
                                            ),
                                          ],
                                        )
                                      : SizedBox(
                                          height: 250,
                                          width: double.infinity,
                                          child: Image.network(
                                            postimage,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
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
            //DESCRIPTION AND NUMBER OF COMMENTS
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 8),
                    child: ReadMoreText(
                      description,
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
                        builder: (context) => NotiCommentScreen(
                          postid: widget.postid,
                          publisher: userData['publisher'],
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
                      DateFormat.yMd().format(userData['time'].toDate()),
                      style: const TextStyle(fontSize: 16, color: wordColor),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      DateFormat.yMd().format(userData['time'].toDate()),
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
            Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Posts')
                    .doc(widget.postid)
                    .collection('comments')
                    .orderBy('datePublished', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) => CommentCard(
                      snap: (snapshot.data! as dynamic).docs[index].data(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
