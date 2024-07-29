//
//  MainTabPath.swift
//  App
//
//  Created by 김민호 on 7/29/24.
//

import Foundation

import ComposableArchitecture
import FeatureSetting
import FeatureCategoryDetail
import FeatureCategorySetting
import FeatureLinkDetail
import FeatureAddLink

@Reducer
public struct MainTabPath {
    @ObservableState
    public enum State: Equatable {
        case alert(PokitAlertBoxFeature.State)
        case setting(PokitSettingFeature.State)
        case 포킷추가및수정(PokitCategorySettingFeature.State)
        case 링크추가및수정(AddLinkFeature.State)
        case 카테고리상세(CategoryDetailFeature.State)
    }
    public enum Action {
        case alert(PokitAlertBoxFeature.Action)
        case setting(PokitSettingFeature.Action)
        case 포킷추가및수정(PokitCategorySettingFeature.Action)
        case 링크추가및수정(AddLinkFeature.Action)
        case 카테고리상세(CategoryDetailFeature.Action)
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.alert, action: \.alert) { PokitAlertBoxFeature() }
        Scope(state: \.setting, action: \.setting) { PokitSettingFeature() }
        Scope(state: \.포킷추가및수정, action: \.포킷추가및수정) { PokitCategorySettingFeature() }
        Scope(state: \.링크추가및수정, action: \.링크추가및수정) { AddLinkFeature() }
        Scope(state: \.카테고리상세, action: \.카테고리상세) { CategoryDetailFeature() }
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
            /// - 포킷 `추가` or `수정`이 성공적으로 `완료`되었을 때
            case let .path(.element(_, action: .포킷추가및수정(.delegate(.settingSuccess(item))))):
                state.path.removeLast()
                return .none
            /// - 포킷 카테고리 아이템 눌렀을 때
            case let .pokit(.delegate(.categoryTapped)):
                state.path.append(.카테고리상세(CategoryDetailFeature.State(mock: DetailItemMock.recommendedMock)))
                return .none
            /// - 링크 상세
            case let .path(.element(_, action: .카테고리상세(.delegate(.linkItemTapped)))),
                 let .pokit(.delegate(.linkDetailTapped)):
                // TODO: 링크상세 모델과 링크수정 모델 일치시키기
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
            /// 링크상세 바텀시트에서 링크수정으로 이동
            case let .linkDetail(.presented(.delegate(.pushLinkAddView))),
                 let .pokit(.delegate(.링크수정하기)):
                // TODO: 링크상세 모델과 링크수정 모델 일치시키기
                state.path.append(.링크추가및수정(AddLinkFeature.State(link: AddLinkMock.init(title: "", urlText: "", createAt: Date.now, memo: "", isRemind: false, pokit: PokitMock(categoryType: "", contentSize: 4)))))
                state.linkDetail = nil
                return .none
            /// 링크추가 및 수정에서 저장하기 눌렀을 때
            case .path(.element(_, action: .링크추가및수정(.delegate(.저장하기_네트워크이후)))):
                state.path.removeLast()
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

