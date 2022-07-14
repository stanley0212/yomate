import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yomate/resources/auth_methods.dart';
import 'package:yomate/responsive/mobile_screen.dart';
import 'package:yomate/responsive/responsive_layout.dart';
import 'package:yomate/responsive/web_screen.dart';
import 'package:yomate/screens/home_screen.dart';
import 'package:yomate/screens/signup_screen.dart';
import 'package:yomate/utils/colors.dart';
import 'package:yomate/utils/global_variables.dart';
import 'package:yomate/utils/utils.dart';
import 'package:yomate/widgets/text_field_input.dart';
import 'package:yomate/widgets/text_input_field.dart';

import '../models/android_back_desktop.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (res == 'Successful') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    } else {
      //
      showSnackBar(res, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void navigateToSignup() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignUpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/camping_background.jpg"),
              fit: BoxFit.fill,
            ),
          ),
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(),
                flex: 2,
              ),
              //Svg image
              Stack(
                children: [
                  // CircleAvatar(
                  //   radius: 64,
                  //   //backgroundColor: Colors.white54,
                  //   backgroundImage: NetworkImage(
                  //       'https://firebasestorage.googleapis.com/v0/b/camping-ee9d0.appspot.com/o/Logo%2Faa.png?alt=media&token=fd235f6d-6700-45f7-ab7e-b285f8f5b093'),
                  // ),
                  Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/camping-ee9d0.appspot.com/o/Logo%2Fnew_logo.png?alt=media&token=988c5c49-19f5-4da8-b350-9e4d8d2cdf37')
                ],
              ),
              const SizedBox(
                height: 64,
              ),
              TextInputField(
                  controller: _emailController,
                  labelText: 'Email',
                  icon: Icons.email),
              const SizedBox(
                height: 24,
              ),
              //Text field input for password

              TextInputField(
                controller: _passwordController,
                labelText: 'Password',
                icon: Icons.lock,
                isObscure: true,
              ),
              const SizedBox(
                height: 24,
              ),
              //Button login
              InkWell(
                onTap: loginUser,
                child: Container(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text('Login'),
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
                    child: const Text("Don't have an account?   "),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  GestureDetector(
                    onTap: navigateToSignup,
                    child: Container(
                      child: const Text(
                        "Sign up",
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
}
