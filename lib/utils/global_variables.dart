import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yomate/screens/campsite_googlemap_screen.dart';
import 'package:yomate/screens/campsite_screen.dart';
import 'package:yomate/screens/feed_screen.dart';
import 'package:yomate/screens/group_screen.dart';
import 'package:yomate/screens/profile_screen.dart';
import 'package:yomate/screens/search_screen.dart';

import '../screens/add_post.dart';
import '../screens/new_multi_images.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  FeedScreen(),
  CampsiteGoogleMapScreen(),
  // CampsiteScreen(),
  //Text('Campsite'),
  SearchScreen(),
  AddPostScreen(),
  //MultiImagesUploadScreen(),
  GroupScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
