import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String bio;
  final String blue_check;
  final int coins;
  final String country;
  final String email;
  final int exp;
  final List followers;
  final List following;
  final String id;
  final String password;
  final String userimage;
  final String username;

  const User({
    required this.bio,
    required this.blue_check,
    required this.coins,
    required this.country,
    required this.email,
    required this.exp,
    required this.followers,
    required this.following,
    required this.id,
    required this.password,
    required this.userimage,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        "bio": bio,
        "blue_check": blue_check,
        "coins": 0,
        "country": country,
        "email": email,
        "exp": 0,
        "followers": followers,
        "following": following,
        "id": id,
        "token": "",
        "password": password,
        "userimage": userimage,
        "username": username,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
      bio: snapshot['bio'],
      blue_check: snapshot['blue_check'],
      coins: 0,
      country: snapshot['country'],
      email: snapshot['email'],
      exp: 0,
      followers: snapshot['followers'],
      following: snapshot['following'],
      id: snapshot['id'],
      password: snapshot['password'],
      userimage: snapshot['userimage'],
      username: snapshot['username'],
    );
  }
}
