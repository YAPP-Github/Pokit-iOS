//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI
import FeatureLogin

@main
struct FeatureLoginDemoApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: 루트 뷰 추가
            SignUpNavigationStackView(store: .init(initialState: .init(), reducer: {
                SignUpNavigationStackFeature()
            }))
        }
    }
}

#Preview {
    SignUpNavigationStackView(store: .init(initialState: .init(), reducer: {
        SignUpNavigationStackFeature()
    }))
}
