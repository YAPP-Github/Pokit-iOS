//
//  CategoryDetailFeature.swift
//  Feature
//
//  Created by 김민호 on 7/17/24.

import Foundation

import ComposableArchitecture
import FeatureContentCard
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct CategoryDetailFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(PasteboardClient.self)
    private var pasteboard
    @Dependency(CategoryClient.self)
    private var categoryClient
    @Dependency(ContentClient.self)
    private var contentClient
    @Dependency(KakaoShareClient.self)
    private var kakaoShareClient
    @Dependency(UserDefaultsClient.self)
    private var userDefaults
    @Dependency(\.amplitude.track)
    private var amplitudeTrack
    
    /// - State
    @ObservableState
    public struct State: Equatable {
        /// Domain
        var domain: CategoryDetail
        public var category: BaseCategoryItem {
            get { domain.category }
        }
        var isUnreadFiltered: Bool {
            get { domain.condition.isUnreadFlitered }
        }
        var isFavoriteFiltered: Bool {
            get { domain.condition.isFavoriteFlitered }
        }
        var isFavoriteCategory: Bool {
            get { domain.category.isFavorite }
        }
        
        var sortType: SortType = .최신순
        var categories: IdentifiedArrayOf<BaseCategoryItem>? {
            guard let categoryList = domain.categoryListInQuiry.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseCategoryItem>()
            categoryList.forEach { category in
                identifiedArray.append(category)
            }
            return identifiedArray
        }
        var contents: IdentifiedArrayOf<ContentCardFeature.State> = []
        /// sheet Presented
        var isCategorySheetPresented: Bool = false
        var isCategorySelectSheetPresented: Bool = false
        var isPokitDeleteSheetPresented: Bool = false
        var isParticipantsSheetPresented: Bool = false
        var isRemoveParticipantSheetPresented: Bool = false
        var isLeaveSheetPresented: Bool = false
        /// selected user
        var selectedUserToRemove: InvitedUser?
        var type: CategoryType
        /// pagenation
        var hasNext: Bool {
            domain.contentList.hasNext
        }
        var isLoading: Bool = true
        /// computed properties
        var invitedUsers: [InvitedUser] {
            domain.invitedUsers
        }
        var isSharedCategory: Bool {
            domain.invitedUsers.count >= 2
        }
        /// 현재 로그인한 사용자의 ID
        var currentUserId: Int?
        var isCreator: Bool {
            guard let currentUserId else { return false }
            return domain.category.userId == currentUserId
        }
        
        public init(type: CategoryType = .참여, category: BaseCategoryItem) {
            self.type = type
            self.domain = .init(categpry: category)
        }
    }
    
    /// - Action
    @CasePathable
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case contents(IdentifiedActionOf<ContentCardFeature>)
        
        @CasePathable
        public enum View: BindableAction, Equatable {
            case binding(BindingAction<State>)
            case dismiss
            case pagenation
            case 새로고침

            /// 즐겨찾기 or 안읽음 버튼 눌렀을 때
            case 분류_버튼_눌렀을때(SortCollectType)
            case 정렬_버튼_눌렀을때
            case 공유_버튼_눌렀을때(CategoryKaKaoShareModel.ShareType)
            case 카테고리_케밥_버튼_눌렀을때
            case 카테고리_선택_버튼_눌렀을때
            case 카테고리_선택했을때(BaseCategoryItem)
            case 뷰가_나타났을때
            case 링크_추가_버튼_눌렀을때
            case 참여인원_버튼_눌렀을때
            case 초대_수락하기_버튼_눌렀을때
            case 저장하기_버튼_눌렀을때
        }
        
        @CasePathable
        public enum InnerAction: Equatable {
            case 카테고리_시트_활성화(Bool)
            case 카테고리_선택_시트_활성화(Bool)
            case 카테고리_삭제_시트_활성화(Bool)
            case 참여인원_시트_활성화(Bool)
            case 내보내기_확인_시트_활성화(Bool)
            case 나가기_확인_시트_활성화(Bool)
            case 카카오톡_공유(CategoryKaKaoShareModel.ShareType)
            case 타입_변경(CategoryType)

            case 카테고리_목록_조회_API_반영(BaseCategoryListInquiry)
            case 카테고리_내_컨텐츠_목록_조회_API_반영(BaseContentListInquiry)
            case pagenation_API_반영(BaseContentListInquiry)
            case pagenation_초기화
            case 포킷_초대된_유저_목록_조회_API_반영([InvitedUser])
            case 내보낼_유저_선택(InvitedUser)
        }
        
        @CasePathable
        public enum AsyncAction: Equatable {
            case 카테고리_내_컨텐츠_목록_조회_API
            case 카테고리_목록_조회_API
            case 페이징_재조회
            case 클립보드_감지
            case 포킷_초대된_유저_목록_조회_API
            case 포킷_내보내기_API(categoryId: Int, resignUserId: Int)
            case 포킷_나가기_API(categoryId: Int)
            case 포킷_초대_수락_API(categoryId: Int)
            case 공유받은_포킷_저장_API
        }
        
        @CasePathable
        public enum ScopeAction {
            case categoryBottomSheet(PokitBottomSheet.Delegate)
            case categoryDeleteBottomSheet(PokitDeleteBottomSheet.Delegate)
            case participantsBottomSheet(ParticipantsBottomSheetDelegate)
            case removeParticipantBottomSheet(PokitDeleteBottomSheet.Delegate)
            case leaveBottomSheet(PokitDeleteBottomSheet.Delegate)
            case contents(IdentifiedActionOf<ContentCardFeature>)
        }

        @CasePathable
        public enum ParticipantsBottomSheetDelegate: Equatable {
            case removeParticipant(InvitedUser)
        }

        @CasePathable
        public enum DelegateAction: Equatable {
            case contentItemTapped(BaseContentItem)
            case linkCopyDetected(URL?)
            case 링크수정(contentId: Int)
            case 링크추가(categoryId: Int)
            case 포킷삭제
            case 포킷수정(BaseCategoryItem)
            case 포킷공유
            case 포킷나가기
            case 카테고리_내_컨텐츠_목록_조회
            case 초대_수락_완료
            case 저장_완료
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
            
        case .contents(let contentsAction):
            return .send(.scope(.contents(contentsAction)))
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
            .forEach(\.contents, action: \.contents) {
                ContentCardFeature()
            }
    }
}
//MARK: - FeatureAction Effect
private extension CategoryDetailFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case .정렬_버튼_눌렀을때:
            state.sortType = state.sortType == .최신순
            ? .오래된순
            : .최신순
            
            state.domain.pageable.sort = [
                state.sortType == .최신순 ? "createdAt,desc" : "createdAt,asc"
            ]
            
            return .concatenate(
                .send(.inner(.pagenation_초기화), animation: .pokitDissolve),
                .send(.async(.카테고리_내_컨텐츠_목록_조회_API))
            )
            
        case let .분류_버튼_눌렀을때(type):
            switch type {
            case .즐겨찾기:
                state.domain.condition.isFavoriteFlitered.toggle()
                guard state.domain.condition.isFavoriteFlitered else { break }
                state.domain.condition.isUnreadFlitered = !state.domain.condition.isFavoriteFlitered
            case .안읽음:
                state.domain.condition.isUnreadFlitered.toggle()
                guard state.domain.condition.isUnreadFlitered else { break }
                state.domain.condition.isFavoriteFlitered = !state.domain.condition.isUnreadFlitered
            }
            return .concatenate(
                .send(.inner(.pagenation_초기화), animation: .pokitDissolve),
                .send(.async(.카테고리_내_컨텐츠_목록_조회_API))
            )
            
        case let .공유_버튼_눌렀을때(shareType):
            return .send(.inner(.카카오톡_공유(shareType)))
            
        case .링크_추가_버튼_눌렀을때:
            let id = state.category.id
            return .send(.delegate(.링크추가(categoryId: id)))
            
        case .카테고리_케밥_버튼_눌렀을때:
            return .run { send in await send(.inner(.카테고리_시트_활성화(true))) }
        
        case .카테고리_선택_버튼_눌렀을때:
            return .send(.inner(.카테고리_선택_시트_활성화(true)))
            
        case .카테고리_선택했을때(let item):
            state.domain.category = item
            return .run { send in
                await send(.inner(.pagenation_초기화), animation: .pokitDissolve)
                await send(.async(.카테고리_내_컨텐츠_목록_조회_API))
                await send(.async(.포킷_초대된_유저_목록_조회_API))
                await send(.inner(.카테고리_선택_시트_활성화(false)))
            }
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .뷰가_나타났을때:
            /// 현재 로그인한 사용자 ID 가져오기
            if let userIdString = userDefaults.stringKey(.userId),
               let userId = Int(userIdString) {
                state.currentUserId = userId
            }

            /// 데이터가 있으면 페이징 재조회, 없으면 초기 조회
            let contentListEffect: Effect<Action> = {
                guard let _ = state.domain.contentList.data?.count else {
                    return .concatenate(
                        .send(.inner(.pagenation_초기화)),
                        .send(.async(.카테고리_내_컨텐츠_목록_조회_API))
                    )
                }
                return .send(.async(.페이징_재조회), animation: .pokitSpring)
            }()

            return .merge(
                contentListEffect,
                .send(.async(.카테고리_목록_조회_API)),
                .send(.async(.포킷_초대된_유저_목록_조회_API)),
                .send(.async(.클립보드_감지))
            )
        case .pagenation:
            state.domain.pageable.page += 1
            return .send(.async(.카테고리_내_컨텐츠_목록_조회_API))

        case .참여인원_버튼_눌렀을때:
            return .send(.inner(.참여인원_시트_활성화(true)))

        case .초대_수락하기_버튼_눌렀을때:
            let categoryId = state.domain.category.id
            return .send(.async(.포킷_초대_수락_API(categoryId: categoryId)))

        case .저장하기_버튼_눌렀을때:
            return .send(.async(.공유받은_포킷_저장_API))

        case .새로고침:
            return .concatenate(
                .send(.inner(.pagenation_초기화), animation: .pokitDissolve),
                .send(.async(.카테고리_내_컨텐츠_목록_조회_API))
            )
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .카테고리_시트_활성화(presented):
            state.isCategorySheetPresented = presented
            return .none
        
        case let .카테고리_삭제_시트_활성화(presented):
            state.isPokitDeleteSheetPresented = presented
            return .none
            
        case let .카테고리_선택_시트_활성화(presented):
            state.isCategorySelectSheetPresented = presented
            return .none
            
        case let .카테고리_목록_조회_API_반영(response):
            state.domain.categoryListInQuiry = response
            guard
                let first = response.data?.first(where: { item in
                    item.id == state.domain.category.id
                })
            else { return .none }
            state.domain.category = first
            return .none
            
        case .카테고리_내_컨텐츠_목록_조회_API_반영(let contentList):
            state.domain.contentList = contentList
            
            var identifiedArray = IdentifiedArrayOf<ContentCardFeature.State>()
            contentList.data?.forEach { identifiedArray.append(.init(content: $0)) }
            state.contents = identifiedArray
            
            state.isLoading = false
            return .none
            
        case .pagenation_API_반영(let contentList):
            let list = state.domain.contentList.data ?? []
            guard let newList = contentList.data else { return .none }

            state.domain.contentList = contentList
            state.domain.contentList.data = list + newList
            newList.forEach { state.contents.append(.init(content: $0)) }
            return .none
            
        case .pagenation_초기화:
            state.domain.pageable.page = 0
            state.domain.contentList.data = nil
            state.isLoading = true
            state.contents.removeAll()
            return .none
            
        case .포킷_초대된_유저_목록_조회_API_반영(let users):
            state.domain.invitedUsers = users
            return .none

        case let .참여인원_시트_활성화(presented):
            state.isParticipantsSheetPresented = presented
            return .none

        case let .내보내기_확인_시트_활성화(presented):
            state.isRemoveParticipantSheetPresented = presented
            return .none

        case let .나가기_확인_시트_활성화(presented):
            state.isLeaveSheetPresented = presented
            return .none

        case let .내보낼_유저_선택(user):
            state.selectedUserToRemove = user
            return .send(.inner(.내보내기_확인_시트_활성화(true)))

        case let .타입_변경(type):
            state.type = type
            return .none

        case let .카카오톡_공유(shareType):
            amplitudeTrack(.share_link(
                linkId: "\(state.domain.category.id)",
                shareTarget: "kakaotalk"
            ))
            kakaoShareClient.카테고리_카카오톡_공유(
                CategoryKaKaoShareModel(
                    shareType: shareType,
                    categoryName: state.domain.category.categoryName,
                    categoryId: state.domain.category.id,
                    imageURL: state.domain.category.categoryImage.imageURL
                )
            )
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .카테고리_목록_조회_API:
            return .run { send in
                let request = BasePageableRequest(page: 0, size: 30, sort: ["createdAt,desc"])
                let response = try await categoryClient.카테고리_목록_조회(request, true, false).toDomain()
                await send(.inner(.카테고리_목록_조회_API_반영(response)))
            }
            
        case .카테고리_내_컨텐츠_목록_조회_API:
            switch state.type {
            case .초대, .공유:
                return .run { [
                    id = state.domain.category.id,
                    categoryName = state.domain.category.categoryName,
                    pageable = state.domain.pageable
                ] send in
                    let request = BasePageableRequest(
                        page: pageable.page,
                        size: pageable.size,
                        sort: pageable.sort
                    )
                    let response = try await categoryClient.공유받은_카테고리_조회("\(id)", request)

                    // SharedCategoryResponse.Content를 BaseContentItem으로 변환
                    let baseContentItems = response.contents.data.map { content in
                        BaseContentItem(
                            id: content.contentId,
                            categoryName: categoryName,
                            categoryId: id,
                            title: content.title,
                            memo: content.memo,
                            thumbNail: content.thumbNail,
                            data: content.data,
                            domain: content.domain,
                            createdAt: content.createdAt,
                            isRead: false,
                            isFavorite: false,
                            keyword: nil,
                            authorUserId: content.authorUserId,
                            authorNickname: content.authorNickname,
                            authorProfileImageURL: content.authorProfileImageURL
                        )
                    }

                    let contentList = BaseContentListInquiry(
                        data: baseContentItems,
                        page: response.contents.page,
                        size: response.contents.size,
                        sort: response.contents.sort.map { $0.toDomain() },
                        hasNext: response.contents.hasNext
                    )

                    pageable.page == 0
                    ? await send(.inner(.카테고리_내_컨텐츠_목록_조회_API_반영(contentList)), animation: .pokitDissolve)
                    : await send(.inner(.pagenation_API_반영(contentList)))
                }

            case .참여:
                return .run { [
                    id = state.domain.category.id,
                    pageable = state.domain.pageable,
                    condition = state.domain.condition
                ] send in
                    let request = BasePageableRequest(
                        page: pageable.page,
                        size: pageable.size,
                        sort: pageable.sort
                    )
                    let conditionRequest = BaseConditionRequest(categoryIds: condition.categoryIds, isRead: condition.isUnreadFlitered, favorites: condition.isFavoriteFlitered)
                    let contentList = try await contentClient.카테고리_내_컨텐츠_목록_조회(
                        "\(id)", request, conditionRequest
                    ).toDomain()
                    pageable.page == 0
                    ? await send(.inner(.카테고리_내_컨텐츠_목록_조회_API_반영(contentList)), animation: .pokitDissolve)
                    : await send(.inner(.pagenation_API_반영(contentList)))
                }
            }
            
        case .페이징_재조회:
            switch state.type {
            case .초대, .공유:
                return .run { [
                    pageable = state.domain.pageable,
                    categoryId = state.domain.category.id,
                    categoryName = state.domain.category.categoryName
                ] send in
                    let stream = AsyncThrowingStream<BaseContentListInquiry, Error> { continuation in
                        Task {
                            for page in 0...pageable.page {
                                let paeagableRequest = BasePageableRequest(
                                    page: page,
                                    size: pageable.size,
                                    sort: pageable.sort
                                )
                                let response = try await categoryClient.공유받은_카테고리_조회("\(categoryId)", paeagableRequest)

                                // SharedCategoryResponse.Content를 BaseContentItem으로 변환
                                let baseContentItems = response.contents.data.map { content in
                                    BaseContentItem(
                                        id: content.contentId,
                                        categoryName: categoryName,
                                        categoryId: categoryId,
                                        title: content.title,
                                        memo: content.memo,
                                        thumbNail: content.thumbNail,
                                        data: content.data,
                                        domain: content.domain,
                                        createdAt: content.createdAt,
                                        isRead: false,
                                        isFavorite: false,
                                        keyword: nil,
                                        authorUserId: content.authorUserId,
                                        authorNickname: content.authorNickname,
                                        authorProfileImageURL: content.authorProfileImageURL
                                    )
                                }

                                let contentList = BaseContentListInquiry(
                                    data: baseContentItems,
                                    page: response.contents.page,
                                    size: response.contents.size,
                                    sort: response.contents.sort.map { $0.toDomain() },
                                    hasNext: response.contents.hasNext
                                )
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
                    await send(.inner(.카테고리_내_컨텐츠_목록_조회_API_반영(contentItems)), animation: .pokitSpring)
                }

            case .참여:
                return .run { [
                    pageable = state.domain.pageable,
                    categoryId = state.domain.category.id,
                    condition = state.domain.condition
                ] send in
                    let stream = AsyncThrowingStream<BaseContentListInquiry, Error> { continuation in
                        Task {
                            for page in 0...pageable.page {
                                let paeagableRequest = BasePageableRequest(
                                    page: page,
                                    size: pageable.size,
                                    sort: pageable.sort
                                )
                                let conditionRequest = BaseConditionRequest(
                                    categoryIds: condition.categoryIds,
                                    isRead: condition.isUnreadFlitered,
                                    favorites: condition.isFavoriteFlitered
                                )
                                let contentList = try await contentClient.카테고리_내_컨텐츠_목록_조회(
                                    "\(categoryId)",
                                    paeagableRequest,
                                    conditionRequest
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
                    await send(.inner(.카테고리_내_컨텐츠_목록_조회_API_반영(contentItems)), animation: .pokitSpring)
                }
            }
            
        case .클립보드_감지:
            return .run { send in
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                }
            }
            
        case .포킷_초대된_유저_목록_조회_API:
            return .run { [id = state.domain.category.id] send in
                let response = try await categoryClient.포킷_초대된_유저_목록_조회(id)
                let users = response.map { $0.toDomain() }
                await send(.inner(.포킷_초대된_유저_목록_조회_API_반영(users)))
            }

        case let .포킷_내보내기_API(categoryId, resignUserId):
            return .run { send in
                try await categoryClient.포킷_내보내기(categoryId, resignUserId)
                await send(.inner(.내보내기_확인_시트_활성화(false)))
                await send(.async(.포킷_초대된_유저_목록_조회_API))
            }

        case let .포킷_나가기_API(categoryId):
            return .run { send in
                try await categoryClient.포킷_나가기(categoryId)
                await send(.inner(.나가기_확인_시트_활성화(false)))
                await send(.delegate(.포킷나가기))
                await dismiss()
            }

        case let .포킷_초대_수락_API(categoryId):
            return .run { send in
                try await categoryClient.포킷_초대_수락(categoryId)
                await send(.inner(.타입_변경(.참여)))
                await send(.delegate(.초대_수락_완료))
            }

        case .공유받은_포킷_저장_API:
            return .run { [category = state.domain.category] send in
                let request = CopiedCategoryRequest(
                    originCategoryId: category.id,
                    categoryName: category.categoryName,
                    categoryImageId: category.categoryImage.id,
                    keyword: category.keywordType.rawValue,
                    openType: category.openType.rawValue
                )
                try await categoryClient.공유받은_카테고리_저장(request)
                await send(.inner(.타입_변경(.참여)))
                await send(.delegate(.저장_완료))
            }
        }
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        /// - 카테고리에 대한 `공유` / `포킷 설정` / `삭제` / `나가기` Delegate
        case .categoryBottomSheet(let delegateAction):
            switch delegateAction {
            case .shareCellButtonTapped:
                return .run { send in
                    await send(.inner(.카테고리_시트_활성화(false)))
                    await send(.inner(.카카오톡_공유(.공유)))
                }

            case .pokitSettingCellButtonTapped:
                return .run { [category = state.category] send in
                    await send(.inner(.카테고리_시트_활성화(false)))
                    await send(.delegate(.포킷수정(category)))
                }

            case .editCellButtonTapped:
                return .run { [category = state.category] send in
                    await send(.inner(.카테고리_시트_활성화(false)))
                    await send(.delegate(.포킷수정(category)))
                }

            case .deleteCellButtonTapped:
                return .run { send in
                    await send(.inner(.카테고리_시트_활성화(false)))
                    await send(.inner(.카테고리_삭제_시트_활성화(true)))
                }

            case .leaveCellButtonTapped:
                return .run { send in
                    await send(.inner(.카테고리_시트_활성화(false)))
                    await send(.inner(.나가기_확인_시트_활성화(true)))
                }

            default: return .none
            }
        /// - 카테고리의 `삭제`를 눌렀을 때 Sheet Delegate
        case .categoryDeleteBottomSheet(let delegateAction):
            switch delegateAction {
            case .cancelButtonTapped:
                return .run { send in await send(.inner(.카테고리_삭제_시트_활성화(false))) }
                
            case .deleteButtonTapped:
                state.isPokitDeleteSheetPresented = false
                return .run { [categoryId = state.domain.category.id] send in
                    await send(.inner(.카테고리_삭제_시트_활성화(false)))
                    await send(.delegate(.포킷삭제))
                    try await categoryClient.카테고리_삭제(categoryId)
                }
            }
            
        /// - 참여인원 바텀시트 Delegate
        case .participantsBottomSheet(let delegateAction):
            switch delegateAction {
            case .removeParticipant(let user):
                return .run { send in
                    await send(.inner(.참여인원_시트_활성화(false)))
                    await send(.inner(.내보낼_유저_선택(user)))
                }
            }

        /// - 유저 내보내기 확인 바텀시트 Delegate
        case .removeParticipantBottomSheet(let delegateAction):
            switch delegateAction {
            case .cancelButtonTapped:
                return .run { send in
                    await send(.inner(.내보내기_확인_시트_활성화(false)))
                }

            case .deleteButtonTapped:
                guard let selectedUser = state.selectedUserToRemove else { return .none }
                return .run { [categoryId = state.domain.category.id] send in
                    await send(.async(.포킷_내보내기_API(categoryId: categoryId, resignUserId: selectedUser.id)))
                }
            }

        /// - 포킷 나가기 확인 바텀시트 Delegate
        case .leaveBottomSheet(let delegateAction):
            switch delegateAction {
            case .cancelButtonTapped:
                return .run { send in
                    await send(.inner(.나가기_확인_시트_활성화(false)))
                }

            case .deleteButtonTapped:
                return .run { [categoryId = state.domain.category.id] send in
                    await send(.async(.포킷_나가기_API(categoryId: categoryId)))
                }
            }

        case let .contents(.element(id: _, action: .delegate(.컨텐츠_항목_케밥_버튼_눌렀을때(content)))):
            return .send(.delegate(.contentItemTapped(content)))
        case .contents:
            return .none
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        switch action {
        case .카테고리_내_컨텐츠_목록_조회:
            return .send(.async(.페이징_재조회))
        default:
            return .none
        }
    }
}
