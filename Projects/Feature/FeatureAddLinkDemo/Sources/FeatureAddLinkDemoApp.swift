//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import FeatureAddLink

@main
struct FeatureAddLinkDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AddLinkView(
                    store: .init(
                        initialState: .init(),
                        reducer: { AddLinkFeature()._printChanges() }
                    )
                )
            }
        }
    }
}
