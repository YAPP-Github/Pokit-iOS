//
//  ShareRootFeature.swift
//  ShareExtension
//
//  Created by 김도형 on 10/17/24.
//

import Foundation

import ComposableArchitecture
import FeatureLogin
import FeatureContentSetting

@Reducer
struct ShareRootFeature {
    @ObservableState
    struct State {
        var intro: IntroFeature.State? = .init()
        var contentSetting: ContentSettingFeature.State? = nil
        
        var url: URL?
        var context: NSExtensionContext?
    }
    
    indirect enum Action {
        case intro(IntroFeature.Action)
        case contentSetting(ContentSettingFeature.Action)
        case viewDidLoad(NSExtensionContext?)
        case parseURL(URL)
    }
    
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .intro(.delegate(.moveToTab)):
            guard let url = state.url else { return .none }
            state.contentSetting = .init(urlText: url.absoluteString)
            state.intro = nil
            return .none
        case .intro:
            return .none
        case .contentSetting(.delegate(.저장하기_완료)):
            state.context?.completeRequest(returningItems: [])
            return .none
        case .contentSetting:
            return .none
        case let .viewDidLoad(context):
            state.context = context
            return .none
        case let .parseURL(url):
            state.url = url
            return .none
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
            .ifLet(\.intro, action: \.intro) { IntroFeature() }
            .ifLet(\.contentSetting, action: \.contentSetting) { ContentSettingFeature() }
            ._printChanges()
    }
}
