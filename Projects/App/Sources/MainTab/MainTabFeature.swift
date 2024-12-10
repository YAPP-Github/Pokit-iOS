//
//  MainTabFeature.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import SwiftUI

import ComposableArchitecture
import FeaturePokit
import FeatureRemind
import FeatureContentDetail
import Domain
import DSKit
import Util
import CoreKit

@Reducer
public struct MainTabFeature {
    /// - Dependency
    @Dependency(PasteboardClient.self)
    private var pasteBoard
    @Dependency(CategoryClient.self)
    private var categoryClient
    @Dependency(UserDefaultsClient.self)
    private var userDefaults
    /// - State
    @ObservableState
    public struct State: Equatable {
        var selectedTab: MainTab = .pokit
        var isBottomSheetPresented: Bool = false
        var linkPopup: PokitLinkPopup.PopupType?
        var isErrorSheetPresented: Bool = false
        var link: String?

        var error: BaseError?

        var path: StackState<MainTabPath.State> = .init()
        var pokit: PokitRootFeature.State
        var remind: RemindFeature.State = .init()
        @Presents var contentDetail: ContentDetailFeature.State?
        @Shared(.inMemory("SelectCategory")) var categoryId: Int?
        @Shared(.inMemory("PushTapped")) var isPushTapped: Bool = false
        var categoryOfSavedContent: BaseCategoryItem?

        public init() {
            self.pokit = .init()
        }
    }
    /// - Action
    public enum Action: FeatureAction, BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case pushAlertTapped(Bool)
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        /// Todo: scope로 이동
        case path(StackAction<MainTabPath.State, MainTabPath.Action>)
        case pokit(PokitRootFeature.Action)
        case remind(RemindFeature.Action)
        case contentDetail(PresentationAction<ContentDetailFeature.Action>)

