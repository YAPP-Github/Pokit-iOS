//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI
import XCTestDynamicOverlay

import FeatureContentList
import FeatureIntro

@main
struct FeatureContentListDemoApp: App {
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                // TODO: 루트 뷰 추가
                
                DemoView(store: .init(
                    initialState: .init(),
                    reducer: { DemoFeature() }
                )) {
                    ContentListView(store: .init(
                        initialState: .init(contentType: .favorite),
                        reducer: { ContentListFeature() }
                    ))
                }
            }
        }
    }
}
