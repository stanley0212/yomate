import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yomate/resources/auth_methods.dart';
import 'package:yomate/responsive/mobile_screen.dart';
import 'package:yomate/responsive/responsive_layout.dart';
import 'package:yomate/responsive/web_screen.dart';
import 'package:yomate/screens/login_screen.dart';
import 'package:yomate/utils/colors.dart';
import 'package:yomate/utils/utils.dart';
import 'package:yomate/widgets/text_field_input.dart';

//enum SingingCharacter { Australia, Taiwan }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;
  String _newValue = 'Australia';

  //SingingCharacter? _character = SingingCharacter.Australia;

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

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    if (_image != null) {
      String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image!,
        //country: _character.toString(),
        country: _newValue,
      );
      print(res);

      setState(() {
        _isLoading = false;
      });

      if (res != 'Successful') {
        showSnackBar(res, context);
      } else {
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          log(token);
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({'token': token});
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
        );
      }
    } else {
      showSnackBar("Please upload profile photo.", context);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              //Svg image
              // const CircleAvatar(
              //   radius: 64,
              //   backgroundColor: Colors.white54,
              //   backgroundImage: NetworkImage(
              //       'https://firebasestorage.googleapis.com/v0/b/camping-ee9d0.appspot.com/o/Logo%2Fapp_login_sign.png?alt=media&token=deaabdc9-ab0d-45f5-8f7d-e8eebddc18b7'),
              // ),
              // SvgPicture.asset(
              //   'assets/fullLogo.png',
              //   color: primaryColor,
              //   height: 40,
              // ),
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
                      : const CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(
                              'https://i.stack.imgur.com/l60Hf.png'),
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
              TextFieldInput(
                hintText: 'Enter your username',
                textInputType: TextInputType.text,
                textEditingController: _usernameController,
              ),
              //Text field input for email
              const SizedBox(
                height: 12,
              ),
              TextFieldInput(
                hintText: 'Enter your email',
                textInputType: TextInputType.emailAddress,
                textEditingController: _emailController,
              ),
              const SizedBox(
                height: 12,
              ),
              //Text field input for password
              TextFieldInput(
                hintText: 'Enter your password',
                textInputType: TextInputType.text,
                textEditingController: _passwordController,
                isPass: true,
              ),
              const SizedBox(
                height: 12,
              ),
              //Text field input for username
              TextFieldInput(
                hintText: 'Enter your information',
                textInputType: TextInputType.text,
                textEditingController: _bioController,
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
              //Button login
              InkWell(
                onTap: signUpUser,
                child: Container(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text('Sign Up'),
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
              const SizedBox(
                height: 12,
              ),
              Flexible(
                child: Container(),
                flex: 2,
              ),
              //Transitioning to signing up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: const Text("Have an account?   "),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  GestureDetector(
                    onTap: navigateToLogin,
                    child: Container(
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _radioBox(String country) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: 160, height: 40),
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
