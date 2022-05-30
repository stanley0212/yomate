import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yomate/models/user.dart' as model;
import 'package:yomate/resources/stroage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        print(cred.user!.uid);

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
          id: cred.user!.uid,
          password: password,
          userimage:
              'https://firebasestorage.googleapis.com/v0/b/camping-ee9d0.appspot.com/o/uploads%2FFullLogo.png?alt=media&token=35a0d63f-255c-4cad-b40e-8e2048fbb5d2',
          username: username,
          followers: [],
          following: [],
        );

        _firestore.collection('Users').doc(cred.user!.uid).set(user.toJson());

        // _firestore.collection('Users').doc(cred.user!.uid).set({
        //   'bio': bio,
        //   'blue_check': "0",
        //   'country': "Australia",
        //   'email': email,
        //   'id': cred.user!.uid,
        //   'password': password,
        //   'userimage': photoUrl,
        //   'username': username,
        //   'followers': [],
        //   'following': [],
        // });
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
