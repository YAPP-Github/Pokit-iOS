//
//  AppDelegate.swift
//  App
//
//  Created by 김민호 on 6/27/24.
//

import SwiftUI

import ComposableArchitecture
import Firebase
import FirebaseMessaging
import GoogleSignIn

final class AppDelegate: NSObject {
    let store = Store(initialState: AppDelegateFeature.State()) {
        AppDelegateFeature()
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
            } else if let _ = token {
                self.store.send(.didRegisterForRemoteNotifications(.success(deviceToken)))
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
