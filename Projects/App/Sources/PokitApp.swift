//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import FeatureRoot

@main
struct PokitApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            /// - appDelegate.store -> RootFeature
            /// - 헷갈리지 않기
            RootView(store: self.appDelegate.store)
        }
    }
}
