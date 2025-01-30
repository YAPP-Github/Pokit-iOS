//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import FeatureRecommend
import FeatureIntro
import CoreKit

@main
struct FeatureRecommendDemoApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: 루트 뷰 추가
            
            DemoView(store: .init(
                initialState: .init(),
                reducer: { DemoFeature() }
            )) {
                RecommendView(store: .init(
                    initialState: .init(),
                    reducer: { RecommendFeature()._printChanges() },
                    withDependencies: {
                        $0[ContentClient.self] = .testValue
                        $0[UserClient.self] = .testValue
                    }
                ))
            }
        }
    }
}
