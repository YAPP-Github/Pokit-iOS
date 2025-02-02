//
//  RootFeature.swift
//  App
//
//  Created by 김민호 on 7/4/24.
//

import Foundation

import ComposableArchitecture
import FeatureIntro
import CoreKit

@Reducer
public struct RootFeature {
    @Dependency(UserDefaultsClient.self) var userDefaults
    @Dependency(UserClient.self) var userClient
    @Reducer(state: .equatable)
    public enum Destination {
        
    }
    
    @ObservableState
    public enum State {
        case intro(IntroFeature.State = .init())
        case mainTab(MainTabFeature.State = .init())
        
        public init() { self = .intro() }
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
            return .run { send in
                guard let fcmToken = userDefaults.stringKey(.fcmToken) else {
                    await send(._sceneChange(.mainTab()))
                    return
                }
                let fcmRequest = FCMRequest(token: fcmToken)
                let user = try await userClient.fcm_토큰_저장(fcmRequest)
                
                await userDefaults.setString(user.token, .fcmToken)
                await userDefaults.setString("\(user.userId)", .userId)
                await send(._sceneChange(.mainTab()))
            }
            
        case .mainTab(.delegate(.로그아웃)),
             .mainTab(.delegate(.회원탈퇴)):
            return .run { send in await send(._sceneChange(.intro(.login()))) }
            
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
