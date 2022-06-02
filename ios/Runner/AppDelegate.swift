import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//    GMSServices.provideAPIKey("AIzaSyAF2FpEl2tYHABFuUFKa5XDa5c2Q_1yj0k")
      GeneratedPluginRegistrant.register(with: self)
      GMSServices.provideAPIKey("AIzaSyAF2FpEl2tYHABFuUFKa5XDa5c2Q_1yj0k")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}	
