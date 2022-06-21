import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:yomate/screens/group_add_post.dart';
import 'package:yomate/screens/search_screen.dart';

import '../utils/colors.dart';
import '../utils/global_variables.dart';
import '../widgets/post_card.dart';

class GroupDetailScreen extends StatefulWidget {
  String groupType;
  GroupDetailScreen({Key? key, required this.groupType}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayOpacity: 0.4,
        overlayColor: Colors.black,
        children: [
          SpeedDialChild(
            backgroundColor: Colors.red,
            child: Icon(
              Icons.add_circle_outline,
            ),
            label: 'Add Post',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      GroupAddPosts(groupType: widget.groupType),
                ),
              );
            },
          ),
        ],
      ),
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
              title: Text(
                widget.groupType,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            //.where('country', isEqualTo: user.country)
            .where('type', isEqualTo: widget.groupType)
            //.orderBy('time', descending: true) //倒序開啟
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            //print("ok");
          }
          return ListView.separated(
              itemBuilder: (context, index) {
                if (index % 10 == 0) {
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
              itemCount: 20);
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
          ? "ca-app-pub-1266028592496119~9828708150"
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
