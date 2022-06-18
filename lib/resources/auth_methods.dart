import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yomate/models/user.dart' as model;
import 'package:yomate/resources/stroage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final FirebaseMessaging _messaging;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('Users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  //sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    //required Uint8List file,
    required String country,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        //register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        //print(cred.user!.uid);

        // String photoUrl =
        //     await StroageMethods().uploadImageToStroage('uploads', file, false);

        // if (country == "SingingCharacter.Australia") {
        //   country = "Australia";
        // } else {
        //   country = "Taiwan";
        // }

        //add user to database

        model.User user = model.User(
          bio: bio,
          blue_check: "0",
          coins: 0,
          country: country,
          email: email,
          exp: 0,
          id: cred.user!.uid,
          password: password,
          userimage:
              'https://firebasestorage.googleapis.com/v0/b/camping-ee9d0.appspot.com/o/user_default_image%2Fdefault_user_image.png?alt=media&token=240634b2-7f58-4fef-af73-cbeb194a131c',
          username: username,
          followers: [],
          following: [],
        );

        _firestore.collection('Users').doc(cred.user!.uid).set(user.toJson());
        _messaging = FirebaseMessaging.instance;
        String? token = await _messaging.getToken();
        //print('This token is ' + token!);

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({'token': token});
        res = "Successful";
      }
      // } on FirebaseAuthException catch (err) {
      //   if (err.code == 'invalid-email') {
      //     res = 'The email is badly formatted.';
      //   } else if (err.code == 'weak-password') {
      //     res = 'Password should be at least 6 characters.';
      //   }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //Login user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred.';

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'Successful';
      } else {
        res = 'Please enter all the fields';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
