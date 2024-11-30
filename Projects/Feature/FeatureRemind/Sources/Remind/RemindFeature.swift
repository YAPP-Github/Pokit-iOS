//
//  RemindFeature.swift
//  Feature
//
//  Created by 김도형 on 7/12/24.

import SwiftUI

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
    @Dependency(\.openURL)
    private var openURL
    @Dependency(RemindClient.self)
    private var remindClient
    @Dependency(ContentClient.self)
    private var contentClient
    @Dependency(SwiftSoupClient.self)
    private var swiftSoupClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        fileprivate var domain = Remind()
        var recommendedContents: IdentifiedArrayOf<BaseContentItem>? {
            guard let recommendedList = domain.recommendedList else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseContentItem>()
            recommendedList.forEach { identifiedArray.append($0) }
            return identifiedArray
        }
        var unreadContents: IdentifiedArrayOf<BaseContentItem>? {
            guard let unreadList = domain.unreadList.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseContentItem>()
            unreadList.forEach { identifiedArray.append($0) }
            return identifiedArray
        }
        var favoriteContents: IdentifiedArrayOf<BaseContentItem>? {
            guard let favoriteList = domain.favoriteList.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseContentItem>()
            favoriteList.forEach { identifiedArray.append($0) }
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
        
        public enum View: Equatable, BindableAction {
            case binding(BindingAction<State>)
            
            /// - Button Tapped
            case 알림_버튼_눌렀을때
            case 검색_버튼_눌렀을때
            case 컨텐츠_항목_눌렀을때(content: BaseContentItem)
            case 컨텐츠_항목_케밥_버튼_눌렀을때(content: BaseContentItem)
            case 안읽음_목록_버튼_눌렀을때
            case 즐겨찾기_목록_버튼_눌렀을때
            
            case 뷰가_나타났을때
            case 즐겨찾기_항목_이미지_조회(contentId: Int)
            case 읽지않음_항목_이미지_조회(contentId: Int)
            case 리마인드_항목_이미지오류_나타났을때(contentId: Int)
        }
        public enum InnerAction: Equatable {
            case 오늘의_리마인드_조회_API_반영(contents: [BaseContentItem])
            case 읽지않음_컨텐츠_조회_API_반영(contentList: BaseContentListInquiry)
            case 즐겨찾기_링크모음_조회_API_반영(contentList: BaseContentListInquiry)
            case 즐겨찾기_이미지_조회_수행_반영(imageURL: String, index: Int)
            case 읽지않음_이미지_조회_수행_반영(imageURL: String, index: Int)
            case 리마인드_이미지_조회_수행_반영(imageURL: String, index: Int)
            
        }
        public enum AsyncAction: Equatable {
            case 오늘의_리마인드_조회_API
            case 읽지않음_컨텐츠_조회_API
            case 즐겨찾기_링크모음_조회_API
            case 즐겨찾기_이미지_조회_수행(contentId: Int)
            case 읽지않음_이미지_조회_수행(contentId: Int)
            case 리마인드_이미지_조회_수행(contentId: Int)
        }
        public enum ScopeAction: Equatable { case 없음 }
        public enum DelegateAction: Equatable {
            case 링크상세(content: BaseContentItem)
            case alertButtonTapped
            case searchButtonTapped
            case 링크수정(id: Int)
            case 링크목록_안읽음
            case 링크목록_즐겨찾기
            case 컨텐츠_상세보기_delegate_위임
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
        case .binding:
            return .none
        case .알림_버튼_눌렀을때:
            return .send(.delegate(.alertButtonTapped))
        case .검색_버튼_눌렀을때:
            return .send(.delegate(.searchButtonTapped))
        case .즐겨찾기_목록_버튼_눌렀을때:
            return .send(.delegate(.링크목록_즐겨찾기))
        case .안읽음_목록_버튼_눌렀을때:
            return .send(.delegate(.링크목록_안읽음))
        case .컨텐츠_항목_케밥_버튼_눌렀을때(let content):
            return .send(.delegate(.링크상세(content: content)))
        case .컨텐츠_항목_눌렀을때(let content):
            guard let url = URL(string: content.data) else {
                return .none
            }
            return .run { _ in await openURL(url) }
        case .뷰가_나타났을때:
            return allContentFetch(animation: .pokitDissolve)
        case let .즐겨찾기_항목_이미지_조회(contentId):
            return .send(.async(.즐겨찾기_이미지_조회_수행(contentId: contentId)))
        case let .읽지않음_항목_이미지_조회(contentId):
            return .send(.async(.읽지않음_이미지_조회_수행(contentId: contentId)))
        case let .리마인드_항목_이미지오류_나타났을때(contentId):
            return .send(.async(.리마인드_이미지_조회_수행(contentId: contentId)))
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .오늘의_리마인드_조회_API_반영(contents: let contents):
            state.domain.recommendedList = contents
            return .none
        case .읽지않음_컨텐츠_조회_API_반영(contentList: let contentList):
            state.domain.unreadList = contentList
            return .none
        case .즐겨찾기_링크모음_조회_API_반영(contentList: let contentList):
            state.domain.favoriteList = contentList
            return .none
        case let .즐겨찾기_이미지_조회_수행_반영(imageURL, index):
            var content = state.domain.favoriteList.data?.remove(at: index)
            content?.thumbNail = imageURL
            guard let content else { return .none }
            state.domain.favoriteList.data?.insert(content, at: index)
            return .none
        case let .읽지않음_이미지_조회_수행_반영(imageURL, index):
            var content = state.domain.unreadList.data?.remove(at: index)
            content?.thumbNail = imageURL
            guard let content else { return .none }
            state.domain.unreadList.data?.insert(content, at: index)
            return .none
        case let .리마인드_이미지_조회_수행_반영(imageURL, index):
            var content = state.domain.recommendedList?.remove(at: index)
            content?.thumbNail = imageURL
            guard let content else { return .none }
            state.domain.recommendedList?.insert(content, at: index)
            return .none
        }
    }
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .오늘의_리마인드_조회_API:
            return .run { send in
                let contents = try await remindClient.오늘의_리마인드_조회().map { $0.toDomain() }
                await send(.inner(.오늘의_리마인드_조회_API_반영(contents: contents)), animation: .pokitDissolve)
            }
        case .읽지않음_컨텐츠_조회_API:
            return .run { [pageable = state.domain.unreadListPageable] send in
                let contentList = try await remindClient.읽지않음_컨텐츠_조회(
                    BasePageableRequest(
                        page: pageable.page,
                        size: pageable.size,
                        sort: pageable.sort
                    )
                ).toDomain()
                await send(.inner(.읽지않음_컨텐츠_조회_API_반영(contentList: contentList)), animation: .pokitDissolve)
            }
        case .즐겨찾기_링크모음_조회_API:
            return .run { [pageable = state.domain.favoriteListPageable] send in
                let contentList = try await remindClient.즐겨찾기_링크모음_조회(
                    BasePageableRequest(
                        page: pageable.page,
                        size: pageable.size,
                        sort: pageable.sort
                    )
                ).toDomain()
                await send(.inner(.즐겨찾기_링크모음_조회_API_반영(contentList: contentList)), animation: .pokitDissolve)
            }
        case let .즐겨찾기_이미지_조회_수행(contentId):
            return .run { [favoriteContents = state.favoriteContents] send in
                guard let index = favoriteContents?.index(id: contentId),
                      let content = favoriteContents?[index],
                      let url = URL(string: content.data) else {
                    return
                }
                
                let imageURL = try await swiftSoupClient.parseOGImageURL(url)
                guard let imageURL else { return }
                
                await send(.inner(.즐겨찾기_이미지_조회_수행_반영(
                    imageURL: imageURL,
                    index: index
                )))
            }
        case let .읽지않음_이미지_조회_수행(contentId):
            return .run { [unreadContents = state.unreadContents] send in
                guard let index = unreadContents?.index(id: contentId),
                      let content = unreadContents?[index],
                      let url = URL(string: content.data) else {
                    return
                }
                let imageURL = try await swiftSoupClient.parseOGImageURL(url)
                guard let imageURL else { return }
                
                await send(.inner(.읽지않음_이미지_조회_수행_반영(
                    imageURL: imageURL,
                    index: index
                )))
            }
        case let .리마인드_이미지_조회_수행(contentId):
            return .run { [recommendedContents = state.recommendedContents] send in
                guard let index = recommendedContents?.index(id: contentId),
                      let content = recommendedContents?[index],
                      let url = URL(string: content.data) else {
                    return
                }
                let imageURL = try await swiftSoupClient.parseOGImageURL(url)
                guard let imageURL else { return }
                
                await send(.inner(.리마인드_이미지_조회_수행_반영(
                    imageURL: imageURL,
                    index: index
                )))
            }
        }
    }
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        /// - 링크에 대한 `공유` /  `수정` / `삭제` delegate
        return .none
    }
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_상세보기_delegate_위임:
            return allContentFetch()
        default: return .none
        }
    }
    
    func allContentFetch(animation: Animation? = nil) -> Effect<Action> {
        return .run { send in
            await send(.async(.오늘의_리마인드_조회_API), animation: animation)
            await send(.async(.읽지않음_컨텐츠_조회_API), animation: animation)
            await send(.async(.즐겨찾기_링크모음_조회_API), animation: animation)
        }
    }
}
