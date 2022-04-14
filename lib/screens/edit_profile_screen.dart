import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yomate/screens/profile_screen.dart';
import 'package:yomate/utils/colors.dart';

import '../models/user.dart' as model;
import '../providers/user_provider.dart';
import '../resources/auth_methods.dart';
import '../responsive/mobile_screen.dart';
import '../responsive/responsive_layout.dart';
import '../responsive/web_screen.dart';
import '../utils/utils.dart';
import '../widgets/text_field_input.dart';
import 'login_screen.dart';

class EditProfileScteen extends StatefulWidget {
  const EditProfileScteen({Key? key}) : super(key: key);

  @override
  _EditProfileScteenState createState() => _EditProfileScteenState();
}

class _EditProfileScteenState extends State<EditProfileScteen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;
  String _newValue = 'Australia';

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  void saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update(
            {'username': _usernameController.text, 'bio': _bioController.text});
    // if (_usernameController != null && _bioController != null) {
    //   await FirebaseFirestore.instance
    //       .collection('Users')
    //       .doc(FirebaseAuth.instance.currentUser!.uid)
    //       .update({
    //     'username': _usernameController.text,
    //     'bio': _bioController.text
    //   });
    // } else if (_usernameController != null && _bioController == null) {
    //   await FirebaseFirestore.instance
    //       .collection('Users')
    //       .doc(FirebaseAuth.instance.currentUser!.uid)
    //       .update({'username': _usernameController.text});
    // } else if (_bioController != null && _usernameController == null) {
    //   await FirebaseFirestore.instance
    //       .collection('Users')
    //       .doc(FirebaseAuth.instance.currentUser!.uid)
    //       .update({'bio': _bioController.text});
    // } else if (_bioController == null && _usernameController == null) {}

    // String res = await AuthMethods().saveProfile(
    //   email: _emailController.text,
    //   password: _passwordController.text,
    //   username: _usernameController.text,
    //   bio: _bioController.text,
    //   file: _image!,
    //   //country: _character.toString(),
    //   country: _newValue,
    // );
    //print(res);

    setState(() {
      _isLoading = false;
    });
    showSnackBar("Saved", context);
    //Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    model.User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Edit Proile'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(),
                flex: 2,
              ),
              const SizedBox(
                height: 12,
              ),
              //Circular widget to accept and show our selected file
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(user.userimage),
                        ),
                  Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo),
                      ))
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              //Text field input for username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: user.username,
                  border: OutlineInputBorder(),
                  labelText: user.username,
                ),
              ),
              // TextFieldInput(
              //   hintText: user.username,
              //   textInputType: TextInputType.text,
              //   textEditingController: _usernameController,
              // ),
              //Text field input for email
              const SizedBox(
                height: 12,
              ),
              // TextFieldInput(
              //   hintText: user.email,
              //   textInputType: TextInputType.emailAddress,
              //   textEditingController: _emailController,
              // ),
              // const SizedBox(
              //   height: 12,
              // ),
              // //Text field input for password
              // TextFieldInput(
              //   hintText: user.password,
              //   textInputType: TextInputType.text,
              //   textEditingController: _passwordController,
              //   isPass: true,
              // ),
              // const SizedBox(
              //   height: 12,
              // ),
              //Text field input for username
              // TextFieldInput(
              //   hintText: user.bio,
              //   textInputType: TextInputType.text,
              //   textEditingController: _bioController,
              // ),
              TextField(
                controller: _bioController,
                decoration: InputDecoration(
                  hintText: user.bio,
                  border: OutlineInputBorder(),
                  labelText: user.bio,
                ),
              ),
              //Text field input for email
              const SizedBox(
                height: 12,
              ),
              const Divider(),
              // Stnaley 06/04/2022 Mark
              // Column(
              //   children: <Widget>[
              //     RadioListTile<SingingCharacter>(
              //       title: const Text('Australia'),
              //       value: SingingCharacter.Australia,
              //       groupValue: _character,
              //       onChanged: (SingingCharacter? value) {
              //         setState(() {
              //           if (value != null) {
              //             _character = value;
              //             String enumValue = value.name;
              //           }
              //         });
              //       },
              //     ),
              //     RadioListTile<SingingCharacter>(
              //       title: const Text('Taiwan'),
              //       value: SingingCharacter.Taiwan,
              //       groupValue: _character,
              //       onChanged: (SingingCharacter? value) {
              //         setState(() {
              //           if (value != null) {
              //             _character = value;
              //             String enumValue = value.name;
              //           }
              //         });
              //       },
              //     ),
              //   ],
              // ),
              Center(
                child: Row(
                  children: <Widget>[
                    _radioBox('Australia'),
                    _radioBox('Taiwan'),
                  ],
                ),
              ),
              const Divider(),
              InkWell(
                onTap: saveProfile,
                child: Container(
                  child: Container(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          )
                        : const Text('Save'),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      color: blueColor,
                    ),
                  ),
                ),
              ),
              const Divider(),
              //Button login
              InkWell(
                onTap: () => {
                  AuthMethods().signOut(),
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ),
                },
                child: Container(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text('Sign out'),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                    ),
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                child: Container(),
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _radioBox(String country) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: 200, height: 40),
      child: RadioListTile<String>(
          value: country,
          title: Text(country),
          groupValue: _newValue,
          onChanged: (value) {
            setState(() {
              _newValue = value!;
            });
          }),
    );
  }
}
