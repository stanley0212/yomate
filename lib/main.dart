import 'dart:developer';
import 'dart:io';

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
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
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
import 'package:yomate/sqlite/database_helper.dart';
import 'package:yomate/utils/colors.dart';
import 'package:flutter/services.dart';

import 'models/android_back_desktop.dart';
import 'package:path/path.dart' as pt;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(,
    );
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
  var _storageString = '';

  void getInitialMessage() async {
    //
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      //'This channel is used for important notifications.', // description
      importance: Importance.max,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                //channel.description,
                icon: android?.smallIcon,
                // other properties...
              ),
            ));
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'noti') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              PostDetailScreen(postid: message.data["postid"]),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    MobileAds.instance.initialize();
    getInitialMessage();
    FlutterAppBadger.removeBadge();
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
