//
//  RemindFeature.swift
//  Feature
//
//  Created by 김도형 on 7/12/24.

import ComposableArchitecture
import Domain
import CoreKit
import Util
import DSKit

@Reducer
public struct RemindFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(\.remindClient)
    private var remindClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        fileprivate var domain = Remind()
        var recommendedContents: IdentifiedArrayOf<BaseContent> {
            var identifiedArray = IdentifiedArrayOf<BaseContent>()
            domain.recommendedList.forEach { identifiedArray.append($0) }
            return identifiedArray
        }
        var unreadContents: IdentifiedArrayOf<BaseContent> {
            var identifiedArray = IdentifiedArrayOf<BaseContent>()
            domain.unreadList.data.forEach { identifiedArray.append($0) }
            return identifiedArray
        }
        var favoriteContents: IdentifiedArrayOf<BaseContent> {
            var identifiedArray = IdentifiedArrayOf<BaseContent>()
            domain.favoriteList.data.forEach { identifiedArray.append($0) }
            return identifiedArray
        }
        /// sheet item
        var bottomSheetItem: BaseContent? = nil
        var alertItem: BaseContent? = nil
    }
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        public enum View: Equatable, BindableAction {
            case binding(BindingAction<State>)
            /// - Button Tapped
            case bellButtonTapped
            case searchButtonTapped
            case linkCardTapped(content: BaseContent)
            case kebabButtonTapped(content: BaseContent)
            case unreadNavigationLinkTapped
            case favoriteNavigationLinkTapped
            case bottomSheetButtonTapped(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContent
            )
            case deleteAlertConfirmTapped(content: BaseContent)
            
            case remindViewOnAppeared
        }
        public enum InnerAction: Equatable {
            case dismissBottomSheet
            case 오늘의_리마인드_조회(contents: [BaseContent])
            case 읽지않음_컨텐츠_조회(contentList: BaseContentListInquiry)
            case 즐겨찾기_링크모음_조회(contentList: BaseContentListInquiry)
        }
        public enum AsyncAction: Equatable {
            case 오늘의_리마인드_조회
            case 읽지않음_컨텐츠_조회
            case 즐겨찾기_링크모음_조회
        }
        public enum ScopeAction: Equatable {
            case bottomSheet(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContent
            )
        }
        public enum DelegateAction: Equatable {
            case 링크상세(content: BaseContent)
            case alertButtonTapped
            case searchButtonTapped
            case 링크수정(content: BaseContent)
            case 링크목록_안읽음
            case 링크목록_즐겨찾기
        }
    }
    /// initiallizer
    public init() {}
    /// - Reducer Core
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
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
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension RemindFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .bellButtonTapped:
            return .run { send in await send(.delegate(.alertButtonTapped)) }
        case .searchButtonTapped:
            return .run { send in await send(.delegate(.searchButtonTapped)) }
        case .favoriteNavigationLinkTapped:
            return .send(.delegate(.링크목록_즐겨찾기))
        case .unreadNavigationLinkTapped:
            return .send(.delegate(.링크목록_안읽음))
        case .kebabButtonTapped(let content):
            state.bottomSheetItem = content
            return .none
        case .linkCardTapped(let content):
            return .send(.delegate(.링크상세(content: content)))
        case .bottomSheetButtonTapped(let delegate, let content):
            return .run { send in
                await send(.inner(.dismissBottomSheet))
                await send(.scope(.bottomSheet(delegate: delegate, content: content)))
            }
        case .deleteAlertConfirmTapped:
            state.alertItem = nil
            return .none
        case .binding:
            return .none
        case .remindViewOnAppeared:
            return .run { send in
                await send(.async(.오늘의_리마인드_조회))
                await send(.async(.읽지않음_컨텐츠_조회))
                await send(.async(.즐겨찾기_링크모음_조회))
            }
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .dismissBottomSheet:
            state.bottomSheetItem = nil
            return .none
        case .오늘의_리마인드_조회(contents: let contents):
            state.domain.recommendedList = contents
            return .none
        case .읽지않음_컨텐츠_조회(contentList: let contentList):
            state.domain.unreadList = contentList
            return .none
        case .즐겨찾기_링크모음_조회(contentList: let contentList):
            state.domain.favoriteList = contentList
            return .none
        }
    }
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .오늘의_리마인드_조회:
            return .run { send in
                let contents = try await remindClient.오늘의_리마인드_조회().map { $0.toDomain() }
                await send(.inner(.오늘의_리마인드_조회(contents: contents)))
            }
        case .읽지않음_컨텐츠_조회:
            return .run { [pageable = state.domain.unreadListPageable] send in
                let contentList = try await remindClient.읽지않음_컨텐츠_조회(
                    .init(
                        page: pageable.page,
                        size: pageable.size,
                        sort: pageable.sort
                    )
                ).toDomain()
                await send(.inner(.읽지않음_컨텐츠_조회(contentList: contentList)))
            }
        case .즐겨찾기_링크모음_조회:
            return .run { [pageable = state.domain.favoriteListPageable] send in
                let contentList = try await remindClient.즐겨찾기_링크모음_조회(
                    .init(
                        page: pageable.page,
                        size: pageable.size,
                        sort: pageable.sort
                    )
                ).toDomain()
                await send(.inner(.즐겨찾기_링크모음_조회(contentList: contentList)))
            }
        }
    }
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        /// - 링크에 대한 `공유` /  `수정` / `삭제` delegate
        switch action {
        case .bottomSheet(let delegate, let content):
            switch delegate {
            case .deleteCellButtonTapped:
                state.alertItem = content
                return .none
            case .editCellButtonTapped:
                return .send(.delegate(.링크수정(content: content)))
            case .favoriteCellButtonTapped:
                return .none
            case .shareCellButtonTapped:
                return .none
            }
        }
    }
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
