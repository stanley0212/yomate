import 'dart:collection';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yomate/models/user.dart';
import 'package:yomate/screens/campsite_openImage.dart';
import 'package:yomate/utils/colors.dart';
import 'package:yomate/utils/global_variables.dart';
import 'package:yomate/widgets/campsite_card.dart';
import 'package:yomate/widgets/post_card.dart';

import '../providers/user_provider.dart';
import '../utils/utils.dart';

class CampsiteScreen extends StatefulWidget {
  String CamperSiteID;
  double lat, lng;
  CampsiteScreen(
      {Key? key,
      required this.CamperSiteID,
      required this.lat,
      required this.lng})
      : super(key: key);

  @override
  _CampsiteScreenState createState() => _CampsiteScreenState();
}

class _CampsiteScreenState extends State<CampsiteScreen> {
  List<String> images = [];
  List<int> _CamperSiteSummary = [];
  int activeIndex = 0;
  String CampsiteName = "";
  String CampSiteAddress = "";
  late LatLng currentPostion;
  final Set<Marker> markers = new Set();

  @override
  void initState() {
    super.initState();
    getCampsiteDetails();
    getImages();
    getFeature();
    setState(() {
      currentPostion = LatLng(widget.lat, widget.lng);
      _kGooglePlex = CameraPosition(
        target: currentPostion,
        zoom: 10,
      );
    });
  }

  Set<Marker> getmarkers() {
    //markers to place on map
    setState(() {
      markers.add(Marker(
        //add first marker
        markerId: MarkerId(currentPostion.toString()),
        position: currentPostion, //position of marker
        icon: BitmapDescriptor.defaultMarker,
        onTap: gotoCampsite(), //Icon for Marker
      ));
    });

    return markers;
  }

  gotoCampsite() {}

  CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(-42.883187304882235, 147.32749945640126),
    zoom: 10,
  );

  getCampsiteDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
          .instance
          .collection('Campsite')
          .doc(widget.CamperSiteID)
          .get();
      setState(() {
        CampsiteName = snap['CamperSiteName'];
        CampSiteAddress = snap['CamperSiteAddress'];
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  getImages() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Campsite')
        .doc(widget.CamperSiteID)
        .get();
    final images =
        List<String>.from(docSnapshot.data()?['CamperSiteImages'] ?? []);
    this.images.addAll(images);

    setState(() {});
  }

  getFeature() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Campsite')
        .doc(widget.CamperSiteID)
        .get();
    final CamperSiteSummary =
        List<int>.from(docSnapshot.data()?['CamperSiteSummary'] ?? []);

    setState(() {
      _CamperSiteSummary = CamperSiteSummary;
      _CamperSiteSummary.forEach((element) {
        switch (element) {
          case 1:
            break;
        }
        print(element);
      });
      //print(_CamperSiteSummary);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: Text(
                CampsiteName.length > 30
                    ? CampsiteName.substring(0, 30) + '...'
                    : CampsiteName,
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
      body: Column(
        children: [
          SizedBox(
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CampSiteOpenImageScreen(
                    postid: widget.CamperSiteID,
                    campsitename: CampsiteName,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CarouselSlider(
                        items: images
                            .map((item) => Container(
                                  margin: EdgeInsets.symmetric(horizontal: 24),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      image: DecorationImage(
                                          image: NetworkImage(item),
                                          fit: BoxFit.cover)),
                                ))
                            .toList(),
                        options: CarouselOptions(
                          height: 200,
                          autoPlay: false,
                          enlargeCenterPage: true,
                          viewportFraction: 0.8,
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          Container(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                child: InkWell(
                  onTap: () {
                    MapUtils.openMap(widget.lat, widget.lng);
                  },
                  child: Text(
                    CampSiteAddress.length < 1
                        ? 'Address: ' +
                            widget.lat.toString() +
                            " , " +
                            widget.lng.toString()
                        : 'Address: ' + CampSiteAddress,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // child: Text(
              //   CampSiteAddress.length < 1
              //       ? 'Address: ' +
              //           widget.lat.toString() +
              //           " , " +
              //           widget.lng.toString()
              //       : 'Address: ' + CampSiteAddress,
              //   style:
              //       TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              // ),
            ),
          ),
          const Divider(),
          Container(
            alignment: Alignment.centerLeft,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Features',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Divider(),
          Container(
            alignment: Alignment.centerLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Map',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: GoogleMap(
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              markers: getmarkers(),
            ),
          ),
        ],
      ),
    );
  }
}

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double lat, double lng) async {
    String googleMapUrl =
        "https://maps.google.com/maps?saddr=-42.88353381466741, 147.32366381373615&daddr=$lat,$lng";
    print(googleMapUrl);
    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      throw "Could not open GoogleMap";
    }
  }
}
