//
//  LinkDetailFeature.swift
//  Feature
//
//  Created by 김도형 on 7/19/24.

import UIKit

import ComposableArchitecture
import Domain
import CoreKit
import Util
import DSKit

@Reducer
public struct ContentDetailFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(SwiftSoupClient.self)
    private var swiftSoup
    @Dependency(ContentClient.self)
    private var contentClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(
            content: BaseContentDetail? = nil,
            contentId: Int? = nil
        ) {
            self.domain = .init(
                content: content,
                contentId: contentId
            )
        }
        fileprivate var domain: ContentDetail
        var content: BaseContentDetail? {
            get { domain.content }
        }
        var contentId: Int? {
            get { domain.contentId }
        }
        var memo: String = ""
        var linkTitle: String? = nil
        var linkImageURL: String? = nil
        var showAlert: Bool = false
        var showShareSheet: Bool = false
        var memoTextAreaState: PokitInputStyle.State = .memo(isReadOnly: true)
        var linkPopup: PokitLinkPopup.PopupType?
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
            /// - View OnAppeared
            case 뷰가_나타났을때
            /// - Button Tapped
            case 공유_버튼_눌렀을때
            case 수정_버튼_눌렀을때
            case 삭제_버튼_눌렀을때
            case 삭제확인_버튼_눌렀을때
            case 즐겨찾기_버튼_눌렀을때
            case 경고시트_해제

            case 링크_공유_완료되었을때
            case 메모포커스_변경되었을때(Bool)
        }

        public enum InnerAction: Equatable {
            case 컨텐츠_상세_조회_API_반영(content: BaseContentDetail)
            case 즐겨찾기_API_반영(Bool)
            case 링크팝업_활성화(PokitLinkPopup.PopupType)
        }

        public enum AsyncAction: Equatable {
            case 컨텐츠_상세_조회_API(id: Int)
            case 즐겨찾기_API(id: Int)
            case 즐겨찾기_취소_API(id: Int)
            case 컨텐츠_삭제_API(id: Int)
            case 컨텐츠_수정_API
        }

        public enum ScopeAction: Equatable { case 없음 }

        public enum DelegateAction: Equatable {
            case editButtonTapped(contentId: Int)
            case 즐겨찾기_갱신_완료
            case 컨텐츠_조회_완료
            case 컨텐츠_삭제_완료
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
        BindingReducer(action: \.view)
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension ContentDetailFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .뷰가_나타났을때:
            /// - 나중에 공유 받은 컨텐츠인지 확인해야함
            state.memoTextAreaState = .memo(isReadOnly: false)
            
            if let id = state.domain.contentId {
                return .send(.async(.컨텐츠_상세_조회_API(id: id)))
            } else if let content = state.domain.content {
                state.memo = content.memo
                return .none
            } else {
                return .none
            }
        case .공유_버튼_눌렀을때:
            state.showShareSheet = true
            return .none
        case .수정_버튼_눌렀을때:
            guard let content = state.domain.content else { return .none }
            return .send(.delegate(.editButtonTapped(contentId: content.id)))
        case .삭제_버튼_눌렀을때:
            state.showAlert = true
            return .none
        case .삭제확인_버튼_눌렀을때:
            guard let id = state.domain.contentId else {
                return .none
            }
            return .send(.async(.컨텐츠_삭제_API(id: id)))
        case .binding:
            return .none
        case .즐겨찾기_버튼_눌렀을때:
            guard let content = state.domain.content,
                  let favorites = state.domain.content?.favorites else {
                return .none
            }
            return favorites
            ? .send(.async(.즐겨찾기_취소_API(id: content.id)))
            : .send(.async(.즐겨찾기_API(id: content.id)))
        case .링크_공유_완료되었을때:
            state.showShareSheet = false
            return .none
        case .경고시트_해제:
            state.showAlert = false
            return .none
        case let .메모포커스_변경되었을때(isFocused):
            guard
                !isFocused,
                state.memo != state.domain.content?.memo
            else { return .none }
            let memo = state.memo
            state.domain.content?.memo = memo
            return .send(.async(.컨텐츠_수정_API))
        }
    }

    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_상세_조회_API_반영(content: let content):
            state.domain.content = content
            state.memo = state.domain.content?.memo ?? ""
            return .send(.delegate(.컨텐츠_조회_완료))
        case .즐겨찾기_API_반영(let favorite):
            state.domain.content?.favorites = favorite
            return .send(.delegate(.즐겨찾기_갱신_완료))
        case let .링크팝업_활성화(type):
            state.linkPopup = type
            return .none
        }
    }

    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_상세_조회_API(id: let id):
            return .run { send in
                let contentResponse = try await contentClient.컨텐츠_상세_조회("\(id)").toDomain()
                await send(.inner(.컨텐츠_상세_조회_API_반영(content: contentResponse)))
            }
        case .즐겨찾기_API(id: let id):
            return .run { send in
                let _ = try await contentClient.즐겨찾기("\(id)")
                await send(.inner(.즐겨찾기_API_반영(true)), animation: .pokitDissolve)
            }
        case .즐겨찾기_취소_API(id: let id):
            return .run { send in
                try await contentClient.즐겨찾기_취소("\(id)")
                await send(.inner(.즐겨찾기_API_반영(false)), animation: .pokitDissolve)
            }
        case .컨텐츠_삭제_API(id: let id):
            return .run { send in
                try await contentClient.컨텐츠_삭제("\(id)")
                await send(.delegate(.컨텐츠_삭제_완료))
                await dismiss()
            }
        case .컨텐츠_수정_API:
            guard
                let content = state.domain.content,
                let url = URL(string: content.data)
            else { return .none }
            return .run { send in
                let imageURL = try? await swiftSoup.parseOGImageURL(url)
                
                let request = ContentBaseRequest(
                    data: content.data,
                    title: content.title,
                    categoryId: content.category.categoryId,
                    memo: content.memo,
                    alertYn: content.alertYn.rawValue,
                    thumbNail: imageURL
                )
                let _ = try await contentClient.컨텐츠_수정(
                    contentId: "\(content.id)",
                    model: request
                )
                await send(
                    .inner(.링크팝업_활성화(.success(title: "메모 수정 완료"))),
                    animation: .pokitSpring
                )
            } catch: { error, send in
                guard let errorResponse = error as? ErrorResponse else { return }
                await send(
                    .inner(.링크팝업_활성화(.error(title: errorResponse.message))),
                    animation: .pokitSpring
                )
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
}
