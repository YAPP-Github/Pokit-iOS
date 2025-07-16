//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import FeatureContentSetting
import FeatureIntro

@main
struct FeatureContentSettingDemoApp: App {
    
    var body: some Scene {
        WindowGroup {
            DemoView(store: .init(
                initialState: DemoFeature.State(),
                reducer: { DemoFeature() }
            )) {
                NavigationStack {
                    ContentSettingView(
                        store: .init(
                            initialState: ContentSettingFeature.State(),
                            reducer: { ContentSettingFeature()._printChanges() }
                        )
                    )
                }
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
