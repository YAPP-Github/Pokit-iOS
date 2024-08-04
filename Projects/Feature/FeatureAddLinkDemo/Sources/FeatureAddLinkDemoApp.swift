//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import FeatureAddLink

@main
struct FeatureAddLinkDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AddLinkView(
                    store: .init(
                        initialState: AddLinkFeature.State(
                            link: .init(
                                id: 0,
                                categoryName: "미분류",
                                categoryId: nil,
                                title: "[playlist] 혼자만의 시간을 갖는다는 것.",
                                thumbNail: "",
                                data: "https://www.youtube.com/watch?v=xSTwqKUyM8k",
                                memo: "일상 생활에서 정신없이 공부하고, 학교 생활을 하다보면 지쳐서 나만의 시간이 필요하다고 느끼는 것 같아요. 온전한 나만의 시간이 가일상 생활에서 정신없이 공부하고, 학교 생활을 하다보면",
                                createdAt: .now,
                                isRead: true,
                                favorites: true,
                                alertYn: .yes
                            )
                        ),
                        reducer: { AddLinkFeature()._printChanges() }
                    )
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddLinkView(
            store: .init(
                initialState: AddLinkFeature.State(
                    link: nil
                ),
                reducer: { AddLinkFeature()._printChanges() }
            )
        )
    }
}
