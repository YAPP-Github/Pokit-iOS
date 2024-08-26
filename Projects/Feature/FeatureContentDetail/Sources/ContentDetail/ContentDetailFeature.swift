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
    @Dependency(\.swiftSoup)
    private var swiftSoup
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(\.contentClient)
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

        var linkTitle: String? = nil
        var linkImageURL: String? = nil
        var showAlert: Bool = false
        var showLinkPreview = false
        var showShareSheet: Bool = false
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
            case contentDetailViewOnAppeared
            /// - Button Tapped
            case sharedButtonTapped
            case editButtonTapped
            case deleteButtonTapped
            case deleteAlertConfirmTapped
            case favoriteButtonTapped
            case alertCancelButtonTapped

            case 링크_공유_완료(completed: Bool)
        }

        public enum InnerAction: Equatable {
            case fetchMetadata(url: URL)
            case parsingInfo(title: String?, imageURL: String?)
            case parsingURL
            case dismissAlert
            case 컨텐츠_상세_조회(content: BaseContentDetail)
            case 즐겨찾기_갱신(Bool)
            case 링크미리보기_presented
        }

        public enum AsyncAction: Equatable {
            case 컨텐츠_상세_조회(id: Int)
            case 즐겨찾기(id: Int)
            case 즐겨찾기_취소(id: Int)
            case 컨텐츠_삭제(id: Int)
        }

        public enum ScopeAction: Equatable { case doNothing }

        public enum DelegateAction: Equatable {
            case editButtonTapped(contentId: Int)
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
private extension ContentDetailFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .contentDetailViewOnAppeared:
            guard let id = state.domain.contentId else {
                return .none
            }
            return .run { send in
                await send(.async(.컨텐츠_상세_조회(id: id)))
            }
        case .sharedButtonTapped:
            state.showShareSheet = true
            return .none
        case .editButtonTapped:
            guard let content = state.domain.content else { return .none }
            return .run { [content] send in
                await send(.delegate(.editButtonTapped(contentId: content.id)))
            }
        case .deleteButtonTapped:
            state.showAlert = true
            return .none
        case .deleteAlertConfirmTapped:
            guard let id = state.domain.contentId else {
                return .none
            }
            return .run { send in
                await send(.async(.컨텐츠_삭제(id: id)))
            }
        case .binding:
            return .none
        case .favoriteButtonTapped:
            guard let content = state.domain.content,
                  let favorites = state.domain.content?.favorites else {
                return .none
            }
            return .run { send in
                if favorites {
                    await send(.async(.즐겨찾기_취소(id: content.id)))
                } else {
                    await send(.async(.즐겨찾기(id: content.id)))
                }
            }
        case .링크_공유_완료(completed: let completed):
            state.showShareSheet = !completed
            return .none
        case .alertCancelButtonTapped:
            state.showAlert = false
            return .none
        }
    }

    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .fetchMetadata(url: let url):
            return .run { send in
                /// - 링크에 대한 메타데이터의 제목 및 썸네일 항목 파싱
                let (title, imageURL) = await swiftSoup.parseOGTitleAndImage(url) {
                    await send(.inner(.링크미리보기_presented))
                }
                await send(
                    .inner(.parsingInfo(title: title, imageURL: imageURL)),
                    animation: .pokitDissolve
                )
            }
        case let .parsingInfo(title: title, imageURL: imageURL):
            state.linkTitle = title
            state.linkImageURL = imageURL
            return .none
        case .parsingURL:
            guard let urlString = state.domain.content?.data,
                  let url = URL(string: urlString) else {
                /// 🚨 Error Case [1]: 올바른 링크가 아닐 때
                state.showLinkPreview = false
                state.linkTitle = nil
                state.linkImageURL = nil
                return .none
            }
            return .send(.inner(.fetchMetadata(url: url)), animation: .pokitDissolve)
        case .dismissAlert:
            state.showAlert = false
            return .none
        case .컨텐츠_상세_조회(content: let content):
            state.domain.content = content
            return .send(.inner(.parsingURL))
        case .즐겨찾기_갱신(let favorite):
            state.domain.content?.favorites = favorite
            return .none
        case .링크미리보기_presented:
            state.showLinkPreview = true
            return .none
        }
    }

    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_상세_조회(id: let id):
            return .run { send in
                let contentResponse = try await contentClient.컨텐츠_상세_조회("\(id)").toDomain()
                await send(.inner(.컨텐츠_상세_조회(content: contentResponse)))
            }
        case .즐겨찾기(id: let id):
            return .run { send in
                let _ = try await contentClient.즐겨찾기("\(id)")
                await send(.inner(.즐겨찾기_갱신(true)))
            }
        case .즐겨찾기_취소(id: let id):
            return .run { send in
                try await contentClient.즐겨찾기_취소("\(id)")
                await send(.inner(.즐겨찾기_갱신(false)))
            }
        case .컨텐츠_삭제(id: let id):
            return .run { _ in
                try await contentClient.컨텐츠_삭제("\(id)")
                await dismiss()
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
