import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../utils/colors.dart';
import '../utils/global_variables.dart';

class CampSiteOpenImageScreen extends StatefulWidget {
  String postid;
  String campsitename;
  CampSiteOpenImageScreen(
      {Key? key, required this.postid, required this.campsitename})
      : super(key: key);

  @override
  State<CampSiteOpenImageScreen> createState() =>
      _CampSiteOpenImageScreenState();
}

class _CampSiteOpenImageScreenState extends State<CampSiteOpenImageScreen> {
  List<String> images = [];
  var activeIndex = 0;

  getImages() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Campsite')
        .doc(widget.postid)
        .get();
    final images =
        List<String>.from(docSnapshot.data()?['CamperSiteImages'] ?? []);
    this.images.addAll(images);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getImages();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: Text(
                widget.campsitename.length > 30
                    ? widget.campsitename.substring(0, 30) + '...'
                    : widget.campsitename,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
              ),
            ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CarouselSlider(
              items: images
                  .map((item) => Container(
                        //margin: EdgeInsets.symmetric(horizontal: 24),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                                image: NetworkImage(item), fit: BoxFit.cover)),
                      ))
                  .toList(),
              options: CarouselOptions(
                height: 400,
                autoPlay: false,
                enlargeCenterPage: true,
                viewportFraction: 1,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
                onPageChanged: (index, reason) =>
                    setState(() => activeIndex = index),
              ),
            ),
            AnimatedSmoothIndicator(
              activeIndex: activeIndex,
              count: images.length,
              effect: JumpingDotEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  dotColor: Colors.deepOrange.withOpacity(0.5),
                  activeDotColor: Colors.deepOrange),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: getAds(),
            )
          ],
        ),
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
      height: 50,
      child: AdWidget(ad: bannerAd),
    );
  }
}
