import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let mapsChannel = FlutterMethodChannel(
      name: "id.serbajaya.ecommerce/maps_config",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    mapsChannel.setMethodCallHandler { call, result in
      guard call.method == "initialize" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let key = call.arguments as? String, !key.isEmpty else {
        result(false)
        return
      }
      result(GMSServices.provideAPIKey(key))
    }
    let channel = FlutterMethodChannel(
      name: "id.serbajaya.ecommerce/google_sign_in_config",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "hasUrlScheme" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let expectedScheme = call.arguments as? String else {
        result(false)
        return
      }
      let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes")
        as? [[String: Any]] ?? []
      result(urlTypes.contains { entry in
        (entry["CFBundleURLSchemes"] as? [String])?.contains(expectedScheme) == true
      })
    }
  }
}
