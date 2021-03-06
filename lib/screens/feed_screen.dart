import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:yomate/models/user.dart';
import 'package:yomate/screens/notifications_screen.dart';
import 'package:yomate/utils/colors.dart';
import 'package:yomate/utils/global_variables.dart';
import 'package:yomate/widgets/post_card.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import '../providers/user_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late List<Object> countriesWithAds;
  late final FirebaseMessaging _messaging;
  //static const loadingTag = "##loading##"; //表尾標記
  //var _words = <String>[loadingTag];
  bool showRefreshLoad = false;
  late int user_badge = 0;

  // updateBadge() async {
  //   await FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .update({'badge': 0});
  // }

  getBadge() async {
    var getUserinfo = {};

    var userSnap2 = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    getUserinfo = userSnap2.data()!;
    if (getUserinfo['badge'] == null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'badge': 0});
    } else {
      setState(() {
        user_badge = getUserinfo['badge'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getBadge();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    //Provider.of<UserProvider>(context).refreshUser();
    //final User user = Provider.of<UserProvider>(context).getUser;
    getToken() async {
      String? token = await _messaging.getToken();
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'token': token});
    }

    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: SvgPicture.asset(
                'assets/yomate_new_logo.svg',
                //color: primaryColor,
                height: 40,
              ),
              actions: [
                // CircleAvatar(
                //   radius: 30,
                //   backgroundColor: Colors.white54,
                //   child: IconButton(
                //     onPressed: () {
                //       Navigator.of(context).push(
                //         MaterialPageRoute(
                //           builder: (context) => ChatRoomList(),
                //         ),
                //       );
                //     },
                //     icon: const Icon(
                //       Icons.message_outlined,
                //     ),
                //   ),
                // ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    user_badge > 0
                        ? Badge(
                            padding: EdgeInsets.all(3),
                            toAnimate: true,
                            position: BadgePosition.topEnd(top: 10, end: 15),
                            badgeContent: Text(user_badge.toString()),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white54,
                              child: IconButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .update({'badge': 0});
                                  FlutterAppBadger.removeBadge();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => NotificationScreen(
                                          userID: FirebaseAuth
                                              .instance.currentUser!.uid)));
                                },
                                icon: const Icon(
                                  Icons.notifications_active_sharp,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white54,
                            child: IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => NotificationScreen(
                                        userID: FirebaseAuth
                                            .instance.currentUser!.uid)));
                              },
                              icon: const Icon(
                                Icons.notifications_active_sharp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            //.where('country', isEqualTo: user.country)
            //.where('country', isEqualTo: 'Australia')
            .orderBy('time', descending: true) //倒序開啟
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // 👇 Handle error
          // if (snapshot.hasError) {
          //   return const Center(
          //     child: Text("snapshot.error"),
          //   );
          // }

          // // 👇 Handle lack of data
          // if (!snapshot.hasData) {
          //   return const Center(
          //     child: Text("Something when wrong - no data available"),
          //   );
          // }

          if (snapshot.hasData) {
            //print("ok");
          }
          //print(user.country);
          // return ListView.builder(
          //   itemCount: snapshot.data!.docs.length,
          //   itemBuilder: (context, index) => Container(
          //     margin: EdgeInsets.symmetric(
          //         horizontal: width > webScreenSize ? width * 0.3 : 0,
          //         vertical: width > webScreenSize ? 15 : 0),
          //     child: PostCard(
          //       snap: snapshot.data!.docs[index],
          //     ),
          //   ),
          // );
          return ListView.separated(
            itemBuilder: (context, index) {
              if (index % 5 == 0) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: width > webScreenSize ? width * 0.3 : 0,
                          vertical: width > webScreenSize ? 15 : 0),
                      child: PostCard(
                        snap: snapshot.data!.docs[index],
                      ),
                    ),
                    Center(
                      child: getAds(),
                    ),
                  ],
                );
              }
              return Container(
                margin: EdgeInsets.symmetric(
                    horizontal: width > webScreenSize ? width * 0.3 : 0,
                    vertical: width > webScreenSize ? 15 : 0),
                child: PostCard(
                  snap: snapshot.data!.docs[index],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 12.0,
              );
            },
            itemCount: 200,
            shrinkWrap: true,
          );
        },
      ),
    );
  }

  Widget getAds() {
    BannerAdListener bannerAdListener =
        BannerAdListener(onAdWillDismissScreen: (ad) {
      ad.dispose();
    }, onAdClosed: (ad) {
      debugPrint("Ad Got Closeed");
    });
    BannerAd bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Platform.isAndroid
          ? "ca-app-pub-1266028592496119/2639363712"
          : "ca-app-pub-1266028592496119/2639363712",
      listener: bannerAdListener,
      request: const AdRequest(),
    );

    bannerAd.load();

    return SizedBox(
      height: 100,
      child: AdWidget(ad: bannerAd),
    );
  }
}
