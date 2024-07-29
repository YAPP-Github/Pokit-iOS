//
//  MainTabPath.swift
//  App
//
//  Created by 김민호 on 7/29/24.
//

import Foundation

import ComposableArchitecture
import FeatureSetting
import FeatureCategorySetting
import FeatureLinkDetail

@Reducer
public struct MainTabPath {
    @ObservableState
    public enum State: Equatable {
        case alert(PokitAlertBoxFeature.State)
        case setting(PokitSettingFeature.State)
        case 포킷추가및수정(PokitCategorySettingFeature.State)
    }
    public enum Action {
        case alert(PokitAlertBoxFeature.Action)
        case setting(PokitSettingFeature.Action)
        case 포킷추가및수정(PokitCategorySettingFeature.Action)
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.alert, action: \.alert) { PokitAlertBoxFeature() }
        Scope(state: \.setting, action: \.setting) { PokitSettingFeature() }
        Scope(state: \.포킷추가및수정, action: \.포킷추가및수정) { PokitCategorySettingFeature() }
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
            /// - 포킷 `추가` or `수정`버튼 눌렀을 때
            case .pokit(.delegate(.수정하기(let selectedItem))):
                state.path.append(.포킷추가및수정(PokitCategorySettingFeature.State(type: .수정, itemList: CategoryItemMock.mock)))
                return .none
            
            case let .path(.element(_, action: .포킷추가및수정(.delegate(.settingSuccess(item))))):
                
                state.path.removeLast()
                return .none
            /// - 링크 상세
            case let .pokit(.categoryDetail(.presented(.delegate(.linkItemTapped)))),
                 let .pokit(.delegate(.linkDetailTapped)):
                state.linkDetail = LinkDetailFeature.State(
                    link: LinkDetailMock(
                        id: UUID(),
                        title: "",
                        url: "",
                        createdAt: Date.now,
                        memo: "",
                        pokit: "",
                        isRemind: false,
                        isFavorite: false
                    )
                )
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

