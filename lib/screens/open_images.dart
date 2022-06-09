import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yomate/responsive/firestore_methods.dart';

import '../utils/colors.dart';
import '../utils/global_variables.dart';

class OpenImageScreen extends StatefulWidget {
  String postid;
  OpenImageScreen({Key? key, required this.postid}) : super(key: key);

  @override
  State<OpenImageScreen> createState() => _OpenImageScreenState();
}

class _OpenImageScreenState extends State<OpenImageScreen> {
  List<String> images = [];
  var activeIndex = 0;

  getImages() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.postid)
        .get();
    final images = List<String>.from(docSnapshot.data()?['postImages'] ?? []);
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
                        // margin: EdgeInsets.symmetric(horizontal: 24),
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
            // DotsIndicator(
            //   dotsCount: images.length == 0 ? 1 : images.length,
            //   position: dotPosition.toDouble(),
            //   decorator: DotsDecorator(
            //       activeColor: Colors.deepOrange,
            //       color: Colors.deepOrange.withOpacity(0.5),
            //       spacing: EdgeInsets.all(2),
            //       activeSize: Size(8, 8),
            //       size: Size(6, 6)),
            // )
          ],
        ),
      ),
    );
  }
}
