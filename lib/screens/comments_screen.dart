import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:yomate/models/user.dart';
import 'package:yomate/providers/user_provider.dart';
import 'package:yomate/responsive/firestore_methods.dart';
import 'package:yomate/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/comment_card.dart';

class CommentScreen extends StatefulWidget {
  final snap;
  const CommentScreen({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  var userData = {};
  String userimage = "";
  String username = "";
  String userid = "";
  String userToken = "";
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    getUserData();
    getUserToken();
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  getUserData() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      userData = userSnap.data()!;
      setState(() {
        username = userData['username'];
        userimage = userData['userimage'];
        userid = userData['id'];
      });
    } catch (e) {}
  }

  getUserToken() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.snap['publisher'])
          .get();
      userData = userSnap.data()!;
      setState(() {
        userToken = userData['token'];
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    //final User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Comments'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .doc(widget.snap['postid'])
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
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(userimage),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: _commentController,
                    decoration: const InputDecoration(
                      // hintText: 'Comment as ${user.username}',
                      hintText: 'Comment somethings',
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await FirestoreMethods().postComment(
                    widget.snap['postid'],
                    _commentController.text,
                    userid,
                    username,
                    userimage,
                    widget.snap['publisher'],
                  );

                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(widget.snap['publisher'])
                      .update({'badge': FieldValue.increment(1)});
                  var getUserinfo = {};
                  int user_badge = 0;
                  var userSnap2 = await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(widget.snap['publisher'])
                      .get();
                  getUserinfo = userSnap2.data()!;
                  user_badge = userData['badge'];

                  if (widget.snap['publisher'] !=
                      FirebaseAuth.instance.currentUser!.uid) {
                    sendPushMessage(
                        userToken,
                        _commentController.text,
                        username + " reply your post.",
                        widget.snap['postid'],
                        '',
                        user_badge);
                    FlutterAppBadger.updateBadgeCount(user_badge);
                  }

                  setState(() {
                    _commentController.text = "";
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: blueColor),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> sendPushMessage(String token, String body, String title,
    String postid, String images, int user_badge) async {
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAm2nkpqg:APA91bH9l8kYkJqGyGnVJhUe4dmG5KeYVrErEB_vl7vhZDGBAgFGOYsyHguDna-SBeP8juVoTtLQ61aI61QZ-46JFwaR-8KPai7CT6n4-jRZFBIMOHEl1Phj0MFxlF8JII92ZUEusIrI',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
            'sound': 'default',
            'badge': user_badge
          },
          'priority': 'high',
          'timeToLive': 24 * 60 * 60,
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'type': 'noti',
            'postid': postid
          },
          "to": token,
        },
      ),
    );
  } catch (e) {
    print("error push notification");
  }
}
