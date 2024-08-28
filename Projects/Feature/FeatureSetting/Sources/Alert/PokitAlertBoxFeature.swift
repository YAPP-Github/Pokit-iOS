//
//  PokitAlertBoxFeature.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import Foundation

import ComposableArchitecture
import Domain
import Util
import CoreKit

@Reducer
public struct PokitAlertBoxFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.alertClient) var alertClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        fileprivate var domain = Alert()
        
        var alertContents: IdentifiedArrayOf<AlertItem>? {
            guard let list = domain.alertList.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<AlertItem>()
            list.forEach { identifiedArray.append($0) }
            return identifiedArray
        }
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum View: Equatable {
            case deleteSwiped(item: AlertItem)
            case itemSelected(item: AlertItem)
            case dismiss
            case onAppear
            case pagenation
        }
        
        public enum InnerAction: Equatable {
            case onAppearResult(AlertListInquiry)
            case pagenation_result(AlertListInquiry)
            case 삭제결과(item: AlertItem)
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable { case doNothing }
        
        public enum DelegateAction: Equatable {
            case moveToContentEdit(id: Int)
            case linkCopyDetected(URL?)
            case alertBoxDismiss
        }
    }
    
    /// - Initiallizer
    public init() {}
    
    public enum CancelID { case disAppear }

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
private extension PokitAlertBoxFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        /// - 스와이프를 통해 아이템 삭제를 눌렀을 때
        case .deleteSwiped(let item):
            return .run { send in
                try await alertClient.알람_삭제("\(item.id)")
                await send(.inner(.삭제결과(item: item)))
            }
        /// - 선택한 항목을 `링크수정`화면으로 이동해 수정
        case .itemSelected(let item):
            return .run { send in await send(.delegate(.moveToContentEdit(id: item.contentId))) }
        case .dismiss:
            return .run { send in
//                await dismiss()
                await send(.delegate(.alertBoxDismiss))
            }
        case .onAppear:
            return .run { [domain = state.domain.alertList] send in
                let sort: [String] = ["createdAt", "desc"]
                let request = BasePageableRequest(page: 0, size: domain.size, sort: sort)
                let result = try await alertClient.알람_목록_조회(request).toDomain()
                await send(.inner(.onAppearResult(result)))
                
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                }
            }
        case .pagenation:
            if state.domain.alertList.hasNext {
                return .run { [domain = state.domain.alertList] send in
                    let sort: [String] = ["createdAt", "desc"]
                    let request = BasePageableRequest(
                        page: domain.page + 1,
                        size: 10,
                        sort: sort
                    )
                    let result = try await alertClient.알람_목록_조회(request).toDomain()
                    await send(.inner(.pagenation_result(result)))
                }
            }
            return .none
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .onAppearResult(list):
            state.domain.alertList = list
            return .none
            
        case let .pagenation_result(alertList):
            guard var list = state.domain.alertList.data else { return .none }
            guard let newList = alertList.data else { return .none }
            
            newList.forEach { list.append($0) }
            state.domain.alertList = alertList
            state.domain.alertList.data = list
            return .none
            
        case let .삭제결과(item):
            //TODO: 삭제연결
            guard let idx = state.domain.alertList.data?.firstIndex(where: { $0 == item }) else { return .none }
            state.domain.alertList.data?.remove(at: idx)
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
