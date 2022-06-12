import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:yomate/models/user.dart';
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
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    //Provider.of<UserProvider>(context).refreshUser();
    final User user = Provider.of<UserProvider>(context).getUser;
    // SystemChrome.setEnabledSystemUIOverlays([]);
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
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white54,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.message_outlined,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white54,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications),
                  ),
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
          ? "ca-app-pub-3180077679928430~6561097742"
          : "ca-app-pub-3180077679928430/2621852739",
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
