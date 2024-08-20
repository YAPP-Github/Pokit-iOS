//
//  RootFeature.swift
//  App
//
//  Created by 김민호 on 7/4/24.
//

import Foundation

import ComposableArchitecture

@Reducer
public struct RootFeature {
    @ObservableState
    public enum State {
        case intro(IntroFeature.State)
        case mainTab(MainTabFeature.State)
    }
    
    public indirect enum Action {
        case _sceneChange(State)
        case intro(IntroFeature.Action)
        case mainTab(MainTabFeature.Action)
    }
    
    public init() {}
    /// - Reducer Core
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let ._sceneChange(newState):
            state = newState
            return .none
        case .intro(.delegate(.moveToTab)):
            return .send(._sceneChange(.mainTab(.init())))
            
        case .mainTab(.delegate(.로그아웃)),
             .mainTab(.delegate(.회원탈퇴)):
            return .send(._sceneChange(.intro(.login(.init()))))
            
        case .intro, .mainTab:
            return .none
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
        .ifCaseLet(\.intro, action: \.intro) { IntroFeature() }
        .ifCaseLet(\.mainTab, action: \.mainTab) { MainTabFeature() }
        ._printChanges()
    }
}
