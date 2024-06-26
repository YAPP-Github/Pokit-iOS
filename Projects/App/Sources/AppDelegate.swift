//
//  AppDelegate.swift
//  App
//
//  Created by 김민호 on 6/27/24.
//

import SwiftUI
import GoogleSignIn

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey: Any] = [:]
        ) -> Bool {
            if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        return false
    }
}
