import Flutter
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