        @CasePathable
        public enum View: Equatable {
            case addButtonTapped
            case addSheetTypeSelected(TabAddSheetType)
            case 링크팝업_버튼_눌렀을때
            case onAppear
            case onOpenURL(url: URL)
            case 경고_확인버튼_클릭
        }
        public enum InnerAction: Equatable {
            case 링크추가및수정이동(contentId: Int)
            case linkCopySuccess(URL?)
            case 공유포킷_이동(sharedCategory: CategorySharing.SharedCategory)
            case 경고_띄움(BaseError)
            case errorSheetPresented(Bool)
            case 링크팝업_활성화(PokitLinkPopup.PopupType)
            case 카테고리상세_이동(category: BaseCategoryItem)
        }
        public enum AsyncAction: Equatable {
            case 공유받은_카테고리_조회(categoryId: Int)
        }
        public enum ScopeAction: Equatable { case doNothing }
        public enum DelegateAction: Equatable {
            case 링크추가하기
            case 포킷추가하기
            case 로그아웃
            case 회원탈퇴
            case 알림함이동
        }
    }
    /// initiallizer
    public init() {}
    /// - Reducer Core
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .binding(\.linkPopup):
            guard state.linkPopup == nil else { return .none }
            state.categoryOfSavedContent = nil
            return .none
        case .binding:
            return .none
        case let .pushAlertTapped(isTapped):
            if isTapped {
                return .send(.delegate(.알림함이동))
            } else {
                return .none
            }
            /// - View
        case .view(let viewAction):
            return handleViewAction(viewAction, state: &state)
            /// - Inner
        case .inner(let innerAction):
            return handleInnerAction(innerAction, state: &state)
            /// - Async
        case .async(let asyncAction):
            return handleAsyncAction(asyncAction, state: &state)
            /// - Scope
        case .scope(let scopeAction):
            return handleScopeAction(scopeAction, state: &state)
            /// - Delegate
        case .delegate(let delegateAction):
            return handleDelegateAction(delegateAction, state: &state)

        case .path:
            return .none
        case .pokit:
            return .none
        case .remind:
            return .none
        case .contentDetail:
            return .none
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Scope(state: \.pokit, action: \.pokit) { PokitRootFeature() }
        Scope(state: \.remind, action: \.remind) { RemindFeature() }

        BindingReducer()
        navigationReducer
        Reduce(self.core)
            .ifLet(\.$contentDetail, action: \.contentDetail) {
                ContentDetailFeature()
            }
    }
}
//MARK: - FeatureAction Effect
private extension MainTabFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .addButtonTapped:
            state.isBottomSheetPresented.toggle()
            return .none

        case .addSheetTypeSelected(let type):
            state.isBottomSheetPresented = false
            switch type {
            case .링크추가: return .send(.delegate(.링크추가하기))
            case .포킷추가: return .send(.delegate(.포킷추가하기))
            }

        case .링크팝업_버튼_눌렀을때:
            return linkPopupButtonTapped(state: &state)

        case .onAppear:
            if state.isPushTapped {
                return .send(.pushAlertTapped(true))
            }
            return .merge(
                .run { send in
                    for await _ in self.pasteBoard.changes() {
                        let url = try await pasteBoard.probableWebURL()
                        await send(.inner(.linkCopySuccess(url)), animation: .pokitSpring)
                    }
                },
                .publisher {
                    state.$isPushTapped.publisher
                        .map(Action.pushAlertTapped)
                }
            )
        case .onOpenURL(url: let url):
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return .none
            }

            let queryItems = components.queryItems ?? []
            guard let categoryIdString = queryItems.first(where: { $0.name == "categoryId" })?.value,
                  let categoryId = Int(categoryIdString) else {
                return .none
            }

            return .send(.async(.공유받은_카테고리_조회(categoryId: categoryId)))
        case .경고_확인버튼_클릭:
            state.error = nil
            return .run { send in await send(.inner(.errorSheetPresented(false))) }
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .linkCopySuccess(url):
            guard let url else { return .none }
            state.linkPopup = .link(
                title: Constants.복사한_링크_저장하기_문구,
                url: url.absoluteString
            )
            state.link = url.absoluteString
            return .none

        case let .경고_띄움(error):
            state.error = error
            return .run { send in await send(.inner(.errorSheetPresented(true))) }

        case let .errorSheetPresented(isPresented):
            state.isErrorSheetPresented = isPresented
            return .none
            
        case let .링크팝업_활성화(type):
            state.linkPopup = type
            return .none
        case let .카테고리상세_이동(category):
            if category.categoryName == "미분류" {
                state.selectedTab = .pokit
                state.path.removeAll()
                return .send(.pokit(.delegate(.미분류_카테고리_활성화)))
            }
            state.path.append(.카테고리상세(.init(category: category)))
            return .none
        default: return .none
        }
    }
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .공유받은_카테고리_조회(categoryId: categoryId):
            return .run { send in
                do {
                    let request = BasePageableRequest(page: 0, size: 10, sort: ["createdAt", "desc"])
                    let sharedCategory = try await categoryClient.공유받은_카테고리_조회("\(categoryId)", request).toDomain()
                    await send(.inner(.공유포킷_이동(sharedCategory: sharedCategory)), animation: .smooth)
                } catch {
                    guard let errorResponse = error as? ErrorResponse else { return }
                    let errorDomain = BaseError(response: errorResponse)
                    await send(.inner(.경고_띄움(errorDomain)))
                }
            }
        }
    }
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        return .none
    }
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    func linkPopupButtonTapped(state: inout State) -> Effect<Action> {
        switch state.linkPopup {
        case .link:
            state.linkPopup = nil
            return .send(.delegate(.링크추가하기))
        case .success:
            state.linkPopup = nil
            guard let category = state.categoryOfSavedContent else { return .none }
            state.categoryOfSavedContent = nil
            return .send(.inner(.카테고리상세_이동(category: category)))
        case .error, .text, .warning, .none:
            return .none
        }
    }
}
