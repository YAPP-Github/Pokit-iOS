//
//  MainTabFeature.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import SwiftUI

import ComposableArchitecture
import FeaturePokit
import FeatureRecommend
import FeatureContentDetail
import FeatureCategoryDetail
import Domain
import DSKit
import Util
import CoreKit

@Reducer
public struct MainTabFeature {
    /// - Dependency
    @Dependency(PasteboardClient.self)
    private var pasteBoard
    @Dependency(CategoryClient.self)
    private var categoryClient
    @Dependency(DeeplinkRouteClient.self)
    private var deeplinkRouter
    @Dependency(\.amplitude.track)
    private var amplitudeTrack
    
    /// - State
    @ObservableState
    public struct State: Equatable {
        var selectedTab: MainTab = .pokit
        var isBottomSheetPresented: Bool = false
        var linkPopup: PokitLinkPopup.PopupType?
        var isErrorSheetPresented: Bool = false
        var link: String?

        var error: BaseError?

        var path: StackState<MainTabPath.State> = .init()
        var pokit: PokitRootFeature.State
        var recommend: RecommendFeature.State = .init()
        @Presents var contentDetail: ContentDetailFeature.State?
        @Shared(.inMemory("SelectCategory")) var categoryId: Int?
        var categoryOfSavedContent: BaseCategoryItem?

        public init() {
            self.pokit = .init()
        }
    }
    /// - Action
    @CasePathable
    public enum Action: FeatureAction, BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        /// Todo: scope로 이동
        case path(StackAction<MainTabPath.State, MainTabPath.Action>)
        case pokit(PokitRootFeature.Action)
        case recommend(RecommendFeature.Action)
        case contentDetail(PresentationAction<ContentDetailFeature.Action>)

