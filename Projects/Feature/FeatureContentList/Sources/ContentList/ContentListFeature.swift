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
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(contentType: ContentType) {
            self.contentType = contentType
        }
        
        let contentType: ContentType
        fileprivate var domain = ContentList()
        var contents: IdentifiedArrayOf<BaseContent> {
            var identifiedArray = IdentifiedArrayOf<BaseContent>()
            domain.contentList.data.forEach { identifiedArray.append($0) }
            return identifiedArray
        }
        var isListAscending = true
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
        
        @CasePathable
        public enum View: Equatable, BindableAction {
            /// - Binding
            case binding(BindingAction<State>)
            /// - Button Tapped
            case linkCardTapped(content: BaseContent)
            case kebabButtonTapped(content: BaseContent)
            case bottomSheetButtonTapped(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContent
            )
            case deleteAlertConfirmTapped(content: BaseContent)
            case sortTextLinkTapped
            case backButtonTapped
            /// - On Appeared
            case contentListViewOnAppeared
        }
        
        public enum InnerAction: Equatable {
            case dismissBottomSheet
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable {
            case bottomSheet(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContent
            )
        }
        
        public enum DelegateAction: Equatable {
            case 링크상세(content: BaseContent)
            case 링크수정(content: BaseContent)
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
        case .sortTextLinkTapped:
            state.isListAscending.toggle()
            return .none
        case .backButtonTapped:
            return .run { _ in await dismiss() }
        case .contentListViewOnAppeared:
            // - MARK: 더미 조회
            state.domain.contentList = ContentListInquiryResponse.mock.toDomain()
            return .run { send in
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
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
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

public extension ContentListFeature {
    enum ContentType: String {
        case unread = "안읽음"
        case favorite = "즐겨찾기"
            
        var title: String { self.rawValue }
    }
}
