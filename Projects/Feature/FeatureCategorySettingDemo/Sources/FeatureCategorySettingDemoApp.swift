//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI
import XCTestDynamicOverlay

import ComposableArchitecture
import FeatureCategorySetting
import FeatureIntro
import Util
import Domain

@main
struct FeatureCategorySettingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                DemoView(store: .init(
                    initialState: DemoFeature.State(),
                    reducer: { DemoFeature() }
                )) {
                    NavigationStack {
                        PokitCategorySettingView(
                            store: Store(
                                initialState: .init(
                                    type: .수정,
                                    category: BaseCategoryItem(
                                        id: 764,
                                        userId: 213,
                                        categoryName: "playlist",
                                        categoryImage: BaseCategoryImage(
                                            imageId: 13,
                                            imageURL: "https://pokit-s3.s3.ap-northeast-2.amazonaws.com/category-image/music.png"
                                        ),
                                        contentCount: 3,
                                        createdAt: "2024.12.03",
                                        openType: .공개,
                                        keywordType: .음악,
                                        userCount: 2,
                                        isFavorite: false
                                    )
                                ),
                                reducer: { PokitCategorySettingFeature() }
                            )
                        )
                    }
                }
            }
        }
    }
}
