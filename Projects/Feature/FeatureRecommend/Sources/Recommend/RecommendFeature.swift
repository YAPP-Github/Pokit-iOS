//
//  RecommendFeature.swift
//  Feature
//
//  Created by 김도형 on 1/29/25.

import SwiftUI

import ComposableArchitecture
import Domain
import CoreKit
import Util
import DSKit

@Reducer
public struct RecommendFeature {
    /// - Dependency
    @Dependency(ContentClient.self)
    private var contentClient
    @Dependency(UserClient.self)
    private var userClient
    @Dependency(CategoryClient.self)
    private var categoryClient
    @Dependency(\.openURL)
    private var openURL
    @Dependency(\.amplitude.track)
    private var amplitudeTrack
    
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var domain = Recommend()
        var isListDescending = true
        /// pagenation
        var hasNext: Bool {
            domain.contentList.hasNext
        }
        var recommendedList: IdentifiedArrayOf<BaseContentItem>? {
            guard let list = domain.contentList.data else { return nil }
            var array = IdentifiedArrayOf<BaseContentItem>()
            array.append(contentsOf: list)
            return array
        }
        var myInterestList: IdentifiedArrayOf<BaseInterest> {
            var array = IdentifiedArrayOf<BaseInterest>()
            array.append(contentsOf: domain.myInterests)
            return array
        }
        var pokitList: [BaseCategoryItem]? {
            get { domain.categoryListInQuiry.data }
        }
        var isLoading: Bool = true
        var selectedInterest: BaseInterest?
        var shareContent: BaseContentItem?
        var interests: [BaseInterest] { domain.interests }
        var showKeywordSheet: Bool = false
        var selectedInterestList = Set<BaseInterest>()
        var reportContent: BaseContentItem?
        var pendingReportContent: BaseContentItem?
        var reportReasons: [BaseReportReason] = []
        var showSelectSheet: Bool = false
        var selectedPokit: BaseCategoryItem?
        var addContent: BaseContentItem?
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
        public enum View: BindableAction {
            /// - Binding
            case binding(BindingAction<State>)
            
            case onAppear
            case pagination
            
            case 추가하기_버튼_눌렀을때(BaseContentItem)
            case 공유하기_버튼_눌렀을때(BaseContentItem)
            case 신고하기_버튼_눌렀을때(BaseContentItem)
            case 신고하기_확인_버튼_눌렀을때(String)
            case 전체보기_버튼_눌렀을때(ScrollViewProxy)
            case 관심사_버튼_눌렀을때(BaseInterest, ScrollViewProxy)
            case 관심사_편집_버튼_눌렀을때
            case 키워드_선택_버튼_눌렀을때(Set<BaseInterest>)
            case 링크_공유_완료되었을때
            case 검색_버튼_눌렀을때
            case 알림_버튼_눌렀을때
            case 추천_컨텐츠_눌렀을때(BaseContentItem)
            case 경고시트_dismiss
            case 포킷선택_항목_눌렀을때(pokit: BaseCategoryItem)
            case 포킷_추가하기_버튼_눌렀을때
        }
        
        @CasePathable
        public enum InnerAction {
            case 추천_조회_API_반영(BaseContentListInquiry)
            case 추천_조회_페이징_API_반영(BaseContentListInquiry)
            case 유저_관심사_조회_API_반영([BaseInterest])
            case 관심사_조회_API_반영([BaseInterest])
            case 컨텐츠_신고사유_조회_API_반영([BaseReportReason])
            case 컨텐츠_신고_API_반영(Int)
            case 카테고리_목록_조회_API_반영(categoryList: BaseCategoryListInquiry)
        }
        
        @CasePathable
        public enum AsyncAction: Equatable {
            case 추천_조회_API
            case 추천_조회_페이징_API
            case 유저_관심사_조회_API
            case 관심사_조회_API
            case 컨텐츠_신고사유_조회_API
            case 컨텐츠_신고_API(contentId: Int, reportReason: String)
            case 카테고리_목록_조회_API
            case 컨텐츠_추가_API
        }
        
