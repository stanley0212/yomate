import 'dart:developer';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:yomate/fcm/notification_badge.dart';
import 'package:yomate/fcm/push_notification.dart';
import 'package:yomate/firebase_options.dart';
import 'package:yomate/notificationService/local_notification_service.dart';
import 'package:yomate/providers/user_provider.dart';
import 'package:yomate/responsive/mobile_screen.dart';
import 'package:yomate/responsive/responsive_layout.dart';
import 'package:yomate/responsive/web_screen.dart';
import 'package:yomate/screens/login_screen.dart';
import 'package:yomate/screens/post_details_screen.dart';
import 'package:yomate/screens/signup_screen.dart';
import 'package:yomate/services/notification_services.dart';
import 'package:yomate/utils/colors.dart';
import 'package:flutter/services.dart';
import 'package:pushy_flutter/pushy_flutter.dart';

import 'models/android_back_desktop.dart';

// Future<void> backgroundHandler(RemoteMessage message) async {
//   print(message.data.toString());
//   print(message.notification!.title);
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  // LocalNotificationService.initialize();
  //FlutterAppBadger.removeBadge();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDElhmMlbhJrDT0yaq7sDGSUBwn8GvPvr0",
            appId: "1:667496523432:web:f6464d870261a52558849d",
            messagingSenderId: "667496523432",
            projectId: "camping-ee9d0",
            storageBucket: 'camping-ee9d0.appspot.com'));
    // options: DefaultFirebaseOptions.currentPlatform);
    await NotificationServices.initialize();
  } else {
    await Firebase.initializeApp();
    await NotificationServices.initialize();
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(
        duration: 3,
        goToPage: MyHomePage(),
      ),
      //home: AnimatedPage(),
    ),
  );
}

class WelcomePage extends StatelessWidget {
  int duration = 0;
  late Widget goToPage;
  WelcomePage({required this.duration, required this.goToPage});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: this.duration), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => this.goToPage));
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.white,
              child: CircleAvatar(
                radius: 230,
                backgroundColor: Colors.white,
                child: Image.asset('assets/fullLogo_1.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Lottie.asset('assets/yomate-ani.json'),
      nextScreen: MyHomePage(),
      splashIconSize: 300,
      duration: 2000,
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: Duration(seconds: 1),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Center();
  }
}

//Notification
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void getInitialMessage() async {
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();
    print(message?.data["type"]);
    if (message != null) {
      if (message.data["type"] == "noti") {
        print("AAAAA");
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                PostDetailScreen(postid: message.data["postid"]),
          ),
        );
      } else if (message.data["type"] == "active") {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postid: '456'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid Page!"),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    MobileAds.instance.initialize();
    getInitialMessage();
    FirebaseMessaging.onMessage.listen((message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          message.data["yomate"].toString(),
          style: TextStyle(color: Colors.black),
        ),
        duration: Duration(seconds: 10),
        backgroundColor: Colors.green,
      ));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "App was opened by a notification",
          style: TextStyle(color: Colors.black),
        ),
        duration: Duration(seconds: 10),
        backgroundColor: Colors.green,
      ));
    });

    // FirebaseMessaging.instance.getInitialMessage().then((message) {
    //   print("FirebaseMessage.instance.getInitialMessage");
    //   if (message != null) {
    //     print("New Notification");
    //     // if (message.data['_id'] != null) {
    //     //   Navigator.of(context).push(MaterialPageRoute(
    //     //       builder: (context) =>
    //     //           PostDetailScreen(postid: message.data['_id'])));
    //     // }
    //   }
    // });

    // FirebaseMessaging.onMessage.listen((message) {
    //   log("message received: ${message.notification!.title}");
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(
    //         message.notification!.body.toString(),
    //       ),
    //       duration: Duration(seconds: 10),
    //       backgroundColor: Colors.green,
    //     ),
    //   );
    // print("FirebaseMessage.onMessage.listen");
    // if (message.notification != null) {
    //   print(message.notification!.title);
    //   print(message.notification!.body);
    //   print("Message details1: ${message.data}");
    //   LocalNotificationService.createanddisplaynotification(message);
    //   //Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostDetailScreen(postid: postid)))
    // }
    // });

    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('App was opened by a notification'),
    //       duration: Duration(seconds: 10),
    //       backgroundColor: Colors.green,
    //     ),
    //   );
    // });

    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   print("FirebaseMessaging.onMessageOpenedApp.listen");
    //   if (message.notification != null) {
    //     print(message.notification!.title);
    //     print(message.notification!.body);
    //     print("Message details2: ${message.data['_id']}");
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => UserProvider(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'yomate',
            theme: ThemeData.dark()
                .copyWith(scaffoldBackgroundColor: Colors.black),
            home: Scaffold(
              body: StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      return const ResponsiveLayout(
                        mobileScreenLayout: MobileScreenLayout(),
                        webScreenLayout: WebScreenLayout(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('${snapshot.error}'),
                      );
                    }
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    );
                  }

                  return const LoginScreen();
                },
              ),
              // floatingActionButton: FloatingActionButton(
              //   onPressed: showNotification,
              //   tooltip: 'Increment',
              //   child: Icon(Icons.add),
              // ),
            ),
          ),
        ),
      );
}
