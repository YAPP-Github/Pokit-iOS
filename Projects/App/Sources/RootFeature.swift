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
    public struct State: Equatable {
        public var appDelegate: AppDelegateFeature.State
        public init(appDelegate: AppDelegateFeature.State = AppDelegateFeature.State()) {
            self.appDelegate = appDelegate
        }
    }
    
    public enum Action {
        case appDelegate(AppDelegateFeature.Action)
        /// Todo: 인트로, 로그인 등등 추가
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
            }
        }
        ._printChanges()
    }
}
