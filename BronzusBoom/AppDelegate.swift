import Foundation
import AppTrackingTransparency
import UIKit
import AdjustSdk
import SwiftUI

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: RootView())
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.requestTrackingIfNeeded()
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var orientationLock: UIInterfaceOrientationMask = .portrait
    static let trackingAnsweredKey = ""
    private var trackingRequestInProgress = false

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        AppDelegate.orientationLock
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let alreadyAnswered = ATTrackingManager.trackingAuthorizationStatus != .notDetermined
        UserDefaults.standard.set(alreadyAnswered, forKey: Self.trackingAnsweredKey)

        if let config = ADJConfig(appToken: "", environment: ADJEnvironmentProduction) {
            config.logLevel = .verbose
            config.attConsentWaitingInterval = 20
            Adjust.initSdk(config)
        }

        return true
    }

    func requestTrackingIfNeeded() {
        guard !trackingRequestInProgress, ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        trackingRequestInProgress = true

        Task {
            defer { trackingRequestInProgress = false }
            try? await Task.sleep(for: .seconds(1))
            guard UIApplication.shared.applicationState == .active else { return }
            _ = await Adjust.requestAppTrackingAuthorization()
            let answered = ATTrackingManager.trackingAuthorizationStatus != .notDetermined
            UserDefaults.standard.set(answered, forKey: AppDelegate.trackingAnsweredKey)
        }
    }
}