        @CasePathable
        public enum ScopeAction: Equatable { case doNothing }
        
        @CasePathable
        public enum DelegateAction: Equatable {
            case 저장하기_완료
            case 검색_버튼_눌렀을때
            case 알림_버튼_눌렀을때
            case 컨텐츠_신고_API_반영
            case 포킷_추가하기_버튼_눌렀을때
            case 포킷_추가하기_완료
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
private extension RecommendFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding: return .none
        case .onAppear:
            return .merge(
                shared(.async(.추천_조회_API), state: &state),
                shared(.async(.관심사_조회_API), state: &state)
            )
        case .pagination:
            return shared(.async(.추천_조회_페이징_API), state: &state)
        case let .추가하기_버튼_눌렀을때(content):
            state.addContent = content
            state.showSelectSheet = true
            return shared(.async(.카테고리_목록_조회_API), state: &state)
        case let .공유하기_버튼_눌렀을때(content):
            state.shareContent = content
            return .none
        case let .신고하기_버튼_눌렀을때(content):
            guard !state.reportReasons.isEmpty else {
                state.pendingReportContent = content
                return shared(.async(.컨텐츠_신고사유_조회_API), state: &state)
            }
            state.reportContent = content
            return .none
        case let .신고하기_확인_버튼_눌렀을때(reportReason):
            guard let content = state.reportContent else { return .none }
            state.reportContent = nil
            state.pendingReportContent = nil
            return shared(
                .async(.컨텐츠_신고_API(contentId: content.id, reportReason: reportReason)),
                state: &state
            )
        case let .전체보기_버튼_눌렀을때(proxy):
            guard state.selectedInterest != nil else { return .none }
            state.domain.contentList.data = nil
            
            state.selectedInterest = nil
            let leading = 20 / UIScreen.main.bounds.width
            let anchor = UnitPoint(
                x: leading,
                y: UnitPoint.leading.y
            )
            proxy.scrollTo("전체보기", anchor: anchor)
            return shared(.async(.추천_조회_API), state: &state)
        case let .관심사_버튼_눌렀을때(interest, proxy):
            guard state.selectedInterest != interest else { return .none }
            state.domain.contentList.data = nil
            
            state.selectedInterest = interest
            proxy.scrollTo(interest.description, anchor: .leading)
            return shared(.async(.추천_조회_API), state: &state)
        case .링크_공유_완료되었을때:
            state.shareContent = nil
            return .none
        case .검색_버튼_눌렀을때:
            return .send(.delegate(.검색_버튼_눌렀을때))
        case .알림_버튼_눌렀을때:
            return .send(.delegate(.알림_버튼_눌렀을때))
        case let .추천_컨텐츠_눌렀을때(content):
            guard let url = URL(string: content.data) else { return .none }
            let index = state.recommendedList?.index(id: content.id)
            amplitudeTrack(.view_link_detail(
                linkId: "\(content.id)",
                linkDomain: content.data,
                entryPoint: "recommend",
                positionIndex: index,
                cardType: "list",
                algoVersion: "v1.2"
            ))
            return .run { _ in await openURL(url) }
        case .관심사_편집_버튼_눌렀을때:
            state.showKeywordSheet = true
            return .none
        case let .키워드_선택_버튼_눌렀을때(interests):
            state.showKeywordSheet = false
            state.selectedInterest = nil
            state.selectedInterestList = interests
            return .run { [ interests = state.selectedInterestList ] send in
                let request = InterestRequest(interests: interests.map(\.description))
                try await userClient.관심사_수정(model: request)
                await send(.async(.유저_관심사_조회_API))
                await send(.async(.추천_조회_API))
            }
        case .경고시트_dismiss:
            state.reportContent = nil
            state.pendingReportContent = nil
            return .none
        case .포킷선택_항목_눌렀을때(pokit: let pokit):
            state.selectedPokit = pokit
            state.showSelectSheet = false
            return shared(.async(.컨텐츠_추가_API), state: &state)
        case .포킷_추가하기_버튼_눌렀을때:
            state.showSelectSheet = false
            return .send(.delegate(.포킷_추가하기_버튼_눌렀을때))
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .추천_조회_페이징_API_반영(let contentList):
            let list = state.domain.contentList.data ?? []
            guard let newList = contentList.data else { return .none }

