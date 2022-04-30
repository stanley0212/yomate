import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
                Uint8List file = await pickImage(ImageSource.camera);
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
    String value;
    return _file == null
        ? Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () => _selectImage(context),
                  // onPressed: () {
                  //   selectImage();
                  // },
                ),
                IconButton(
                  icon: const Icon(Icons.video_call),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => VideoPickScreen())),
                  // onPressed: () {
                  //   selectImage();
                  // },
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: clearImage,
              ),
              title: const Text('Post to'),
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
                      selectCategoryItems.toString()),
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
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectCategoryItems,
                          items: categoryItems
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item,
                                        style: TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (item) => setState(() {
                            selectCategoryItems = item;
                          }),
                        ),
                      ),
                    ),
                    Center(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectItems,
                          items: items
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item,
                                        style: TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (item) => setState(() {
                            selectItems = item;
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.userimage),
                    ),
                    //Display user photo
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            hintText: 'Writing something',
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
                // Expanded(
                //   child: GridView.builder(
                //     itemCount: selectedFiles.length,
                //     gridDelegate:
                //         const SliverGridDelegateWithFixedCrossAxisCount(
                //             crossAxisCount: 3),
                //     itemBuilder: (BuildContext context, int index) {
                //       print("test: ");
                //       return Image.file(
                //         File(selectedFiles[index].path),
                //         fit: BoxFit.cover,
                //       );
                //     },
                //   ),
                // ),
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
