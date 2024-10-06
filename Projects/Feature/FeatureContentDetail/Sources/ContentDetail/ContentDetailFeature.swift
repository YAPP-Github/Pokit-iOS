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
            case 뷰가_나타났을때
            /// - Button Tapped
            case 공유_버튼_눌렀을때
            case 수정_버튼_눌렀을때
            case 삭제_버튼_눌렀을때
            case 삭제확인_버튼_눌렀을때
            case 즐겨찾기_버튼_눌렀을때
            case 경고시트_해제

            case 링크_공유_완료되었을때
        }

        public enum InnerAction: Equatable {
            case linkPreview
            case 메타데이터_조회_수행(url: URL)
            case 메타데이터_조회_반영(title: String?, imageURL: String?)
            case URL_유효성_확인
            case 컨텐츠_상세_조회_API_반영(content: BaseContentDetail)
            case 즐겨찾기_API_반영(Bool)
        }

        public enum AsyncAction: Equatable {
            case 컨텐츠_상세_조회_API(id: Int)
            case 즐겨찾기_API(id: Int)
            case 즐겨찾기_취소_API(id: Int)
            case 컨텐츠_삭제_API(id: Int)
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
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension ContentDetailFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .뷰가_나타났을때:
            guard let id = state.domain.contentId else {
                return .none
            }
            return .run { send in
                await send(.async(.컨텐츠_상세_조회_API(id: id)))
            }
        case .공유_버튼_눌렀을때:
            state.showShareSheet = true
            return .none
        case .수정_버튼_눌렀을때:
            guard let content = state.domain.content else { return .none }
            return .run { [content] send in
                await send(.delegate(.editButtonTapped(contentId: content.id)))
            }
        case .삭제_버튼_눌렀을때:
            state.showAlert = true
            return .none
        case .삭제확인_버튼_눌렀을때:
            guard let id = state.domain.contentId else {
                return .none
            }
            return .run { send in
                await send(.async(.컨텐츠_삭제_API(id: id)))
            }
        case .binding:
            return .none
        case .즐겨찾기_버튼_눌렀을때:
            guard let content = state.domain.content,
                  let favorites = state.domain.content?.favorites else {
                return .none
            }
            return .run { send in
                if favorites {
                    await send(.async(.즐겨찾기_취소_API(id: content.id)))
                } else {
                    await send(.async(.즐겨찾기_API(id: content.id)))
                }
            }
        case .링크_공유_완료되었을때:
            state.showShareSheet = false
            return .none
        case .경고시트_해제:
            state.showAlert = false
            return .none
        }
    }

    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .메타데이터_조회_수행(url: let url):
            return .run { send in
                /// - 링크에 대한 메타데이터의 제목 및 썸네일 항목 파싱
                let (title, imageURL) = await swiftSoup.parseOGTitleAndImage(url) {
                    await send(.inner(.linkPreview), animation: .pokitDissolve)
                }
                await send(
                    .inner(.메타데이터_조회_반영(title: title, imageURL: imageURL)),
                    animation: .pokitDissolve
                )
            }
        case let .메타데이터_조회_반영(title: title, imageURL: imageURL):
            state.linkTitle = title
            state.linkImageURL = imageURL
            return .none
        case .URL_유효성_확인:
            guard let urlString = state.domain.content?.data,
                  let url = URL(string: urlString) else {
                /// 🚨 Error Case [1]: 올바른 링크가 아닐 때
                state.showLinkPreview = false
                state.linkTitle = nil
                state.linkImageURL = nil
                return .none
            }
            return .send(.inner(.메타데이터_조회_수행(url: url)), animation: .pokitDissolve)
        case .컨텐츠_상세_조회_API_반영(content: let content):
            state.domain.content = content
            return .run { send in
                await send(.delegate(.컨텐츠_조회_완료))
                await send(.inner(.URL_유효성_확인))
            }
        case .즐겨찾기_API_반영(let favorite):
            state.domain.content?.favorites = favorite
            return .send(.delegate(.즐겨찾기_갱신_완료))
        case .linkPreview:
            state.showLinkPreview = true
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
                await send(.inner(.즐겨찾기_API_반영(true)))
            }
        case .즐겨찾기_취소_API(id: let id):
            return .run { send in
                try await contentClient.즐겨찾기_취소("\(id)")
                await send(.inner(.즐겨찾기_API_반영(false)))
            }
        case .컨텐츠_삭제_API(id: let id):
            return .run { send in
                try await contentClient.컨텐츠_삭제("\(id)")
                await send(.delegate(.컨텐츠_삭제_완료))
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
