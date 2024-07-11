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
    @Reducer(state: .equatable)
    public enum Destination {
        
    }
    
    @ObservableState
    public struct State {
        public var appDelegate: AppDelegateFeature.State
        public var intro: IntroFeature.State?
        public var mainTab: MainTabFeature.State?
        
        public init(appDelegate: AppDelegateFeature.State = AppDelegateFeature.State()) {
            self.appDelegate = appDelegate
            self.intro = IntroFeature.State()
        }
    }
    
    public enum Action {
        case appDelegate(AppDelegateFeature.Action)
        case intro(IntroFeature.Action)
        case mainTab(MainTabFeature.Action)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.appDelegate, action: \.appDelegate) {
            AppDelegateFeature()
        }
        Reduce { state, action in
            switch action {
            case .appDelegate:
                return .none
            case .intro(.delegate(.moveToTab)):
                state.intro = nil
                state.mainTab = MainTabFeature.State()
                return .none
            case .intro:
                return .none
            case .mainTab:
                return .none
            }
        }
        .ifLet(\.intro, action: \.intro) {
            IntroFeature()
        }
        .ifLet(\.mainTab, action: \.mainTab) {
            MainTabFeature()
        }
        ._printChanges()
    }
}
