import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:yomate/main.dart';
import 'package:yomate/responsive/web_screen.dart';
import 'package:yomate/utils/utils.dart';

import '../providers/user_provider.dart';
import '../responsive/firestore_methods.dart';
import '../responsive/mobile_screen.dart';
import '../responsive/responsive_layout.dart';
import '../utils/colors.dart';
import '../utils/global_variables.dart';

class GroupAddPosts extends StatefulWidget {
  String groupType;
  GroupAddPosts({Key? key, required this.groupType}) : super(key: key);

  @override
  State<GroupAddPosts> createState() => _GroupAddPostsState();
}

class _GroupAddPostsState extends State<GroupAddPosts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selected = "0";
  final TextEditingController _descriptionController = TextEditingController();
  List<XFile> _selectFiles = [];
  final ImagePicker _picker = ImagePicker();
  late VideoPlayerController _controller;
  File? _videoFile;
  bool _isLoading = false;
  List<String> _arrImageUrl = [];

  late LatLng currentPostion;
  late double currentPostionLatitude, currentPostionLongitude;
  late String getlatlng, getSub, getSubDetails, getStreet, currentLatLng;

  void clearImage() {
    setState(() {
      _selected = "0";
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _selected = "0";
      getlatlng = '';
      getSub = '';
      getSubDetails = '';
      getStreet = '';
      currentPostionLatitude = 0;
      currentPostionLongitude = 0;
      currentLatLng = '';
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  Future<void> selectImage() async {
    if (_selectFiles != null) {
      _selectFiles.clear();
      setState(() {
        _selected = "0";
      });
    }
    try {
      final List<XFile>? imgs = await _picker.pickMultiImage(imageQuality: 20);
      if (imgs!.isNotEmpty && imgs.length <= 9) {
        _selectFiles.addAll(imgs);
        setState(() {
          _selected = "1";
        });
      } else {
        showSnackBar('Cannot upload over 9 photos', context);
        setState(() {
          _selected = "0";
        });
      }
      //print("List of selected images: " + imgs.length.toString());
    } catch (e) {
      print(e);
    }
  }

  Future<void> selectVideo() async {
    try {
      final XFile? _video =
          await _picker.pickVideo(source: ImageSource.gallery);

      setState(() {
        _selected = "2";
        _controller = VideoPlayerController.file(File(_video!.path))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized,
            //even before the play button has been pressed.
            setState(() {
              _controller.seekTo(Duration(milliseconds: 2));
            });
          });
        _controller.pause();
        _videoFile = File(_video.path);
        //print(_videoFile);
      });
    } catch (e) {
      print(e);
    }
  }

  void upLoadVideo(
    String description,
    String uid,
    String username,
    String profImage,
    String blue_check,
    String publisher,
    String type,
    double currentPostionLatitude,
    double currentPostionLongitude,
    String getSub,
  ) async {
    String res = "Some error occurred";
    if (_videoFile == null) return;
    try {
      setState(() {
        _isLoading = true;
      });
      String postid = _firestore.collection('Posts').doc().id;
      var videoUrl = await uploadVideoToStroage('videos', _videoFile!, true);
      await _firestore.collection('Posts').doc(postid).set({
        'Lat': currentPostionLatitude,
        'Lng': currentPostionLongitude,
        'blue_check': blue_check,
        'country': 'Australia',
        'description': description,
        'imageType': 'video',
        'like': [],
        'location': getSub,
        'postid': postid,
        'postimage': videoUrl,
        'profile_image': profImage,
        'publisher': uid,
        'saves': [],
        'sub': '',
        'time': DateTime.now(),
        'title': '',
        'type': widget.groupType,
        'username': username,
        'view': 0,
      });

      await _firestore
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'coins': FieldValue.increment(5),
        'exp': FieldValue.increment(5)
      });

      res = "Successful";
      if (res == "Successful") {
        setState(() {
          _isLoading = false;
        });
        showSnackBar("Posted", context);
        clearImage();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(res, context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  void upLoadFunction(
    List<XFile> _images,
    String description,
    String uid,
    String username,
    String profImage,
    String blue_check,
    String publisher,
    String type,
    double currentPostionLatitude,
    double currentPostionLongitude,
    String getSub,
  ) async {
    String res = "Some error occurred";
    try {
      setState(() {
        _isLoading = true;
      });
      String postid = _firestore.collection('Posts').doc().id;
      await _firestore.collection('Posts').doc(postid).set({
        'Lat': currentPostionLatitude,
        'Lng': currentPostionLongitude,
        'blue_check': blue_check,
        'country': 'Australia',
        'description': description,
        'imageType': 'image',
        'like': [],
        'location': getSub,
        'postImages': [],
        'postid': postid,
        'postimage': '',
        'profile_image': profImage,
        'publisher': uid,
        'saves': [],
        'sub': '',
        'time': DateTime.now(),
        'title': '',
        'type': widget.groupType,
        'username': username,
        'view': 0,
      });

      await Future.forEach(_images, (XFile image) async {
        var imageUrl = await uploadMultiImageToStroage('Posts', image, true);
        _arrImageUrl.add(imageUrl.toString());
      });

      await _firestore.collection('Posts').doc(postid).update({
        'postimage': _arrImageUrl[0],
      });

      await _firestore
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'coins': FieldValue.increment(5),
        'exp': FieldValue.increment(5)
      });

      await _firestore.collection('Posts').doc(postid).update({
        'postImages': FieldValue.arrayUnion(_arrImageUrl),
      });

      res = "Successful";
      if (res == "Successful") {
        setState(() {
          _isLoading = false;
        });
        showSnackBar("Posted", context);
        clearImage();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(res, context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<String> uploadMultiImageToStroage(
      String childName, XFile _image, bool isPost) async {
    Reference ref = _storage
        .ref()
        .child(childName)
        .child(FirebaseAuth.instance.currentUser!.uid);

    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    UploadTask uploadTask = ref.putFile(File(_image.path));

    await uploadTask.whenComplete(() {
      print(ref.getDownloadURL());
    });
    return await ref.getDownloadURL();
  }

  Future<String> uploadVideoToStroage(
      String childName, File _video, bool isPost) async {
    Reference ref = _storage
        .ref()
        .child('videos')
        .child(FirebaseAuth.instance.currentUser!.uid);

    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    UploadTask uploadTask = ref.putFile(_videoFile!);

    await uploadTask.whenComplete(() {
      print(ref.getDownloadURL());
    });
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;
    String value;
    if (_selected == "0") {
      return Material(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(4, 60, 0, 0),
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.photo,
                      size: 40,
                    ),
                    onPressed: () => selectImage(),
                  ),
                  Text(
                    'max: 9 photos',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.video_call,
                      size: 40,
                    ),
                    onPressed: selectVideo,
                  ),
                  Text(
                    'max: one video',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: width > webScreenSize
              ? webBackgroundColor
              : mobileBackgroundColor,
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white54,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              },
            ),
          ),
          title: const Text(
            'Post to',
            style: TextStyle(color: wordColor),
          ),
          centerTitle: false,
          actions: [
            TextButton(
              onPressed: () {
                if (_selected == "1") {
                  upLoadFunction(
                      _selectFiles,
                      _descriptionController.text,
                      user.id,
                      user.username,
                      user.userimage,
                      user.blue_check,
                      user.id,
                      'image',
                      currentPostionLatitude,
                      currentPostionLongitude,
                      getSub);
                } else {
                  upLoadVideo(
                      _descriptionController.text,
                      user.id,
                      user.username,
                      user.userimage,
                      user.blue_check,
                      user.id,
                      'video',
                      currentPostionLatitude,
                      currentPostionLongitude,
                      getSub);
                }
              },
              child: const Text(
                'Post',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            _isLoading
                ? const LinearProgressIndicator()
                : const Padding(
                    padding: EdgeInsets.only(top: 0),
                  ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group: ' + widget.groupType,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28),
                ),
                GestureDetector(
                  onTap: () async {
                    bool serviceEnabled;
                    LocationPermission permission;

                    serviceEnabled =
                        await Geolocator.isLocationServiceEnabled();
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
                    var position =
                        await GeolocatorPlatform.instance.getCurrentPosition();
                    List<Location> locations =
                        await locationFromAddress("17 Queen St Dandenong");
                    List<Placemark> placemarks = await placemarkFromCoordinates(
                        -42.9041118, 147.3247503);
                    // Text(
                    //   user.username,
                    //   style: const TextStyle(color: Colors.black),
                    // );
                    setState(() {
                      currentPostionLatitude = position.latitude.toDouble();
                      currentPostionLongitude = position.longitude.toDouble();
                      // currentLatLng = currentPostionLatitude.toString() +
                      //     " , " +
                      //     currentPostionLongitude.toString() +
                      //     " , " +
                      //     getSubDetails;
                      // currentPostion =
                      //     LatLng(position.latitude, position.longitude);
                      // getlatlng = locations.last.latitude.toString() +
                      //     " " +
                      //     locations.last.longitude.toString();
                      // getSub = placemarks.reversed.last.locality.toString();
                      getSubDetails = placemarks
                          .reversed.last.subAdministrativeArea
                          .toString();
                      // getStreet = placemarks.reversed.last.street.toString();
                      // //print(currentPostion);
                      // print(currentPostionLatitude);
                      // print(currentPostionLongitude);
                      // print(getSubDetails);

                      // currentLatLng =
                      //     user.username + " is at " + getSubDetails;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white54,
                          child: Icon(Icons.location_pin)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white54,
                  backgroundImage: NetworkImage(user.userimage),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    currentLatLng,
                    style: const TextStyle(fontSize: 16, color: wordColor),
                  ),
                ),
                Center(
                  child: getSubDetails == ''
                      ? Text(
                          user.username,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )
                      : Text(
                          user.username + " is at " + getSubDetails,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                        ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: TextField(
                    controller: _descriptionController,
                    style: TextStyle(color: wordColor),
                    decoration: const InputDecoration(
                        hintStyle: TextStyle(color: wordColor),
                        hintText: "What's on your mind?",
                        border: InputBorder.none),
                    maxLines: 8,
                  ),
                ),
              ],
            ),
            Expanded(
              child: _selectFiles.isNotEmpty
                  ? GridView.builder(
                      itemCount: _selectFiles.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Image.file(
                            File(_selectFiles[index].path),
                            fit: BoxFit.cover,
                          ),
                        );
                      })
                  : Container(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                          Center(
                            child: _controller.value.isPlaying == true
                                ? Visibility(
                                    visible: false,
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white60,
                                      child: Icon(
                                          _controller.value.isPlaying == true
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          size: 26,
                                          color: Colors.blue),
                                    ),
                                  )
                                : Visibility(
                                    visible: true,
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white60,
                                      child: Icon(
                                          _controller.value.isPlaying == true
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          size: 26,
                                          color: Colors.blue),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
            ),
            const Divider(),
            // Text(
            //   getlatlng +
            //       "," +
            //       getStreet +
            //       "," +
            //       getSub +
            //       " " +
            //       getSubDetails,
            //   style: const TextStyle(color: Colors.white),
            // ),
            // currentPostionLatitude.toString() +
            //     "," +
            //     currentPostionLongitude.toString()
            //Text(currentLatLng),
          ],
        ),
      );
    }
  }
}
