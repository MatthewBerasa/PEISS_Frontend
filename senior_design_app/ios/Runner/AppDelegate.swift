import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Critical delay for AltStore sideloading compatibility
    self.perform(#selector(restrictedFirebaseInit), with: nil, afterDelay: 1.0)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Add this extension method
  @objc func restrictedFirebaseInit() {
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
      print("Firebase initialized successfully")
    }
  }
}