            state.domain.contentList = contentList
            state.domain.contentList.data = list + newList
            return .none
        case .추천_조회_API_반영(let contentList):
            state.domain.contentList = contentList
            
            state.isLoading = false
            return .none
        case let .유저_관심사_조회_API_반영(interests):
            state.domain.myInterests = interests.filter { interest in
                state.interests.contains(interest)
            }
            interests.forEach {
                guard state.interests.contains($0) else { return }
                state.selectedInterestList.insert($0)
            }
            return .none
        case let .관심사_조회_API_반영(interests):
            state.domain.interests = interests.filter({ interest in
                interest.code != "default"
            })
            return .none
        case let .컨텐츠_신고사유_조회_API_반영(reasons):
            state.reportReasons = reasons
            if let pendingReportContent = state.pendingReportContent {
                state.reportContent = pendingReportContent
                state.pendingReportContent = nil
            }
            return .none
        case let .컨텐츠_신고_API_반영(contentId):
            state.domain.contentList.data?.removeAll(where: { $0.id == contentId })
            return .send(.delegate(.컨텐츠_신고_API_반영))
        case .카테고리_목록_조회_API_반영(categoryList: let categoryList):
            /// - `카테고리_목록_조회`의 filter 옵션을 `false`로 해두었기 때문에 `미분류` 카테고리 또한 항목에서 조회가 가능함

            /// [1]. `미분류`에 해당하는 인덱스 번호와 항목을 체크, 없다면 목록갱신이 불가함
            guard
                let unclassifiedItemIdx = categoryList.data?.firstIndex(where: {
                    $0.categoryName == Constants.미분류
                })
            else { return .none }
            guard
                let unclassifiedItem = categoryList.data?.first(where: {
                    $0.categoryName == Constants.미분류
                })
            else { return .none }
            
            /// [2]. 새로운 list변수를 만들어주고 카테고리 항목 순서를 재배치 (최신순 정렬 시  미분류는 항상 맨 마지막)
            var list = categoryList
            list.data?.remove(at: unclassifiedItemIdx)
            list.data?.insert(unclassifiedItem, at: 0)
            
