//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import ComposableArchitecture
import FeatureCategorySetting
import FeatureIntro
import Util

@main
struct FeatureCategorySettingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoView(store: .init(
                initialState: DemoFeature.State(),
                reducer: { DemoFeature() }
            )) {
                NavigationStack {
                    PokitCategorySettingView(
                        store: Store(
                            initialState: .init(type: .추가),
                            reducer: { PokitCategorySettingFeature() }
                        )
                    )
                }
            }
        }
    }
}
