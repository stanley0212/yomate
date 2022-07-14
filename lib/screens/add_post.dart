import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import 'package:google_maps_webservice/places.dart' as location;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:places_service/places_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:yomate/locations/application_bloc.dart';
import 'package:yomate/models/user.dart' as model;
import 'package:yomate/providers/user_provider.dart';
import 'package:yomate/responsive/firestore_methods.dart';
import 'package:yomate/responsive/mobile_screen.dart';
import 'package:yomate/responsive/responsive_layout.dart';
import 'package:yomate/responsive/web_screen.dart';
import 'package:yomate/screens/home_screen.dart';
import 'package:yomate/utils/colors.dart';
import 'package:yomate/utils/global_variables.dart';
import 'package:yomate/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

import '../locations/location_controller.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  String _selected = "0";
  ImagePicker imagePicker = ImagePicker();
  List<XFile> _selectFiles = [];
  late XFile _pickVideo;
  File? _videoFile;
  List<String> _arrImageUrl = [];
  List<String> items = [
    'Choose Sub',
    'MEL',
    'NSW',
    'TAS',
    'QLD',
    'ACT',
    'SA',
    'WA',
    'NT'
  ];
  List<String> categoryItems = [
    'Choose Category',
    'Fishing',
    'Camping',
    'Hiking',
    'Leisure',
    'Travelling',
    'Thrifty',
  ];
  String? selectItems = 'Choose Sub';
  String? selectCategoryItems = 'Choose Category';

  //GoogleMap
  late String getlatlng,
      getSub,
      getSubDetails,
      getStreet,
      currentLatLng,
      getLocation;
  late LatLng currentPostion;
  late double currentPostionLatitude, currentPostionLongitude;
  TextEditingController searchAddressController = TextEditingController();

  //Check in
  var uuid = Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];
  double Lat = 0.0;
  double Lng = 0.0;
  String place_location = '';

  //Upload Video
  late VideoPlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getlatlng = '';
    getSub = '';
    getSubDetails = '';
    getStreet = '';
    currentPostionLatitude = 0;
    currentPostionLongitude = 0;
    currentLatLng = '';
    getLocation = '';

    searchAddressController.addListener(() {
      onchange();
    });
  }

  void onchange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }

    getSuggestion(searchAddressController.text);
  }

  void getSuggestion(String input) async {
    String gKey = "";
    String baseURL =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String request =
        '$baseURL?input=$input&key=$gKey&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();
    print("getSuggestion: " + response.body.toString());
    if (response.statusCode == 200) {
      setState(() {
        _placeList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  // void _getUserLocation() async {
  //   var position = await GeolocatorPlatform.instance.getCurrentPosition();

  //   setState(() {
  //     currentPostion = LatLng(position.latitude, position.longitude);
  //   });
  // }

  //Add multi images
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedFiles = [];

  void postImage(
    String uid,
    String username,
    String userImage,
    String profImage,
    String blue_check,
    String publisher,
    String sub,
    String type,
    currentPostionLatitude,
    currentPostionLongitude,
    getSubDetails,
    selectedFiles,
    Lat,
    Lng,
    place_location,
  ) async {
    setState(() {
      _isLoading = true;
    });
    if (type != 'Choose Category') {
      try {
        String res = await FirestoreMethods().uploadPost(
          _descriptionController.text,
          _file!,
          uid,
          username,
          profImage,
          blue_check,
          publisher,
          sub,
          type,
          currentPostionLatitude,
          currentPostionLongitude,
          getSubDetails,
          //selectedFiles,
          Lat,
          Lng,
          place_location,
        );
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
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar("Please choose category", context);
    }
  }

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Create a post'),
          children: [
            // SimpleDialogOption(
            //   padding: const EdgeInsets.all(20),
            //   child: const Text('Take a photo'),
            //   onPressed: () async {
            //     Navigator.of(context).pop();
            //     Uint8List? file = await pickImage(ImageSource.camera);
            //     setState(() {
            //       _file = file;
            //     });
            //   },
            // ),
            // SimpleDialogOption(
            //   padding: const EdgeInsets.all(20),
            //   child: const Text('Choose from gallery'),
            //   onPressed: () async {
            //     Navigator.of(context).pop();
            //     Uint8List file = await pickImage(ImageSource.gallery);
            //     setState(() {
            //       _file = file;
            //     });
            //   },
            // ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose multi photos'),
              onPressed: () async {
                selectImage();
                setState(() {});
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void clearImage() {
    setState(() {
      _selected = "0";
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
    double Lat,
    double Lng,
    String place_location,
  ) async {
    if (selectCategoryItems.toString() != 'Choose Category') {
      String res = "Some error occurred";
      if (_videoFile == null) return;
      try {
        setState(() {
          _isLoading = true;
        });
        String postid = _firestore.collection('Posts').doc().id;
        var videoUrl = await uploadVideoToStroage('videos', _videoFile!, true);
        await _firestore.collection('Posts').doc(postid).set({
          'Lat': Lat,
          'Lng': Lng,
          'blue_check': blue_check,
          'country': 'Australia',
          'description': description,
          'imageType': 'video',
          'like': [],
          'location': place_location,
          'postid': postid,
          'postimage': videoUrl,
          'profile_image': profImage,
          'publisher': uid,
          'saves': [],
          'sub': '',
          'time': DateTime.now(),
          'title': '',
          'type': selectCategoryItems.toString(),
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
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar("Please choose category", context);
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
    double Lat,
    double Lng,
    String place_location,
  ) async {
    if (selectCategoryItems.toString() != 'Choose Category') {
      String res = "Some error occurred";
      try {
        setState(() {
          _isLoading = true;
        });
        String postid = _firestore.collection('Posts').doc().id;
        await _firestore.collection('Posts').doc(postid).set({
          'Lat': Lat,
          'Lng': Lng,
          'blue_check': blue_check,
          'country': 'Australia',
          'description': description,
          'imageType': 'image',
          'like': [],
          'location': place_location,
          'postImages': [],
          'postid': postid,
          'postimage': '',
          'profile_image': profImage,
          'publisher': uid,
          'saves': [],
          'sub': '',
          'time': DateTime.now(),
          'title': '',
          'type': selectCategoryItems.toString(),
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
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar("Please choose category", context);
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
    return _selected == "0"
        ? Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                        // onPressed: () {
                        //   selectImage();
                        // },
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
          )
        : Scaffold(
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
                  onPressed: clearImage,
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
                          getSub,
                          Lat,
                          Lng,
                          place_location);
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
                          getSub,
                          Lat,
                          Lng,
                          place_location);
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
                    Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 228, 228,
                              228), //background color of dropdown button
                          border: Border.all(
                              color: Colors.white,
                              width: 3), //border of dropdown button
                          borderRadius: BorderRadius.circular(
                              50), //border raiuds of dropdown button
                          boxShadow: const <BoxShadow>[
                            //apply shadow on Dropdown button
                            BoxShadow(
                                color: Color.fromRGBO(
                                    0, 0, 0, 0.57), //shadow for button
                                blurRadius: 5) //blur radius of shadow
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: SizedBox(
                            width: 180,
                            child: DropdownButton<String>(
                              dropdownColor: Colors.white,
                              alignment: AlignmentDirectional.center,
                              value: selectCategoryItems,
                              items: categoryItems
                                  .map((item) => DropdownMenuItem(
                                        alignment: AlignmentDirectional.center,
                                        value: item,
                                        child: Text(item,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: wordColor)),
                                      ))
                                  .toList(),
                              onChanged: (item) => setState(() {
                                selectCategoryItems = item;
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 245, 126,
                            245), //background color of dropdown button
                        border: Border.all(
                            color: Colors.white,
                            width: 3), //border of dropdown button
                        borderRadius: BorderRadius.circular(
                            50), //border raiuds of dropdown button
                        boxShadow: const <BoxShadow>[
                          //apply shadow on Dropdown button
                          BoxShadow(
                              color: Color.fromRGBO(
                                  0, 0, 0, 0.57), //shadow for button
                              blurRadius: 5) //blur radius of shadow
                        ],
                      ),
                      //Stanley 05/06/2022 unused sub
                      // child: DropdownButtonHideUnderline(
                      //   child: SizedBox(
                      //     width: 140,
                      //     child: DropdownButton<String>(
                      //       dropdownColor: Colors.white,
                      //       alignment: AlignmentDirectional.center,
                      //       value: selectItems,
                      //       items: items
                      //           .map((item) => DropdownMenuItem(
                      //                 alignment: AlignmentDirectional.center,
                      //                 value: item,
                      //                 child: Text(item,
                      //                     style: TextStyle(
                      //                         fontSize: 16, color: wordColor)),
                      //               ))
                      //           .toList(),
                      //       onChanged: (item) => setState(() {
                      //         selectItems = item;
                      //       }),
                      //     ),
                      //   ),
                      // ),
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
                            return Future.error(
                                'Location permissions are denied');
                          }
                        }

                        if (permission == LocationPermission.deniedForever) {
                          return Future.error(
                              'Location permissions are permanently denied, we cannot request permissions.');
                        }
                        var position = await GeolocatorPlatform.instance
                            .getCurrentPosition();
                        List<Location> locations =
                            await locationFromAddress("17 Queen St Dandenong");
                        List<Placemark> placemarks =
                            await placemarkFromCoordinates(
                                -42.9041118, 147.3247503);

                        setState(() {
                          currentPostionLatitude = position.latitude.toDouble();
                          currentPostionLongitude =
                              position.longitude.toDouble();

                          // getSubDetails = placemarks
                          //     .reversed.last.subAdministrativeArea
                          //     .toString();
                        });
                      },
                      // child: Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   // children: const [
                      //   //   CircleAvatar(
                      //   //       radius: 16,
                      //   //       backgroundColor: Colors.white54,
                      //   //       child: Icon(Icons.location_pin)),
                      //   // ],
                      //   children: [
                      //     IconButton(
                      //       icon: Icon(Icons.location_pin),
                      //       onPressed: () {},
                      //     ),
                      //   ],
                      // ),
                      child: Container(
                        width: 200,
                        height: 100,
                        child: Column(
                          children: [
                            TextFormField(
                              style: TextStyle(color: Colors.black),
                              controller: searchAddressController,
                              decoration: InputDecoration(
                                  hintText: 'Check in? if you want',
                                  hintStyle: TextStyle(color: Colors.black)),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _placeList.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    onTap: () async {
                                      List<Location> locations =
                                          await locationFromAddress(
                                              _placeList[index]['description']);
                                      print(locations.last.latitude);
                                      print(locations.last.longitude);

                                      setState(() {
                                        searchAddressController.text =
                                            _placeList[index]['description'];
                                        getSubDetails =
                                            _placeList[index]['description'];
                                        Lat = locations.last.latitude;
                                        Lng = locations.last.longitude;
                                        place_location =
                                            _placeList[index]['description'];
                                      });
                                    },
                                    title: Text(
                                      _placeList[index]['description'],
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: CircleAvatar(
                        backgroundColor: Colors.white54,
                        backgroundImage: NetworkImage(user.userimage),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                              _controller.value.isPlaying ==
                                                      true
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
                                              _controller.value.isPlaying ==
                                                      true
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
              ],
            ),
          );
  }
}
