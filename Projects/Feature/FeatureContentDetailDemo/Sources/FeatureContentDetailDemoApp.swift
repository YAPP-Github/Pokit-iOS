//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import FeatureContentDetail

@main
struct FeatureContentDetailDemoApp: App {
    @State var showLinkDetail = true
    
    var body: some Scene {
        WindowGroup {
            // TODO: 루트 뷰 추가
            VStack {
                Spacer()
                
                Button("링크 상세") {
                    showLinkDetail = true
                }
                
                Spacer()
            }
            .background(.white)
            .sheet(isPresented: $showLinkDetail) {
                ContentDetailView(store: .init(
                    initialState: .init(contentId: 2),
                    reducer: { ContentDetailFeature()._printChanges() })
                )
            }
        }
    }
}
