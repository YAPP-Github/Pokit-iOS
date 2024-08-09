//
//  LinkListFeature.swift
//  Feature
//
//  Created by 김도형 on 8/2/24.

import Foundation

import ComposableArchitecture
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct ContentListFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(\.pasteboard)
    private var pasteBoard
    @Dependency(\.remindClient)
    private var remindClient
    @Dependency(\.contentClient)
    private var contentClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(contentType: ContentType) {
            self.contentType = contentType
        }
        
        let contentType: ContentType
        fileprivate var domain = ContentList()
        var contents: IdentifiedArrayOf<BaseContentItem> {
            var identifiedArray = IdentifiedArrayOf<BaseContentItem>()
            domain.contentList.data.forEach { identifiedArray.append($0) }
            return identifiedArray
        }
        var isListAscending = true
        /// sheet item
        var bottomSheetItem: BaseContentItem? = nil
        var alertItem: BaseContentItem? = nil
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum View: Equatable, BindableAction {
            /// - Binding
            case binding(BindingAction<State>)
            /// - Button Tapped
            case linkCardTapped(content: BaseContentItem)
            case kebabButtonTapped(content: BaseContentItem)
            case bottomSheetButtonTapped(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContentItem
            )
            case deleteAlertConfirmTapped(content: BaseContentItem)
            case sortTextLinkTapped
            case backButtonTapped
            /// - On Appeared
            case contentListViewOnAppeared
        }
        
        public enum InnerAction: Equatable {
            case dismissBottomSheet
            case 컨텐츠_목록_조회(BaseContentListInquiry)
            case 컨텐츠_삭제_반영(contentId: Int)
        }
        
        public enum AsyncAction: Equatable {
            case 읽지않음_컨텐츠_조회
            case 즐겨찾기_링크모음_조회
            case 컨텐츠_삭제(contentId: Int)
        }
        
        public enum ScopeAction: Equatable {
            case bottomSheet(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContentItem
            )
        }
        
        public enum DelegateAction: Equatable {
            case 링크상세(contentId: Int)
            case 링크수정(contentId: Int)
            case linkCopyDetected(URL?)
        }
    }
    
    /// - Initiallizer
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
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension ContentListFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .kebabButtonTapped(let content):
            state.bottomSheetItem = content
            return .none
        case .linkCardTapped(let content):
            return .send(.delegate(.링크상세(contentId: content.id)))
        case .bottomSheetButtonTapped(let delegate, let content):
            return .run { send in
                await send(.inner(.dismissBottomSheet))
                await send(.scope(.bottomSheet(delegate: delegate, content: content)))
            }
        case .deleteAlertConfirmTapped:
            guard let id = state.alertItem?.id else { return .none }
            return .run { [id] send in
                await send(.async(.컨텐츠_삭제(contentId: id)))
            }
        case .binding:
            return .none
        case .sortTextLinkTapped:
            state.isListAscending.toggle()
            return .none
        case .backButtonTapped:
            return .run { _ in await dismiss() }
        case .contentListViewOnAppeared:
            return .run { [type = state.contentType] send in
                switch type {
                case .unread:
                    await send(.async(.읽지않음_컨텐츠_조회))
                    break
                case .favorite:
                    await send(.async(.즐겨찾기_링크모음_조회))
                    break
                }
                
                for await _ in self.pasteBoard.changes() {
                    let url = try await pasteBoard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                }
            }
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .dismissBottomSheet:
            state.bottomSheetItem = nil
            return .none
        case .컨텐츠_목록_조회(let contentList):
            state.domain.contentList = contentList
            return .none
        case .컨텐츠_삭제_반영(contentId: let id):
            state.alertItem = nil
            state.domain.contentList.data.removeAll { $0.id == id }
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .읽지않음_컨텐츠_조회:
            return .run { [pageable = state.domain.pageable] send in
                let contentList = try await remindClient.읽지않음_컨텐츠_조회(
                    .init(
                        page: pageable.page,
                        size: pageable.size,
                        sort: pageable.sort
                    )
                ).toDomain()
                await send(.inner(.컨텐츠_목록_조회(contentList)))
            }
        case .즐겨찾기_링크모음_조회:
            return .run { [pageable = state.domain.pageable] send in
                let contentList = try await remindClient.즐겨찾기_링크모음_조회(
                    .init(
                        page: pageable.page,
                        size: pageable.size,
                        sort: pageable.sort
                    )
                ).toDomain()
                await send(.inner(.컨텐츠_목록_조회(contentList)))
            }
        case .컨텐츠_삭제(contentId: let id):
            return .run { [id] send in
                let _ = try await contentClient.컨텐츠_삭제("\(id)")
                await send(.inner(.컨텐츠_삭제_반영(contentId: id)), animation: .pokitSpring)
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
                return .send(.delegate(.링크수정(contentId: content.id)))
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

public extension ContentListFeature {
    enum ContentType: String {
        case unread = "안읽음"
        case favorite = "즐겨찾기"
            
        var title: String { self.rawValue }
    }
}
