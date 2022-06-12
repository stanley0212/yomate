import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:yomate/fcm/notification_badge.dart';
import 'package:yomate/fcm/push_notification.dart';
import 'package:yomate/providers/user_provider.dart';
import 'package:yomate/responsive/mobile_screen.dart';
import 'package:yomate/responsive/responsive_layout.dart';
import 'package:yomate/responsive/web_screen.dart';
import 'package:yomate/screens/login_screen.dart';
import 'package:yomate/screens/signup_screen.dart';
import 'package:yomate/utils/colors.dart';

Future _firebaseMessageingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDElhmMlbhJrDT0yaq7sDGSUBwn8GvPvr0",
          appId: "1:667496523432:web:f6464d870261a52558849d",
          messagingSenderId: "667496523432",
          projectId: "camping-ee9d0",
          storageBucket: 'camping-ee9d0.appspot.com'),
    );
  } else {
    await Firebase.initializeApp();
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
    // return MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(
    //       create: (_) => UserProvider(),
    //     ),
    //   ],
    //   child: MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     title: 'yomate',
    //     theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
    //     home: StreamBuilder(
    //       stream: FirebaseAuth.instance.authStateChanges(),
    //       builder: (context, snapshot) {
    //         if (snapshot.connectionState == ConnectionState.active) {
    //           if (snapshot.hasData) {
    //             return const ResponsiveLayout(
    //               mobileScreenLayout: MobileScreenLayout(),
    //               webScreenLayout: WebScreenLayout(),
    //             );
    //           } else if (snapshot.hasError) {
    //             return Center(
    //               child: Text('${snapshot.error}'),
    //             );
    //           }
    //         }
    //         if (snapshot.connectionState == ConnectionState.waiting) {
    //           return const Center(
    //             child: CircularProgressIndicator(
    //               color: primaryColor,
    //             ),
    //           );
    //         }

    //         return const LoginScreen();
    //       },
    //     ),
    //   ),
    // );
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
  late int _totalNotifications;
  late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;

  void requestAndRegisterNotification() async {
    await Firebase.initializeApp();

    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessageingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      String? token = await _messaging.getToken();
      print('This token is ' + token!);

      FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) {
          PushNotification notification = PushNotification(
            title: message.notification?.title,
            body: message.notification?.body,
          );
          setState(() {
            _notificationInfo = notification;
            _totalNotifications++;
          });
          if (_notificationInfo != null) {
            showSimpleNotification(
              Text(_notificationInfo!.title!),
              leading:
                  NotificationBadge(totalNotification: _totalNotifications),
              subtitle: Text(_notificationInfo!.body!),
              background: Colors.cyan.shade700,
              duration: Duration(seconds: 2),
            );
          }
        },
      );
    } else {
      print('User decliend or has not appected permission');
    }
  }

  @override
  void initState() {
    super.initState();
    MobileAds.instance.initialize();
    requestAndRegisterNotification();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });
    _totalNotifications = 0;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'yomate',
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
        home: StreamBuilder(
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
      ),
    );
  }
}
