import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yomate/utils/colors.dart';

class OldOpenImages extends StatefulWidget {
  String postid;
  OldOpenImages({Key? key, required this.postid}) : super(key: key);

  @override
  State<OldOpenImages> createState() => _OldOpenImagesState();
}

class _OldOpenImagesState extends State<OldOpenImages> {
  final urlImages = [
    'https://firebasestorage.googleapis.com/v0/b/camping-ee9d0.appspot.com/o/Posts%2F1630840282329.null?alt=media&token=ef4496f7-b313-4806-bb29-fb3192dec1d1',
    'https://firebasestorage.googleapis.com/v0/b/camping-ee9d0.appspot.com/o/Posts%2F1631445779652.null?alt=media&token=d09a6441-23b0-42a8-b1a6-ddeab82ed4ed',
    'https://firebasestorage.googleapis.com/v0/b/camping-ee9d0.appspot.com/o/Posts%2F1632318448723.null?alt=media&token=e016745a-7bf6-40b1-b936-435db258e158',
  ];
  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
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
            CarouselSlider.builder(
              options: CarouselOptions(
                height: 400,
                // enlargeCenterPage: true,
                // enlargeStrategy: CenterPageEnlargeStrategy.height,
                autoPlayInterval: Duration(seconds: 2),
                onPageChanged: (index, reason) =>
                    setState(() => activeIndex = index),
              ),
              itemCount: urlImages.length,
              itemBuilder: (context, index, realIndex) {
                final urlImage = urlImages[index];
                return buildImage(urlImage, index);
              },
            ),
            const SizedBox(
              height: 32,
            ),
            buildIndicator(),
          ],
        ),
      ),
    );
  }

  Widget buildImage(String urlImage, int index) => Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        color: Colors.grey,
        width: double.infinity,
        child: Image.network(
          urlImage,
          fit: BoxFit.cover,
        ),
      );
  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: urlImages.length,
        effect: JumpingDotEffect(dotHeight: 12, dotWidth: 12),
      );
}
