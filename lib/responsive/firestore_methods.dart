import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:yomate/models/post.dart';
import 'package:yomate/resources/stroage_methods.dart';
import 'package:http/http.dart' as http;

import '../sqlite/database_helper.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   // All data
//   List<Map<String, dynamic>> myData = [];

//   bool _isLoading = true;
// // This function is used to fetch all data from the database
//   void _refreshData() async {
//     final data = await DatabaseHelper.getItems();

//     myData = data;
//     _isLoading = false;

//     final existingData = myData.firstWhere((element) => element['id'] == 1);
//     var noti_badge = existingData['badge'];
//     log(noti_badge);
//     noti_badge++;
//   }

  //upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
    // String publisher,
    String blue_check,
    String publisher,
    String sub,
    String type,
    double currentPostionLatitude,
    double currentPostionLongitude,
    String getSub,
  ) async {
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StroageMethods().uploadImageToStroage('Posts', file, true);

      String postid = _firestore.collection('Posts').doc().id;
      Post post = Post(
        Lat: currentPostionLatitude,
        Lng: currentPostionLongitude,
        blue_check: blue_check,
        country: "Australia",
        description: description,
        imageType: "image",
        location: '',
        postImages: photoUrl,
        postid: postid,
        postimage: photoUrl,
        profile_image: profImage,
        publisher: publisher,
        sub: getSub,
        time: DateTime.now(),
        title: '',
        type: type,
        username: username,
        view: 0,
        like: [],
      );
      _firestore.collection('Posts').doc(postid).set(
            post.toJson(),
          );

      await _firestore.collection('Posts').doc(postid).update({
        'postImages': FieldValue.arrayUnion([photoUrl]),
      });
      res = "Successful";
      print(post);
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postid, String id, List like, String username,
      String publisher) async {
    try {
      if (like.contains(id)) {
        await _firestore.collection('Posts').doc(postid).update({
          'like': FieldValue.arrayRemove([id]),
        });
      } else {
        await _firestore.collection('Posts').doc(postid).update({
          'like': FieldValue.arrayUnion([id]),
        });
        //Send Notification
        if (publisher != FirebaseAuth.instance.currentUser!.uid) {
          String uuid = const Uuid().v1();
          FirebaseFirestore.instance.collection('Notifications').doc(uuid).set({
            'comment': ' like your post',
            'isPost': 'false',
            'postid': postid,
            'time': DateTime.now(),
            'userid': FirebaseAuth.instance.currentUser!.uid,
            'received': publisher,
            'notid': uuid
          });
        }
        var userData = {};
        var getUsername = {};
        String userToken = "";
        String uname = "";
        var userSnap = await FirebaseFirestore.instance
            .collection('Users')
            .doc(publisher)
            .get();
        userData = userSnap.data()!;
        userToken = userData['token'];

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(publisher)
            .update({'badge': FieldValue.increment(1)});

        var getUserinfo = {};
        int user_badge = 0;
        var userSnap3 = await FirebaseFirestore.instance
            .collection('Users')
            .doc(publisher)
            .get();
        getUserinfo = userSnap3.data()!;
        user_badge = userData['badge'];

        var userSnap2 = await FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        getUsername = userSnap2.data()!;
        uname = getUsername['username'];
        //user_badge = userData['badge'];

        sendPushMessage(
            userToken, '', uname + ' like your post.', postid, '', user_badge);
        FlutterAppBadger.updateBadgeCount(user_badge);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> savePost(String postid, String id, List saves) async {
    try {
      if (saves.contains(id)) {
        await _firestore.collection('Posts').doc(postid).update({
          'saves': FieldValue.arrayRemove([id]),
        });
        //await _firestore.collection('Notifications').doc().delete();
      } else {
        await _firestore.collection('Posts').doc(postid).update({
          'saves': FieldValue.arrayUnion([id]),
        });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> postComment(String postid, String text, String id,
      String username, String profilePic, String publisher) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('Posts')
            .doc(postid)
            .collection('comments')
            .doc()
            .set({
          'profilePic': profilePic,
          'username': username,
          'id': id,
          'text': text,
          'commentid': commentId,
          'datePublished': DateTime.now(),
        });
        await _firestore
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'coins': FieldValue.increment(1),
          'exp': FieldValue.increment(1)
        });
        //Send Notification
        if (publisher != FirebaseAuth.instance.currentUser!.uid) {
          String uuid = const Uuid().v1();
          FirebaseFirestore.instance.collection('Notifications').doc(uuid).set({
            'comment': ' reply your post',
            'isPost': 'false',
            'postid': postid,
            'time': DateTime.now(),
            'userid': FirebaseAuth.instance.currentUser!.uid,
            'received': publisher,
            'notid': uuid
          });
        }
        //final data1 = await DatabaseHelper.createItem("1");
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //Delete SECTION
  Future<void> deletePost(String postid) async {
    try {
      await _firestore.collection('Posts').doc(postid).delete();
      await _firestore
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'coins': FieldValue.increment(-5),
        'exp': FieldValue.increment(-5)
      });
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  //Delete SECTION
  Future<void> reportPost(String postid, String commtext, String userID) async {
    try {
      String id = const Uuid().v1();
      await _firestore.collection('Report').doc(id).set({
        'postid': postid,
        'comment': commtext,
        'userID': userID,
        'time': DateTime.now(),
      });
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  //Delete Comment not yet complete
  Future<void> deleteComment(String id) async {
    try {
      await _firestore.collection('Posts').doc(id).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  //Follower
  Future<void> followUser(
    String uid,
    String followId,
  ) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('Users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('Users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('Users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('Users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('Users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
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
