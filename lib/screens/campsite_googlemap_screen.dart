import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yomate/utils/colors.dart';

class CampsiteGoogleMapScreen extends StatefulWidget {
  const CampsiteGoogleMapScreen({Key? key}) : super(key: key);

  @override
  _CampsiteGoogleMapScreenState createState() =>
      _CampsiteGoogleMapScreenState();
}

class _CampsiteGoogleMapScreenState extends State<CampsiteGoogleMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  late final Uint8List markerIcon;

  // List<String> images = [
  //   'assets/accomodation.png',
  //   'assets/beach.png',
  //   'assets/boat.png',
  //   'assets/campsite.png',
  // ];

  Uint8List? markerImage;
  final List<Marker> _markers = <Marker>[];
  // final List<LatLng> _latLang = <LatLng>[
  //   LatLng(33.6941, 72.9734),
  //   LatLng(33.7008, 72.9682),
  //   LatLng(33.6992, 72.9744),
  //   LatLng(33.6939, 72.9771),
  //   LatLng(33.6910, 72.9807),
  //   LatLng(33.7036, 72.9785)
  // ];
  final List<LatLng> getLatlng = <LatLng>[];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-42.883187304882235, 147.32749945640126),
    zoom: 15,
  );

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
  }

  // loadData() async {
  //   for (int i = 0; i < images.length; i++) {
  //     final Uint8List markerIcon =
  //         await getBytesFromAsset(images[i].toString(), 100);
  //     _markers.add(Marker(
  //         markerId: MarkerId(i.toString()),
  //         position: _latLang[i],
  //         icon: BitmapDescriptor.fromBytes(markerIcon),
  //         infoWindow: InfoWindow(title: 'The title of the marker')));
  //     setState(() {});
  //   }
  // }

  loadData() async {
    await FirebaseFirestore.instance.collection('Campsite').get().then(
      (querySnapshot) {
        querySnapshot.docs.forEach((element) {
          switch (element.data()['type']) {
            case 'Accomodation':
              markerIcon = 'assets/accomodation.png' as Uint8List;
              break;
            case 'Beach':
              markerIcon = 'assets/beach.png' as Uint8List;
              break;
            case 'Boat Ramp':
              markerIcon = 'assets/boat.png' as Uint8List;
              break;
            case 'Campsite':
              markerIcon = 'assets/campsite.png' as Uint8List;
              break;
          }
          // final Uint8List markerIcon =
          //     getBytesFromAsset(images[i].toString(), 100) as Uint8List;
          _markers.add(Marker(
              markerId: MarkerId(element.data()['CamperSiteID']),
              position: element.data()['CamperSiteLatitude'] +
                  "," +
                  element.data()['CamperSiteLongitude'],
              icon: BitmapDescriptor.fromBytes(markerIcon),
              infoWindow: InfoWindow(title: element.data()['CamperSiteName'])));
          setState(() {});
          print(element.data()['type']);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset(
          'assets/yomate_new_logo.svg',
          color: primaryColor,
          height: 32,
        ),
      ),
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: _kGooglePlex,
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          markers: Set<Marker>.of(_markers),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}
