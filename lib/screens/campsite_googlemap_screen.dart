import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yomate/screens/campsite_screen.dart';
import 'package:yomate/utils/colors.dart';

class CampsiteGoogleMapScreen extends StatefulWidget {
  const CampsiteGoogleMapScreen({Key? key}) : super(key: key);

  @override
  _CampsiteGoogleMapScreenState createState() =>
      _CampsiteGoogleMapScreenState();
}

class _CampsiteGoogleMapScreenState extends State<CampsiteGoogleMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  Uint8List? markerImage;
  final List<Marker> _markers = <Marker>[];
  final List<LatLng> getLatlng = <LatLng>[];
  late LatLng currentPostion;
  double currentlat = 0;
  double currentlng = 0;
  double? distanceMeter = 0;

  Uint8List? markerIcon;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  void initState() {
    super.initState();
    List<LatLng> getLatlng;
    loadData();
    getCurrentPostion();
  }

  getCurrentPostion() async {
    //get CurrentPosition
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // var position = await GeolocatorPlatform.instance.getCurrentPosition();
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentPostion = LatLng(position.latitude, position.longitude);
      currentlat = position.latitude;
      currentlng = position.longitude;
      _kGooglePlex = CameraPosition(
        target: currentPostion,
        zoom: 10,
      );
    });
  }

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-42.883187304882235, 147.32749945640126),
    zoom: 10,
  );

  loadData() async {
    await FirebaseFirestore.instance.collection('Campsite').get().then(
      (querySnapshot) {
        querySnapshot.docs.forEach((element) async {
          switch (element.data()['type']) {
            case 'Accommodation':
              markerIcon = await getBytesFromAsset(
                  'assets/accommodation_location.png', 100);
              break;
            case 'Beach':
              markerIcon =
                  await getBytesFromAsset('assets/beach_location.png', 100);
              break;
            case 'Boat Ramp':
              markerIcon =
                  await getBytesFromAsset('assets/boat_ramp_location.png', 100);
              break;
            case 'Campsite':
              markerIcon =
                  await getBytesFromAsset('assets/campsite_location.png', 100);
              break;
            case 'Information':
              markerIcon = await getBytesFromAsset(
                  'assets/information_location.png', 100);
              break;
            case 'Jetty':
              markerIcon =
                  await getBytesFromAsset('assets/jerry_location.png', 100);
              break;
            case 'Lookout':
              markerIcon =
                  await getBytesFromAsset('assets/lookout_location.png', 100);
              break;
            case 'Lighthouse':
              markerIcon = await getBytesFromAsset(
                  'assets/lighthouse_location.png', 100);
              break;
            case 'Hot Spring':
              markerIcon = await getBytesFromAsset(
                  'assets/hot_spring_location.png', 100);
              break;
          }
          //Calculate distance
          distanceMeter = Geolocator.distanceBetween(
              currentlat,
              currentlng,
              element.data()['CamperSiteLatitude'],
              element.data()['CamperSiteLongitude']);
          var distance = distanceMeter?.round().toInt();
          //print(distance! / 1000);
          _markers.add(
            Marker(
              markerId: MarkerId(element.data()['CamperSiteID']),
              position: LatLng(element.data()['CamperSiteLatitude'],
                  element.data()['CamperSiteLongitude']),
              onTap: () {
                _customInfoWindowController.addInfoWindow!(
                    Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 300,
                            height: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(
                                      element.data()['CamperSiteImages'][0]),
                                  fit: BoxFit.fitWidth,
                                  filterQuality: FilterQuality.high),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              //color: Colors.red,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 10, right: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  //width: 100,
                                  child: Text(
                                    element.data()['CamperSiteName'].length > 30
                                        ? element
                                                .data()['CamperSiteName']
                                                .substring(0, 30) +
                                            '...'
                                        : element.data()['CamperSiteName'],
                                    maxLines: 1,
                                    //overflow: TextOverflow.fade,
                                    //softWrap: false,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                const Spacer(),
                                // const Text(
                                //   '.3 mi.',
                                //   // widget.data!.date!,
                                // )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 10, right: 10),
                            child: Text(
                              element.data()['CamperSiteDescription'].length >
                                      80
                                  ? element
                                          .data()['CamperSiteDescription']
                                          .substring(0, 80) +
                                      '...'
                                  : element.data()['CamperSiteDescription'],
                              style: const TextStyle(color: Colors.black),
                              maxLines: 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 10, right: 10),
                            child: Text(
                              'Estimate Distance:' +
                                  (distance! / 1000).toString() +
                                  ' kms',
                              style: const TextStyle(color: Colors.black),
                              maxLines: 1,
                            ),
                          ),
                          // Padding(
                          //   padding:
                          //       EdgeInsets.only(top: 10, left: 10, right: 10),
                          //   child: Text(
                          //     'Facility:' + element.data()['CamperSiteSummary'],
                          //     style: const TextStyle(color: Colors.black),
                          //   ),
                          // ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CampsiteScreen(
                                      CamperSiteID:
                                          element.data()['CamperSiteID'],
                                      lat: element.data()['CamperSiteLatitude'],
                                      lng: element
                                          .data()['CamperSiteLongitude'])));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Text(
                                    'Information',
                                    style: TextStyle(color: Colors.red),
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    LatLng(element.data()['CamperSiteLatitude'],
                        element.data()['CamperSiteLongitude']));
              },
              icon: BitmapDescriptor.fromBytes(markerIcon!),
              infoWindow: InfoWindow(
                title: element.data()['CamperSiteName'],
              ),
            ),
          );
          setState(() {});
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset(
          'assets/yomate_new_logo.svg',
          //color: primaryColor,
          height: 40,
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            markers: Set<Marker>.of(_markers),
            // onMapCreated: (GoogleMapController controller) {
            //   _controller.complete(controller);
            // },
            onTap: (postion) {
              _customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
            onMapCreated: (GoogleMapController controller) {
              _customInfoWindowController.googleMapController = controller;
            },
            polylines: {
              const Polyline(
                polylineId: PolylineId('overview_polyline'),
                color: Colors.red,
                width: 5,
              )
            },
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 250,
            width: 300,
            offset: 35,
          ),
        ],
      ),
    );
  }
}
