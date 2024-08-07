//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import ComposableArchitecture
import FeatureSetting

@main
struct FeatureSettingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            /*
             To 도형
             NavigationLink를 통해 들어온 뷰에서 dismiss는 안먹을 거임! TCA dismiss랑 스유 dismiss랑 다르기 때문임!
             어처피 본 작업할 때는 TCA dismiss가 작동될꺼니까 상관하지말고 dismiss() 적용 해주면됨!
            */
            NavigationStack {
                HStack {
                    NavigationLink("검색") {
                        PokitSearchView(
                            store: Store(
                                initialState: .init(),
                                reducer: { PokitSearchFeature()._printChanges() }
                            )
                        )
                    }
                    
                    NavigationLink("알림함") {
                        PokitAlertBoxView(
                            store: Store(
                                initialState: .init(alertItems: AlertMock.mock),
                                reducer: { PokitAlertBoxFeature() }
                            )
                        )
                    }
                    NavigationLink("세팅") {
                        PokitSettingView(
                            store: Store(
                                initialState: .init(),
                                reducer: { PokitSettingFeature() }
                            )
                        )
                    }
                }
            }
        }
    }
}

private struct ContentView: View {
    var body: some View {
        Text("")
    }
}
