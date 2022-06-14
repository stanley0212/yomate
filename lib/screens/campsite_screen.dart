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

  String SummaryIcon = '';
  String SummaryName = '';
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
            SummaryIcon = 'assest/kitchen.png';
            SummaryName = 'Kitchen';
            break;
          case 2:
            SummaryIcon = 'assest/barbecue.png';
            SummaryName = 'Barbecue';
            break;
          case 3:
            SummaryIcon = 'assest/suit_any_car.png';
            SummaryName = 'Suit any car';
            break;
          case 4:
            SummaryIcon = 'assest/laundromat.png';
            SummaryName = 'Laundromat';
            break;
          case 5:
            SummaryIcon = 'assest/dump_station.png';
            SummaryName = 'Dump station';
            break;
          case 6:
            SummaryIcon = 'assest/large_vehicle_access.png';
            SummaryName = 'Large vechile access';
            break;
          case 7:
            SummaryIcon = 'assest/caravan_power.png';
            SummaryName = 'Caravan power';
            break;
          case 8:
            SummaryIcon = 'assest/hot_shower.png';
            SummaryName = 'How shower';
            break;
          case 9:
            SummaryIcon = 'assest/water_from_tap.png';
            SummaryName = 'Water from tap';
            break;
          case 10:
            SummaryIcon = 'assest/cellular_signal.png';
            SummaryName = 'Celluar signal';
            break;
          case 11:
            SummaryIcon = 'assest/cabin.png';
            SummaryName = 'Cabin';
            break;
          case 12:
            SummaryIcon = 'assest/wifi.png';
            SummaryName = 'Wifi';
            break;
          case 13:
            SummaryIcon = 'assest/wheelchair_accessible.png';
            SummaryName = 'Whellchair accessible';
            break;
          case 14:
            SummaryIcon = 'assest/pet_welcome.png';
            SummaryName = 'Pet welcome by arrangment';
            break;
          case 15:
            SummaryIcon = 'assest/househole_power.png';
            SummaryName = 'Household power';
            break;
          case 16:
            SummaryIcon = 'assest/surface.png';
            SummaryName = 'Surface';
            break;
          case 17:
            SummaryIcon = 'assest/credit_card.png';
            SummaryName = 'Credit card accepted';
            break;
          case 18:
            SummaryIcon = 'assest/bed_supplied.png';
            SummaryName = 'Bedding supplied';
            break;
          case 19:
            SummaryIcon = 'assest/toilet.png';
            SummaryName = 'Toilet';
            break;
          case 20:
            SummaryIcon = 'assest/internet.png';
            SummaryName = 'Internet';
            break;
          case 21:
            SummaryIcon = 'assest/swimming_pool.png';
            SummaryName = 'Swimming pool';
            break;
          case 22:
            SummaryIcon = 'assest/boat_ramp.png';
            SummaryName = 'Boat ramp';
            break;
          case 23:
            SummaryIcon = 'assest/fishing.png';
            SummaryName = 'Fishing';
            break;
          case 24:
            SummaryIcon = 'assest/kayaking.png';
            SummaryName = 'Kayaking';
            break;
          case 25:
            SummaryIcon = 'assest/short_walk.png';
            SummaryName = 'Internet';
            break;
          case 26:
            SummaryIcon = 'assest/snorkelling.png';
            SummaryName = 'Snorkelling';
            break;
          case 27:
            SummaryIcon = 'assest/camp_fire.png';
            SummaryName = 'Campfires permitted';
            break;
          case 28:
            SummaryIcon = 'assest/parking.png';
            SummaryName = 'Parking';
            break;
          case 29:
            SummaryIcon = 'assest/camping.png';
            SummaryName = 'Camping';
            break;
          case 30:
            SummaryIcon = 'assest/swimming.png';
            SummaryName = 'Swimming';
            break;
          case 31:
            SummaryIcon = 'assest/overnight_bushwalking.png';
            SummaryName = 'Overniger walk';
            break;
          case 32:
            SummaryIcon = 'assest/picnic_area.png';
            SummaryName = 'Picnic facilities';
            break;
          case 33:
            SummaryIcon = 'assest/visitor_centre.png';
            SummaryName = 'Visitor center';
            break;
          case 34:
            SummaryIcon = 'assest/car4wd.png';
            SummaryName = '4WD';
            break;
          case 35:
            SummaryIcon = 'assest/bike_cyclist.png';
            SummaryName = 'Cycling tracks';
            break;
          case 36:
            SummaryIcon = 'assest/hot_spring.png';
            SummaryName = 'Hot spring';
            break;
          case 37:
            SummaryIcon = 'assest/restaurant.png';
            SummaryName = 'Restaurant';
            break;
          case 38:
            SummaryIcon = 'assest/look_out.png';
            SummaryName = 'Look our';
            break;
          case 39:
            SummaryIcon = 'assest/jerry.png';
            SummaryName = 'Jetty';
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
                                  //margin: EdgeInsets.symmetric(horizontal: 24),
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
