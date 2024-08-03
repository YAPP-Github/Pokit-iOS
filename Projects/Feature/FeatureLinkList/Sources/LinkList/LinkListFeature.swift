//
//  LinkListFeature.swift
//  Feature
//
//  Created by 김도형 on 8/2/24.

import Foundation

import ComposableArchitecture
import CoreKit
import DSKit
import Util

@Reducer
public struct LinkListFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(\.pasteboard)
    private var pasteBoard
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(linkType: LinkType) {
            self.linkType = linkType
            self.links = .init()
            LinkListMock.listMock.forEach { link in
                self.links.append(link)
            }
        }
        
        let linkType: LinkType
        var links: IdentifiedArrayOf<LinkListMock>
        var isListAscending = true
        /// sheet item
        var bottomSheetItem: LinkListMock? = nil
        var alertItem: LinkListMock? = nil
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
            case linkCardTapped(link: LinkListMock)
            case kebabButtonTapped(link: LinkListMock)
            case bottomSheetButtonTapped(
                delegate: PokitBottomSheet.Delegate,
                link: LinkListMock
            )
            case deleteAlertConfirmTapped(link: LinkListMock)
            case sortTextLinkTapped
            case backButtonTapped
            /// - On Appeared
            case linkListViewOnAppeared
        }
        
        public enum InnerAction: Equatable {
            case dismissBottomSheet
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable {
            case bottomSheet(
                delegate: PokitBottomSheet.Delegate,
                link: LinkListMock
            )
        }
        
        public enum DelegateAction: Equatable {
            case 링크상세(link: LinkListMock)
            case 링크수정(link: LinkListMock)
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
private extension LinkListFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .kebabButtonTapped(let link):
            state.bottomSheetItem = link
            return .none
        case .linkCardTapped(let link):
            return .send(.delegate(.링크상세(link: link)))
        case .bottomSheetButtonTapped(let delegate, let link):
            return .run { send in
                await send(.inner(.dismissBottomSheet))
                await send(.scope(.bottomSheet(delegate: delegate, link: link)))
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
        case .linkListViewOnAppeared:
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
        case .bottomSheet(let delegate, let link):
            switch delegate {
            case .deleteCellButtonTapped:
                state.alertItem = link
                return .none
            case .editCellButtonTapped:
                return .send(.delegate(.링크수정(link: link)))
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

public extension LinkListFeature {
    enum LinkType {
        case unread
        case favorite
        
        var title: String {
            switch self {
            case .unread: return "안읽음"
            case .favorite: return "즐겨찾기"
            }
        }
    }
}
