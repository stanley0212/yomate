import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:yomate/models/user.dart';
import 'package:yomate/providers/user_provider.dart';
import 'package:yomate/responsive/firestore_methods.dart';
import 'package:yomate/screens/comments_screen.dart';
import 'package:yomate/screens/profile_screen.dart';
import 'package:yomate/utils/colors.dart';
import 'package:yomate/utils/global_variables.dart';
import 'package:yomate/utils/utils.dart';
import 'package:yomate/widgets/comment_card.dart';
import 'package:yomate/widgets/like_animation.dart';
import 'package:yomate/widgets/save_animation.dart';

class CampsiteCard extends StatefulWidget {
  final snap;
  const CampsiteCard({Key? key, required this.snap}) : super(key: key);

  @override
  _CampsiteCardState createState() => _CampsiteCardState();
}

class _CampsiteCardState extends State<CampsiteCard> {
  int photoLen = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   getPhotos();
  // }

  // void getPhotos() async {
  //   try {
  //     QuerySnapshot snap = await FirebaseFirestore.instance
  //         .collection('Campsite')
  //         .doc(widget.snap['CamperSiteID'])
  //         .collection('CamperSiteImages')
  //         .get();
  //     photoLen = snap.docs.length;
  //   } catch (e) {
  //     showSnackBar(e.toString(), context);
  //   }
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    int _index = 0;
    final width = MediaQuery.of(context).size.width;
    //Provider.of<UserProvider>(context).refreshUser();
    final User user = Provider.of<UserProvider>(context).getUser;
    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
          border: Border.all(
            color:
                width > webScreenSize ? secondaryColor : mobileBackgroundColor,
          ),
          color: mobileBackgroundColor),
      //color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          //HEADER SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.snap['CamperSiteName'],
                ),
              ),
            ],
          ),
          //IMAGE SECTION
          GestureDetector(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  // child: Image.network(
                  //   widget.snap['CamperSiteName'], // late modity image array
                  //   fit: BoxFit.cover,
                  // ),
                  // child: Carousel(
                  //   dotSize: 6.0,
                  //   dotSpacing: 15.0,
                  //   dotPosition: DotPosition.bottomCenter,
                  //   images: [
                  //     Image.network(
                  //       widget.snap['CamperSiteImages']
                  //           [photoLen], // late modity image array
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ],
                  // ),
                  child: FutureBuilder(builder: (_,
                      AsyncSnapshot<
                              List<QueryDocumentSnapshot<Map<String, dynamic>>>>
                          snapShot) {
                    return snapShot.data == null
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: CarouselSlider.builder(
                                itemCount: snapShot.data!.length,
                                itemBuilder:
                                    (BuildContext context, index, int) {
                                  DocumentSnapshot<Map<String, dynamic>>
                                      sliderImage = snapShot.data![index];
                                  return SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Image.network(
                                        sliderImage['CamperSiteImages'],
                                        fit: BoxFit.fill,
                                      ));
                                },
                                options: CarouselOptions(
                                    viewportFraction: 1,
                                    initialPage: 0,
                                    autoPlay: true,
                                    height: 150,
                                    onPageChanged:
                                        (int i, carouselPageChangedReason) {
                                      setState(() {
                                        _index = i;
                                      });
                                    })),
                          );
                  }),
                ),
              ],
            ),
          ),
          //DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        // TextSpan(
                        //   text: widget.snap['username'],
                        //   style: const TextStyle(fontWeight: FontWeight.bold),
                        // ),
                        TextSpan(
                          text: '  ${widget.snap['CamperSiteDescription']}',
                        ),
                      ],
                    ),
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(vertical: 4),
                //   child: Text(
                //     DateFormat.yMd()
                //         .format(widget.snap['ServerTimeStamp'].toDate()),
                //     style: const TextStyle(fontSize: 16, color: secondaryColor),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