        @CasePathable
        public enum View: Equatable {
            case addButtonTapped
            case addSheetTypeSelected(TabAddSheetType)
            case 링크팝업_버튼_눌렀을때
            case onAppear
            case onOpenURL(url: URL)
            case 경고_확인버튼_클릭
            case 검색_버튼_눌렀을때
            case 알림_버튼_눌렀을때
        }
        @CasePathable
        public enum InnerAction: Equatable {
            case 링크추가및수정이동(contentId: Int)
            case linkCopySuccess(URL?)
            case 공유받은_카테고리_이동(category: BaseCategoryItem, type: CategoryType)
            case 포킷_딥링크_이동(category: BaseCategoryItem, contentId: Int?, userId: Int?)
            case 딥링크_수신(DeeplinkRoute)
            case 경고_띄움(BaseError)
            case errorSheetPresented(Bool)
            case 링크팝업_활성화(PokitLinkPopup.PopupType)
            case 카테고리상세_이동(category: BaseCategoryItem)
        }
        @CasePathable
        public enum AsyncAction: Equatable {
            case 공유받은_카테고리_조회(categoryId: Int, shareType: String?)
            case 포킷_딥링크_처리(categoryId: Int, contentId: Int?, userId: Int?)
        }
        @CasePathable
        public enum ScopeAction: Equatable { case doNothing }
        @CasePathable
        public enum DelegateAction: Equatable {
            case 링크추가하기
            case 포킷추가하기
            case 로그아웃
            case 회원탈퇴
            case 알림함이동
        }
    }
    /// initiallizer
    public init() {}
    
    private enum CancelID {
        case 클립보드_감지
        case 딥링크_스트림_감지
    }
    
    /// - Reducer Core
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .binding(\.linkPopup):
            guard state.linkPopup == nil else { return .none }
            state.categoryOfSavedContent = nil
            return .none
        case .binding(\.selectedTab):
            switch state.selectedTab {
            case .pokit:
                amplitudeTrack(.view_home_pokit(entryPoint: "pokit"))
            case .recommend:
                amplitudeTrack(.view_home_recommend(entryPoint: "recommend"))
            }
            return .none
        case .binding:
            return .none
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

        case .path:
            return .none
        case .pokit:
            return .none
        case .recommend:
            return .none
        case .contentDetail:
            return .none
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Scope(state: \.pokit, action: \.pokit) { PokitRootFeature() }
        Scope(state: \.recommend, action: \.recommend) {
            RecommendFeature()
        }

        BindingReducer()
        navigationReducer
        Reduce(self.core)
            .ifLet(\.$contentDetail, action: \.contentDetail) {
                ContentDetailFeature()
            }
    }
}
//MARK: - FeatureAction Effect
private extension MainTabFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .addButtonTapped:
            state.isBottomSheetPresented.toggle()
            return .none

        case .addSheetTypeSelected(let type):
            state.isBottomSheetPresented = false
            switch type {
            case .링크추가: return .send(.delegate(.링크추가하기))
            case .포킷추가: return .send(.delegate(.포킷추가하기))
            }

        case .링크팝업_버튼_눌렀을때:
            return linkPopupButtonTapped(state: &state)

        case .onAppear:
            return .merge(
                .run { send in
                    for await _ in self.pasteBoard.changes() {
                        let url = try await pasteBoard.probableWebURL()
                        await send(.inner(.linkCopySuccess(url)), animation: .pokitSpring)
                    }
                }
                .cancellable(id: CancelID.클립보드_감지, cancelInFlight: true),
                .run { send in
                    for await route in self.deeplinkRouter.routeStream() {
                        await send(.inner(.딥링크_수신(route)), animation: .smooth)
                    }
                }
                .cancellable(id: CancelID.딥링크_스트림_감지, cancelInFlight: true)
            )
        case .onOpenURL(url: let url):
            guard url.scheme?.lowercased().hasPrefix("kakao") == true else { return .none }
            return .run { _ in
                await self.deeplinkRouter.routeTo(url)
            }
        case .경고_확인버튼_클릭:
            state.error = nil
            return .run { send in await send(.inner(.errorSheetPresented(false))) }
        case .검색_버튼_눌렀을때:
            switch state.selectedTab {
            case .pokit: return .none
            case .recommend:
                return RecommendFeature()
                    .reduce(
                        into: &state.recommend,
                        action: .view(.검색_버튼_눌렀을때)
                    )
                    .map(Action.recommend)
            }
        case .알림_버튼_눌렀을때:
            switch state.selectedTab {
            case .pokit: return .none
            case .recommend:
                return RecommendFeature()
                    .reduce(
                        into: &state.recommend,
                        action: .view(.알림_버튼_눌렀을때)
                    )
                    .map(Action.recommend)
            }
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .linkCopySuccess(url):
            guard let url else { return .none }
            state.linkPopup = .link(
                title: Constants.복사한_링크_저장하기_문구,
                url: url.absoluteString
            )
            state.link = url.absoluteString
            return .none
            
        case let .경고_띄움(error):
            state.error = error
            return .run { send in await send(.inner(.errorSheetPresented(true))) }
            
        case let .errorSheetPresented(isPresented):
            state.isErrorSheetPresented = isPresented
            return .none
            
        case let .링크팝업_활성화(type):
            state.linkPopup = type
            return .none
        case let .카테고리상세_이동(category):
            if category.categoryName == Constants.미분류 {
                state.path.removeAll()
                return .send(.pokit(.delegate(.미분류_카테고리_활성화)))
            }
            state.path.append(.카테고리상세(.init(category: category)))
            return .none
            
        case let .공유받은_카테고리_이동(category, type):
            if let context = topCategoryContext(from: state), context.categoryId == category.id {
                return refreshCategoryDetail(
                    stackElementId: context.stackElementId,
                    type: type
                )
            }
            state.path.append(.카테고리상세(.init(type: type, category: category)))
            return .none
            
        case let .포킷_딥링크_이동(category, contentId, userId):
            state.contentDetail = nil
            
            if let context = topCategoryContext(from: state), context.categoryId == category.id {
                let refreshEffect = refreshCategoryDetail(
                    stackElementId: context.stackElementId,
                    type: CategoryType.참여
                )
                
                if let contentId {
                    state.contentDetail = ContentDetailFeature.State(contentId: contentId)
                    return refreshEffect
                }
                
                guard userId != nil else { return refreshEffect }
                return .concatenate(
                    refreshEffect,
                    openParticipantsSheet(stackElementId: context.stackElementId)
                )
            }
            
            state.path.append(.카테고리상세(.init(type: .참여, category: category)))
            guard let stackElementId = state.path.ids.last else { return .none }
            
            if let contentId {
                state.contentDetail = ContentDetailFeature.State(contentId: contentId)
                return .none
            }
            
            guard userId != nil else { return .none }
            return openParticipantsSheet(stackElementId: stackElementId)
            
        case let .딥링크_수신(route):
            switch route {
            case let .kakaoSharedCategory(categoryId, shareType):
                switch state.selectedTab {
                case .pokit:
                    amplitudeTrack(.view_home_pokit(entryPoint: "deeplink"))
                case .recommend:
                    amplitudeTrack(.view_home_recommend(entryPoint: "deeplink"))
                }
                return .send(.async(.공유받은_카테고리_조회(categoryId: categoryId, shareType: shareType)))
                
            case let .pokitShared(categoryId, contentId, userId):
                guard let categoryId else { return .none }
                return .send(.async(.포킷_딥링크_처리(
                    categoryId: categoryId,
                    contentId: contentId,
                    userId: userId
                )))
            case .pokitAlert:
                return .send(.delegate(.알림함이동))
            }
            
        default: return .none
        }
    }
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .공유받은_카테고리_조회(categoryId: categoryId, shareType: shareType):
            return .run { send in
                do {
                    let request = BasePageableRequest(page: 0, size: 10, sort: ["createdAt,desc"])
                    let response = try await categoryClient.공유받은_카테고리_조회("\(categoryId)", request)
                    let category = BaseCategoryItem(
                        id: response.category.categoryId,
                        userId: 0,
                        categoryName: response.category.categoryName,
                        categoryImage: BaseCategoryImage(
                            imageId: response.category.categoryImageId,
                            imageURL: response.category.categoryImageUrl
                        ),
                        contentCount: response.category.contentCount,
                        createdAt: "",
                        openType: .공개,
                        keywordType: .default,
                        userCount: 0,
                        isFavorite: false
                    )
                    let type: CategoryType = shareType == "invite" ? .초대 : .공유
                    await send(.inner(.공유받은_카테고리_이동(category: category, type: type)), animation: .smooth)
                } catch {
                    guard let errorResponse = error as? ErrorResponse else { return }
                    let errorDomain = BaseError(response: errorResponse)
                    await send(.inner(.경고_띄움(errorDomain)))
                }
            }
            
        case let .포킷_딥링크_처리(categoryId, contentId, userId):
            return .run { send in
                do {
                    let request = BasePageableRequest(page: 0, size: 30, sort: ["createdAt,desc"])
                    let list = try await categoryClient.카테고리_목록_조회(request, false, false).toDomain()
                    if let category = list.data?.first(where: { $0.id == categoryId }) {
                        await send(.inner(.포킷_딥링크_이동(category: category, contentId: contentId, userId: userId)), animation: .smooth)
                        return
                    }

                    let response = try await categoryClient.카테고리_상세_조회("\(categoryId)")
                    let category = BaseCategoryItem(
                        id: response.categoryId,
                        userId: 0,
                        categoryName: response.categoryName,
                        categoryImage: response.categoryImage.toDomain(),
                        contentCount: 0,
                        createdAt: "",
                        openType: .공개,
                        keywordType: .default,
                        userCount: 0,
                        isFavorite: false,
                        alertEnabled: response.alertEnabled
                    )

                    await send(.inner(.포킷_딥링크_이동(category: category, contentId: contentId, userId: userId)), animation: .smooth)
                } catch {
                    guard let errorResponse = error as? ErrorResponse else { return }
                    let errorDomain = BaseError(response: errorResponse)
                    await send(.inner(.경고_띄움(errorDomain)))
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
    
    func linkPopupButtonTapped(state: inout State) -> Effect<Action> {
        switch state.linkPopup {
        case .link:
            state.linkPopup = nil
            return .send(.delegate(.링크추가하기))
        case .success:
            state.linkPopup = nil
            guard let category = state.categoryOfSavedContent else { return .none }
            state.categoryOfSavedContent = nil
            return .send(.inner(.카테고리상세_이동(category: category)))
        case .error, .text, .warning, .report, .none:
            return .none
        }
    }

    func topCategoryContext(from state: State) -> (
        stackElementId: StackElementID,
        categoryId: Int
    )? {
        guard
            let stackElementId = state.path.ids.last,
            case let .카테고리상세(categoryDetailState) = state.path.last
        else { return nil }

        return (stackElementId, categoryDetailState.category.id)
    }

    func refreshCategoryDetail(
        stackElementId: StackElementID,
        type: CategoryType
    ) -> Effect<Action> {
        .concatenate(
            .send(.path(.element(
                id: stackElementId,
                action: .카테고리상세(.inner(.타입_변경(type)))
            ))),
            .send(.path(.element(
                id: stackElementId,
                action: .카테고리상세(.inner(.pagenation_초기화))
            ))),
            .send(.path(.element(
                id: stackElementId,
                action: .카테고리상세(.async(.카테고리_내_컨텐츠_목록_조회_API))
            ))),
            .send(.path(.element(
                id: stackElementId,
                action: .카테고리상세(.async(.포킷_초대된_유저_목록_조회_API))
            )))
        )
    }

    func openParticipantsSheet(stackElementId: StackElementID) -> Effect<Action> {
        .send(.path(.element(
            id: stackElementId,
            action: .카테고리상세(.view(.참여인원_버튼_눌렀을때))
        )))
    }
}
