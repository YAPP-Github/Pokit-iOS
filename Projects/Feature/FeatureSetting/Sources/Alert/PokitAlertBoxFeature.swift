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
    @Dependency(\.dismiss) 
    var dismiss
    @Dependency(PasteboardClient.self) 
    var pasteboard
    @Dependency(NotificationClient.self)
    var notificationClient
    @Dependency(DeeplinkRouteClient.self)
    var deeplinkRouter
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}

        var notifications = NotificationListInquiry(
            data: [],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )
        var isLoading = true

        var alertContents: IdentifiedArrayOf<NotificationItem>? {
            guard !isLoading else { return nil }
            var identifiedArray = IdentifiedArrayOf<NotificationItem>()
            notifications.data.forEach { identifiedArray.append($0) }
            return identifiedArray
        }
        var hasNext: Bool { notifications.hasNext }
    }
    
    /// - Action
    @CasePathable
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum View: Equatable {
            case dismiss
            case pagenation
            case 밀어서_삭제했을때(item: NotificationItem)
            case 알람_항목_선택했을때(item: NotificationItem)
            case 뷰가_나타났을때
        }
        
        @CasePathable
        public enum InnerAction: Equatable {
            case pagenation_알람_목록_조회_API_반영(NotificationListInquiry)
            case 뷰가_나타났을때_알람_목록_조회_API_반영(NotificationListInquiry)
            case 알람_삭제_API_반영(item: NotificationItem)
            case 알람_읽음_API_반영(notificationId: Int)
        }
        
        @CasePathable
        public enum AsyncAction: Equatable {
            case pagenation_알람_목록_조회_API
            case 뷰가_나타났을때_알람_목록_조회_API
            case 알람_삭제_API(item: NotificationItem)
            case 알람_읽음_API(item: NotificationItem)
            case 클립보드_감지
        }
        
        @CasePathable
        public enum ScopeAction: Equatable { case 없음 }
        
        @CasePathable
        public enum DelegateAction: Equatable {
            case linkCopyDetected(URL?)
            case alertBoxDismiss
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
private extension PokitAlertBoxFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .dismiss:
            return .send(.delegate(.alertBoxDismiss))
            
        case let .밀어서_삭제했을때(item):
            return .send(.async(.알람_삭제_API(item: item)))
            
        case let .알람_항목_선택했을때(item):
            guard !item.isRead else {
                return routeEffect(for: item)
            }
            return .send(.async(.알람_읽음_API(item: item)))
            
        case .뷰가_나타났을때:
            return .merge(
                .send(.async(.뷰가_나타났을때_알람_목록_조회_API)),
                .send(.async(.클립보드_감지))
            )
            
        case .pagenation:
            return state.hasNext
            ? .send(.async(.pagenation_알람_목록_조회_API))
            : .none
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .뷰가_나타났을때_알람_목록_조회_API_반영(list):
            state.notifications = list
            state.isLoading = false
            return .none
            
        case let .pagenation_알람_목록_조회_API_반영(alertList):
            state.notifications = .init(
                data: state.notifications.data + alertList.data,
                page: alertList.page,
                size: alertList.size,
                sort: alertList.sort,
                hasNext: alertList.hasNext
            )
            return .none
            
        case let .알람_삭제_API_반영(item):
            guard
                let idx = state.notifications.data.firstIndex(where: {
                    $0 == item
                })
            else { return .none }
            state.notifications.data.remove(at: idx)
            return .none
        case let .알람_읽음_API_반영(notificationId):
            guard let index = state.notifications.data.firstIndex(where: { $0.id == notificationId }) else {
                return .none
            }
            state.notifications.data[index].isRead = true
            return .none
        }
    }
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .pagenation_알람_목록_조회_API:
                return .run { [notifications = state.notifications] send in
                    let sort: [String] = ["createdAt", "desc"]
                    let request = BasePageableRequest(
                        page: notifications.page + 1,
                        size: 10,
                        sort: sort
                    )
                    let result = try await notificationClient.알림_목록_조회(request).toDomain()
                    await send(.inner(.pagenation_알람_목록_조회_API_반영(result)))
                }
            
        case .뷰가_나타났을때_알람_목록_조회_API:
            return .run { [notifications = state.notifications] send in
                let sort: [String] = ["createdAt", "desc"]
                let request = BasePageableRequest(page: 0, size: notifications.size, sort: sort)
                let result = try await notificationClient.알림_목록_조회(request).toDomain()
                await send(.inner(.뷰가_나타났을때_알람_목록_조회_API_반영(result)))
            }
            
        case let .알람_삭제_API(item):
            return .run { send in
                try await notificationClient.알림_삭제(item.id)
                await send(.inner(.알람_삭제_API_반영(item: item)))
            }
        case let .알람_읽음_API(item):
            return .run { send in
                try await notificationClient.알림_읽음(item.id)
                await send(.inner(.알람_읽음_API_반영(notificationId: item.id)))
                guard
                    let deeplink = item.deepLink,
                    !deeplink.isEmpty,
                    let url = URL(string: deeplink)
                else { return }
                await deeplinkRouter.routeTo(url)
            }
            
        case .클립보드_감지:
            return .run { send in
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
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

    func routeEffect(for item: NotificationItem) -> Effect<Action> {
        guard
            let deeplink = item.deepLink,
            !deeplink.isEmpty,
            let url = URL(string: deeplink)
        else { return .none }

        return .run { _ in
            await deeplinkRouter.routeTo(url)
        }
    }
}
