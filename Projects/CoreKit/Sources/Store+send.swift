//
//  Store+send.swift
//  CoreKit
//
//  Created by 김민호 on 7/1/24.
//

import SwiftUI
import ComposableArchitecture

/// 다음과 같이 사용
/// - 1. store.send(.doSomething)
/// - 2. store.send(.view(.doSomething))
public extension Store where Action: FeatureAction {
    func send(_ action: Action.ViewAction, animation: Animation? = nil) {
        send(.view(action), animation: animation)
    }
}