            /// [3]. 도메인 항목 리스트에 list 할당
            state.domain.categoryListInQuiry = list
            state.selectedPokit = unclassifiedItem
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .추천_조회_페이징_API:
            state.domain.pageable.page += 1
            return .run { [
                pageable = state.domain.pageable,
                keyword = state.selectedInterest?.description
            ] send in
                let pageableRequest = BasePageableRequest(
                    page: pageable.page,
                    size: pageable.size,
                    sort: pageable.sort
                )
                let contentList = try await contentClient.추천_컨텐츠_조회(
                    pageableRequest,
                    keyword
                ).toDomain()
                
                await send(.inner(.추천_조회_페이징_API_반영(contentList)))
            }
        case .추천_조회_API:
            return contentListFetch(state: &state)
        case .유저_관심사_조회_API:
            return .run { send in
                let interests = try await userClient.유저_관심사_목록_조회()
                    .map { $0.toDomian() }
                    .sorted { $0.description < $1.description }
                
                await send(.inner(.유저_관심사_조회_API_반영(interests)))
            }
        case .관심사_조회_API:
            return .run { send in
                let interests = try await userClient.관심사_목록_조회()
                    .map { $0.toDomian() }
                    .sorted { $0.description < $1.description }
                
                await send(.inner(.관심사_조회_API_반영(interests)))
                await send(.async(.유저_관심사_조회_API))
            }
        case .컨텐츠_신고사유_조회_API:
            return .run { send in
                let reasons = try await contentClient.컨텐츠_신고사유_조회().toDomain()
                await send(.inner(.컨텐츠_신고사유_조회_API_반영(reasons)))
            }
        case let .컨텐츠_신고_API(contentId, reportReason):
            return .run { send in
                let request = ContentReportRequest(reportReason: reportReason)
                try await contentClient.컨텐츠_신고_사유(contentId, request)
                await send(
                    .inner(.컨텐츠_신고_API_반영(contentId)),
                    animation: .pokitSpring
                )
            }
        case .카테고리_목록_조회_API:
            let request = BasePageableRequest(
                page: state.domain.pageable.page,
                size: 30,
                sort: state.domain.pageable.sort
            )
            return categoryListFetch(request: request)
        case .컨텐츠_추가_API:
            guard let categoryId = state.selectedPokit?.id,
                  let content = state.addContent
            else { return .none }
            let request = ContentBaseRequest(
                data: content.data,
                title: content.title,
                categoryId: categoryId,
                memo: content.memo ?? "",
                alertYn: "NO",
                thumbNail: content.thumbNail
            )
            let index = state.recommendedList?.index(id: content.id)
            return .run { send in
                let response = try await contentClient.컨텐츠_추가(request)
                amplitudeTrack(.add_link(
                    folderId: "\(categoryId)",
                    linkDomain: content.data,
                    entryPoint: "recommend",
                    linkId: "\(response.contentId)",
                    positionIndex: index,
                    algoVersion: "v1.2"
                ))
                await send(.delegate(.저장하기_완료))
            }
        }
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        switch action {
        case .포킷_추가하기_완료:
            guard state.addContent != nil else { return .none }
            state.showSelectSheet = true
            return shared(.async(.카테고리_목록_조회_API), state: &state)
        case .저장하기_완료:
            state.addContent = nil
            return .none
        default: return .none
        }
    }
    
    /// - Shared Effect
    func shared(_ action: Action, state: inout State) -> Effect<Action> {
        switch action {
        case .view(let viewAction):
            return handleViewAction(viewAction, state: &state)
        case .inner(let innerAction):
            return handleInnerAction(innerAction, state: &state)
        case .async(let asyncAction):
            return handleAsyncAction(asyncAction, state: &state)
        case .scope(let scopeAction):
            return handleScopeAction(scopeAction, state: &state)
        case .delegate(let delegateAction):
            return handleDelegateAction(delegateAction, state: &state)
        }
    }
    
    func contentListFetch(state: inout State) -> Effect<Action> {
        return .run { [
            pageable = state.domain.pageable,
            keyword = state.selectedInterest?.description
        ] send in
            let stream = AsyncThrowingStream<BaseContentListInquiry, Error> { continuation in
                Task {
                    for page in 0...pageable.page {
                        let pageableRequest = BasePageableRequest(
                            page: page,
                            size: pageable.size,
                            sort: pageable.sort
                        )
                        let contentList = try await contentClient.추천_컨텐츠_조회(
                            pageableRequest,
                            keyword
                        ).toDomain()
                        continuation.yield(contentList)
                    }
                    continuation.finish()
                }
            }
            var contentItems: BaseContentListInquiry? = nil
            for try await contentList in stream {
                let items = contentItems?.data ?? []
                let newItems = contentList.data ?? []
                contentItems = contentList
                contentItems?.data = items + newItems
            }
            guard let contentItems else { return }
            await send(.inner(.추천_조회_API_반영(contentItems)), animation: .pokitDissolve)
        }
    }
    
    func categoryListFetch(request: BasePageableRequest) -> Effect<Action> {
        return .run { send in
            let categoryList = try await categoryClient.카테고리_목록_조회(request, false, true).toDomain()
            await send(.inner(.카테고리_목록_조회_API_반영(categoryList: categoryList)), animation: .pokitDissolve)
        }
    }
}
