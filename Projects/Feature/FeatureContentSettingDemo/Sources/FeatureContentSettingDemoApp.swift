//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import FeatureContentSetting

@main
struct FeatureContentSettingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentSettingView(
                    store: .init(
                        initialState: ContentSettingFeature.State(
                            contentId: 4
                        ),
                        reducer: { ContentSettingFeature()._printChanges() }
                    )
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentSettingView(
            store: .init(
                initialState: ContentSettingFeature.State(
                    contentId: nil
                ),
                reducer: { ContentSettingFeature()._printChanges() }
            )
        )
    }
}
