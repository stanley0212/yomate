import UIKit
import Flutter
import GoogleMaps
import FirebaseMessaging
import Firebase


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//    GMSServices.provideAPIKey("AIzaSyAF2FpEl2tYHABFuUFKa5XDa5c2Q_1yj0k")
      FirebaseApp.configure()
      GeneratedPluginRegistrant.register(with: self)
      GMSServices.provideAPIKey("AIzaSyAF2FpEl2tYHABFuUFKa5XDa5c2Q_1yj0k")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("Token: \(deviceToken)")
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
}	
	
