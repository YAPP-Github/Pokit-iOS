//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import FeatureContentList

@main
struct FeatureContentListDemoApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: 루트 뷰 추가
            ContentListView(store: .init(
                initialState: .init(contentType: .unread),
                reducer: { ContentListFeature()._printChanges() }
            ))
        }
    }
}
