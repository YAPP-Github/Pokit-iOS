//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import ComposableArchitecture
import FeatureCategoryDetail
import Domain
import CoreKit

@main
struct FeatureCategoryDetailDemoApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: 루트 뷰 추가
            NavigationStack {
                CategoryDetailView(
                    store: Store(
                        initialState: .init(
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
                                userCount: 0,
                                isFavorite: false
                              )
                        ),
                        reducer: { CategoryDetailFeature() }
                    )
                )
            }
        }
    }
}
