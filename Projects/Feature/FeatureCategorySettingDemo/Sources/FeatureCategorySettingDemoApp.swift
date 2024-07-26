//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import ComposableArchitecture
import FeatureCategorySetting

@main
struct FeatureCategorySettingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                PokitCategorySettingView(
                    store: Store(
                        initialState: .init(
                            type: .수정,
                            text: "맛집리스트",
                            itemList: CategoryItemMock.mock
                        ),
                        reducer: { PokitCategorySettingFeature() }
                    )
                )
            }
        }
    }
}
