//
//  AppDelegate.swift
//  App
//
//  Created by 김민호 on 6/27/24.
//

import SwiftUI
import UIKit

import ComposableArchitecture
import CoreKit
import Firebase
import FirebaseMessaging
import GoogleSignIn
import Dependencies

final class AppDelegate: NSObject {
    @Dependency(\.amplitude)
    private var amplitude

    let store: StoreOf<AppDelegateFeature>

    override init() {
        if UITestEnvironment.isEnabled {
            self.store = Store(
                initialState: AppDelegateFeature.State(),
                reducer: { AppDelegateFeature() },
                withDependencies: {
                    $0[CategoryClient.self] = .mainTabDeeplinkTestValue
                    $0[ContentClient.self] = .mainTabDeeplinkTestValue
                    $0[UserClient.self] = .mainTabDeeplinkTestValue
                    $0[AuthClient.self] = .mainTabDeeplinkTestValue
                    $0[VersionClient.self] = .mainTabDeeplinkTestValue
                    $0[UserDefaultsClient.self] = .mainTabDeeplinkTestValue
                    $0[PasteboardClient.self] = .noop
                    $0[UserNotificationClient.self] = .noop
                    $0[RemoteNotificationsClient.self] = .noop
                }
            )
        } else {
            self.store = Store(initialState: AppDelegateFeature.State()) {
                AppDelegateFeature()
            }
        }
    }
}
//MARK: - UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if GIDSignIn.sharedInstance.handle(url) { return true }
        return false
    }
    
    /// - 앱을 실행할 준비가 되었을 때
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        self.store.send(.didFinishLaunching)

        if UITestEnvironment.isEnabled {
            return true
        }

        // 운영체제 버전 (ex: "iOS 18.0.0")
        let osVersion = "iOS \(UIDevice.current.systemVersion)"

        // 앱 번들 버전 (ex: "2.0.1")
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let amplitudeKey = Bundle.main.infoDictionary?["AMPLITUDE_API_KEY"] as? String ?? ""
        amplitude.initialize(amplitudeKey, nil)
        amplitude.track(.app_open(deviceOS: osVersion, appVersion: appVersion))
        return true
    }
    
    /// - APNs에 성공적으로 등록되었을 때
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error {
                self.store.send(.didRegisterForRemoteNotifications(.failure(error)))
            } else if let token {
                self.store.send(.didRegisterForRemoteNotifications(.success(token)))
            }
        }
    }
    
    /// - APNs에 등록할 수 없을 때
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: any Error
    ) {
        self.store.send(.didRegisterForRemoteNotifications(.failure(error)))
    }
}
