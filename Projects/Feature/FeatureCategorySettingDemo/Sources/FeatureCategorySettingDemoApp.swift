//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import ComposableArchitecture
import FeatureCategorySetting
import Util

@main
struct FeatureCategorySettingDemoApp: App {
    var body: some Scene {
        WindowGroup {
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
