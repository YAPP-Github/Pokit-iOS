//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import FeatureLinkDetail

@main
struct FeatureLinkDetailDemoApp: App {
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
                LinkDetailView(store: .init(
                    initialState: .init(
                        link: LinkDetailMock(
                            title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                            url: "https://www.youtube.com/watch?v=xSTwqKUyM8k",
                            createdAt: .now,
                            memo: "건강과 지속 가능성을 추구",
                            pokit: "아티클",
                            isRemind: true,
                            isFavorite: true
                        )
                    ),
                    reducer: { LinkDetailFeature() })
                )
            }
        }
    }
}
