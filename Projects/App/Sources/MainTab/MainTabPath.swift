//
//  MainTabPath.swift
//  App
//
//  Created by 김민호 on 7/29/24.
//

import ComposableArchitecture
import FeatureSetting
import FeatureCategoryDetail

@Reducer
public struct MainTabPath {
    @ObservableState
    public enum State: Equatable {
        case alert(PokitAlertBoxFeature.State)
        case setting(PokitSettingFeature.State)
    }
    public enum Action {
        case alert(PokitAlertBoxFeature.Action)
        case setting(PokitSettingFeature.Action)
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.alert, action: \.alert) { PokitAlertBoxFeature() }
        Scope(state: \.setting, action: \.setting) { PokitSettingFeature() }
    }
}

public extension MainTabFeature {
    var navigationReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            /// - 네비게이션 바 `알림`버튼 눌렀을 때
            case .pokit(.delegate(.alertButtonTapped)),
                 .remind(.delegate(.bellButtonTapped)):
                state.path.append(.alert(PokitAlertBoxFeature.State(alertItems: AlertMock.mock)))
                return .none
            /// - 네비게이션 바 `검색`버튼 눌렀을 때
            case .pokit(.delegate(.searchButtonTapped)),
                 .remind(.delegate(.searchButtonTapped)):
                return .none
            /// - 네비게이션 바 `설정`버튼 눌렀을 때
            case .pokit(.delegate(.settingButtonTapped)):
                state.path.append(.setting(PokitSettingFeature.State()))
                return .none
            case let .path:
                return .none
            case let .delegate(delegateAction):
                return .none
            default: return .none
            }
        }
        .forEach(\.path, action: \.path) { MainTabPath() }
    }
}

