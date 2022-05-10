import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yomate/models/user.dart';
import 'package:yomate/providers/user_provider.dart';
import 'package:yomate/responsive/firestore_methods.dart';
import 'package:yomate/responsive/mobile_screen.dart';
import 'package:yomate/responsive/responsive_layout.dart';
import 'package:yomate/responsive/web_screen.dart';
import 'package:yomate/screens/home_screen.dart';
import 'package:yomate/screens/videoPick_screen.dart';
import 'package:yomate/utils/colors.dart';
import 'package:yomate/utils/global_variables.dart';
import 'package:yomate/utils/utils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  ImagePicker imagePicker = ImagePicker();
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
    'Fishing',
    'Camping',
    'Hiking',
    'Leisure',
    'Travelling'
  ];
  String? selectItems = 'Choose Sub';
  String? selectCategoryItems = 'Fishing';

  //GoogleMap
  late String getlatlng, getSub, getSubDetails, getStreet, currentLatLng;
  late LatLng currentPostion;
  late double currentPostionLatitude, currentPostionLongitude;

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
  ) async {
    setState(() {
      _isLoading = true;
    });
    //Stanley 07/04/2022 Mark
    // try {
    //   String res = await FirestoreMethods().uploadPost(
    //       _descriptionController.text,
    //       _file!,
    //       uid,
    //       username,
    //       profImage,
    //       blue_check,
    //       publisher,
    //       sub);
    //   if (res == "Successful") {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //     showSnackBar("Posted", context);
    //     clearImage();
    //     Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(
    //         builder: (context) => const ResponsiveLayout(
    //           mobileScreenLayout: MobileScreenLayout(),
    //           webScreenLayout: WebScreenLayout(),
    //         ),
    //       ),
    //     );
    //   } else {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //     showSnackBar(res, context);
    //   }
    // } catch (e) {
    //   showSnackBar(e.toString(), context);
    // }
    if (sub != 'Choose Sub') {
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
      showSnackBar("Please choose sub", context);
    }
  }

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Create a post'),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take a photo'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List? file = await pickImage(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose from gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.gallery);
                // final List<XFile>? imgs = await _picker.pickMultiImage();
                // if (imgs!.isNotEmpty) {
                //   selectedFiles.addAll(imgs);
                // }
                setState(() {
                  _file = file;
                });
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
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;
    String value;
    return _file == null
        ? Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: IconButton(
                    icon: const Icon(
                      Icons.photo,
                      size: 40,
                    ),
                    onPressed: () => _selectImage(context),
                    // onPressed: () {
                    //   selectImage();
                    // },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: IconButton(
                    icon: const Icon(
                      Icons.video_call,
                      size: 40,
                    ),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => VideoPickScreen())),
                    // onPressed: () {
                    //   selectImage();
                    // },
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
                  onPressed: () => postImage(
                      user.id,
                      user.username,
                      user.userimage,
                      user.userimage,
                      user.blue_check,
                      user.id,
                      selectItems.toString(),
                      selectCategoryItems.toString(),
                      currentPostionLatitude,
                      currentPostionLongitude,
                      getSubDetails),
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
                      child: DropdownButtonHideUnderline(
                        child: SizedBox(
                          width: 120,
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
                                              fontSize: 16, color: wordColor)),
                                    ))
                                .toList(),
                            onChanged: (item) => setState(() {
                              selectCategoryItems = item;
                            }),
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
                      child: DropdownButtonHideUnderline(
                        child: SizedBox(
                          width: 140,
                          child: DropdownButton<String>(
                            dropdownColor: Colors.white,
                            alignment: AlignmentDirectional.center,
                            value: selectItems,
                            items: items
                                .map((item) => DropdownMenuItem(
                                      alignment: AlignmentDirectional.center,
                                      value: item,
                                      child: Text(item,
                                          style: TextStyle(
                                              fontSize: 16, color: wordColor)),
                                    ))
                                .toList(),
                            onChanged: (item) => setState(() {
                              selectItems = item;
                            }),
                          ),
                        ),
                      ),
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
                          currentLatLng =
                              user.username + " is at " + getSubDetails;
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
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Display user photo
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
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
                    // Stanley 06/04/2022 mark
                    // SizedBox(
                    //   height: 45,
                    //   width: 45,
                    //   child: AspectRatio(
                    //     aspectRatio: 487 / 451,
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         image: DecorationImage(
                    //           image: MemoryImage(_file!),
                    //           fit: BoxFit.fill,
                    //           alignment: FractionalOffset.topCenter,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const Divider(),
                  ],
                ),
                //Show selected image
                SizedBox(
                  height: 250,
                  child: AspectRatio(
                    aspectRatio: 487 / 451,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: MemoryImage(_file!),
                          fit: BoxFit.fill,
                          alignment: FractionalOffset.topCenter,
                        ),
                      ),
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

  // File? myfile;
  // pickFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();

  //   if (result != null) {
  //     File file = File(result.files.single.path);
  //     setState(() {
  //       myfile = file;
  //     });
  //   } else {
  //     // User canceled the picker
  //   }
  // }

  Future<void> selectImage() async {
    if (selectedFiles != null) {
      selectedFiles.clear();
    }
    try {
      final List<XFile>? imgs = await _picker.pickMultiImage();
      if (imgs!.isNotEmpty) {
        selectedFiles.addAll(imgs);
      }
      //print("image list : " + imgs.length.toString());
    } catch (e) {
      print(e.toString());
    }
    setState(() {});
  }
}
