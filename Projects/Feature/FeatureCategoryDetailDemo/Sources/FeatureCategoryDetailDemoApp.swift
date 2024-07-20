//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import ComposableArchitecture
import FeatureCategoryDetail

@main
struct FeatureCategoryDetailDemoApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: 루트 뷰 추가
            NavigationStack {
                CategoryDetailView(
                    store: Store(
                        initialState: .init(mock: DetailItemMock.recommendedMock),
                        reducer: { CategoryDetailFeature() }
                    )
                )
            }
        }
    }
}
