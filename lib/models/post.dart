import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post {
  final String blue_check;
  final String country;
  final String description;
  final String imageType;
  final String location;
  final String postImages;
  final String postid;
  final String postimage;
  final String profile_image;
  final String publisher;
  final String sub;
  final time;
  final String title;
  final String type;
  final String username;
  final view;
  final like;

  const Post({
    required this.blue_check,
    required this.country,
    required this.description,
    required this.imageType,
    required this.location,
    required this.postImages,
    required this.postid,
    required this.postimage,
    required this.profile_image,
    required this.publisher,
    required this.sub,
    required this.time,
    required this.title,
    required this.type,
    required this.username,
    required this.view,
    required this.like,
  });

  Map<String, dynamic> toJson() => {
        "blue_check": blue_check,
        "country": country,
        "description": description,
        "imageType": "image",
        "location": location,
        "postImages": postImages,
        "postid": postid,
        "postimage": postImages,
        "profile_image": profile_image,
        "publisher": publisher,
        "sub": sub,
        "time": time,
        "title": "",
        "type": type,
        "username": username,
        "view": 0,
        "like": like,
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Post(
      blue_check: snapshot['blue_check'],
      country: snapshot['country'],
      description: snapshot['description'],
      imageType: snapshot['imageType'],
      location: snapshot['location'],
      postImages: snapshot['postImages'],
      postid: snapshot['postid'],
      postimage: snapshot['postimage'],
      profile_image: snapshot['profile_image'],
      publisher: snapshot['publisher'],
      sub: snapshot['sub'],
      time: snapshot['time'],
      title: "",
      type: snapshot['type'],
      username: snapshot['username'],
      view: 0,
      like: snapshot['like'],
    );
  }
}
