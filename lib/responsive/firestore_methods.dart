import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:yomate/models/post.dart';
import 'package:yomate/resources/stroage_methods.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      res = "Successful";
      print(post);
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postid, String id, List like) async {
    try {
      if (like.contains(id)) {
        await _firestore.collection('Posts').doc(postid).update({
          'like': FieldValue.arrayRemove([id]),
        });
      } else {
        await _firestore.collection('Posts').doc(postid).update({
          'like': FieldValue.arrayUnion([id]),
        });
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
      String username, String profilePic) async {
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

  //Save Post
  // Future<void> savePost(
  //   bool PostID,
  //   String UID,
  // ) async {
  //   try {
  //     await _firestore.collection('Saves').doc(UID).set({'PostID': PostID});
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  //getMulitImages
  // Future<List> getImages(String postid) async {
  //   try {
  //     final data = _firestore.collection('Posts').doc(postid).get();
  //     return data.data()["postImages"];
  //   } catch (e) {
  //     return null;
  //   }
  // }
}
