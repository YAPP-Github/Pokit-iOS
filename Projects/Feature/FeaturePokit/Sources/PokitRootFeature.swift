//
//  PokitRootFeature.swift
//  Feature
//
//  Created by 김민호 on 7/16/24.

import Foundation

import ComposableArchitecture
import FeatureContentCard
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct PokitRootFeature {
    /// - Dependency
    @Dependency(CategoryClient.self)
    private var categoryClient
    @Dependency(ContentClient.self)
    private var contentClient
    @Dependency(RemindClient.self)
    private var remindClient
    @Dependency(KakaoShareClient.self)
    private var kakaoShareClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        @Presents var linkEdit: PokitLinkEditFeature.State?
        var folderType: PokitRootFilterType = .folder(.포킷)
        var sortType: PokitRootFilterType = .sort(.최신순)

        fileprivate var domain = Pokit()
        var categories: IdentifiedArrayOf<BaseCategoryItem>? {
            guard let categoryList = domain.categoryList.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseCategoryItem>()
            categoryList.forEach { category in
                identifiedArray.append(category)
            }
            return identifiedArray
        }
        var contents: IdentifiedArrayOf<ContentCardFeature.State> = []

        var selectedKebobItem: BaseCategoryItem?

        var isKebobSheetPresented: Bool = false
        var isPokitDeleteSheetPresented: Bool = false
        
        var hasNext: Bool { domain.categoryList.hasNext }
        var unclassifiedHasNext: Bool { domain.unclassifiedContentList.hasNext }
        var isLoading: Bool = true

        public init() { }
    }

    /// - Action
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
            case 검색_버튼_눌렀을때
            case 알람_버튼_눌렀을때
            case 설정_버튼_눌렀을때
            case 필터_버튼_눌렀을때(PokitRootFilterType.Folder)
            case 분류_버튼_눌렀을때
            case 케밥_버튼_눌렀을때(BaseCategoryItem)
            case 포킷추가_버튼_눌렀을때
            case 링크추가_버튼_눌렀을때
            case 편집하기_버튼_눌렀을때
            case 카테고리_눌렀을때(BaseCategoryItem)
            case 컨텐츠_항목_눌렀을때(BaseContentItem)
            case 뷰가_나타났을때
            case 페이지_로딩중일때
        }

        public enum InnerAction: Equatable {
            case sort
            case 카테고리_시트_활성화(Bool)
            case 카테고리_삭제_시트_활성화(Bool)
            
            case 미분류_카테고리_조회_API_반영(contentList: BaseContentListInquiry)
            case 미분류_전쳬_링크_조회_API_반영(contentList: BaseContentListInquiry)
            case 미분류_카테고리_페이징_조회_API_반영(contentList: BaseContentListInquiry)
            case 미분류_카테고리_컨텐츠_삭제_API_반영(contentId: Int)
            
            case 카테고리_조회_API_반영(categoryList: BaseCategoryListInquiry)
            case 카테고리_페이징_조회_API_반영(contentList: BaseCategoryListInquiry)
            
            case 페이지네이션_초기화
        }

        public enum AsyncAction: Equatable {
            case 카테고리_조회_API
            case 카테고리_페이징_조회_API
            case 카테고리_페이징_재조회_API
            case 카테고리_삭제_API(categoryId: Int)
            
            case 미분류_카테고리_조회_API
            case 미분류_전쳬_링크_조회_API
            case 미분류_카테고리_페이징_조회_API
            case 미분류_카테고리_페이징_재조회_API
        }

        @CasePathable
        public enum ScopeAction {
            case bottomSheet(PokitBottomSheet.Delegate)
            case deleteBottomSheet(PokitDeleteBottomSheet.Delegate)
            case contents(IdentifiedActionOf<ContentCardFeature>)
            case linkEdit(PresentationAction<PokitLinkEditFeature.Action>)
        }

        public enum DelegateAction: Equatable {
            case searchButtonTapped
            case alertButtonTapped
            case settingButtonTapped

            case categoryTapped(BaseCategoryItem)
            case linkPopup(text: String)
            case 수정하기(BaseCategoryItem)
            case 링크수정하기(id: Int)
            /// 링크상세로 이동
            case contentDetailTapped(BaseContentItem)
            case 미분류_카테고리_컨텐츠_조회
            
            case 포킷추가_버튼_눌렀을때
            case 링크추가_버튼_눌렀을때
            case 미분류_카테고리_활성화
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
            
        case .contents(let contentsAciton):
            return .send(.scope(.contents(contentsAciton)))
        }
    }

    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
            .forEach(\.contents, action: \.contents) { ContentCardFeature() }
            .ifLet(\.$linkEdit, action: \.scope.linkEdit) { PokitLinkEditFeature() }
            
    }
}
//MARK: - FeatureAction Effect
private extension PokitRootFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
        /// - Navigation Bar
        case .검색_버튼_눌렀을때:
            return .run { send in await send(.delegate(.searchButtonTapped)) }
            
        case .알람_버튼_눌렀을때:
            return .run { send in await send(.delegate(.alertButtonTapped)) }
            
        case .설정_버튼_눌렀을때:
            return .run { send in await send(.delegate(.settingButtonTapped)) }

        case .필터_버튼_눌렀을때(let selectedFolderType):
            state.folderType = .folder(selectedFolderType)
            state.sortType = .sort(.최신순)
            return .send(.inner(.sort))
            
        case .분류_버튼_눌렀을때:
            switch state.folderType {
            case .folder(.포킷):
                state.sortType = .sort(state.sortType == .sort(.이름순) ? .최신순 : .이름순)
                return .send(.inner(.sort), animation: .pokitDissolve)
                
            case .folder(.미분류):
                state.sortType = .sort(.최신순)
                return .send(.inner(.sort), animation: .pokitDissolve)
                
            default: return .none
            }

        case .케밥_버튼_눌렀을때(let selectedItem):
            state.selectedKebobItem = selectedItem
            return .run { send in await send(.inner(.카테고리_시트_활성화(true))) }
            
        case .포킷추가_버튼_눌렀을때:
            return .run { send in await send(.delegate(.포킷추가_버튼_눌렀을때)) }
            
        case .링크추가_버튼_눌렀을때:
            return .run { send in await send(.delegate(.링크추가_버튼_눌렀을때)) }
            
        case .편집하기_버튼_눌렀을때:
            return .run { send in await send(.async(.미분류_전쳬_링크_조회_API)) }

        case .카테고리_눌렀을때(let category):
            return .run { send in await send(.delegate(.categoryTapped(category))) }

            /// - 링크 아이템을 눌렀을 때
        case .컨텐츠_항목_눌렀을때(let selectedItem):
            return .run { send in await send(.delegate(.contentDetailTapped(selectedItem))) }
            
        case .뷰가_나타났을때:
            switch state.folderType {
            case .folder(.포킷):
                guard let _ = state.domain.categoryList.data?.count else {
                    return .send(.inner(.페이지네이션_초기화))
                }
                return .send(.async(.카테고리_페이징_재조회_API), animation: .pokitSpring)
                
            case .folder(.미분류):
                guard let _ = state.domain.unclassifiedContentList.data?.count else {
                    return .send(.inner(.페이지네이션_초기화))
                }
                return .send(.async(.미분류_카테고리_페이징_재조회_API), animation: .pokitSpring)
                
            default: return .none
            }
            
        case .페이지_로딩중일때:
            switch state.folderType {
            case .folder(.포킷):
                return .send(.async(.카테고리_페이징_조회_API))
                
            case .folder(.미분류):
                return .send(.async(.미분류_카테고리_페이징_조회_API))
                
            default: return .none
            }
        }
    }

    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .카테고리_시트_활성화(presented):
            state.isKebobSheetPresented = presented
            return .none

        case let .카테고리_삭제_시트_활성화(presented):
            state.isPokitDeleteSheetPresented = presented
            return .none

        case .sort:
            switch state.sortType {
            case .sort(.이름순):
                state.domain.pageable.sort = ["name,asc"]
                return .send(.inner(.페이지네이션_초기화), animation: .pokitDissolve)
                
            case .sort(.오래된순):
                state.domain.pageable.sort = ["createdAt,asc"]
                return .send(.inner(.페이지네이션_초기화), animation: .pokitDissolve)
                
            case .sort(.최신순):
                state.domain.pageable.sort = ["createdAt,desc"]
                return .send(.inner(.페이지네이션_초기화), animation: .pokitDissolve)
                
            default: return .none
            }

        case .미분류_카테고리_조회_API_반영(contentList: let contentList):
            state.domain.unclassifiedContentList = contentList
            
            var contents = IdentifiedArrayOf<ContentCardFeature.State>()
            contentList.data?.forEach { contents.append(.init(content: $0)) }
            state.contents = contents
            
            state.isLoading = false
            return .none
            
        case let .미분류_전쳬_링크_조회_API_반영(contentList):
            state.linkEdit = PokitLinkEditFeature.State(linkList: contentList)
            return .none
            
        case let .카테고리_조회_API_반영(categoryList):
            state.domain.categoryList = categoryList
            return .none

        case let .카테고리_페이징_조회_API_반영(contentList):
            let list = state.domain.categoryList.data ?? []
            guard let newList = contentList.data else { return .none }

            state.domain.categoryList = contentList
            state.domain.categoryList.data = list + newList
            state.domain.pageable.size = 10
            return .none

        case let .미분류_카테고리_페이징_조회_API_반영(contentList):
            let list = state.domain.unclassifiedContentList.data ?? []
            guard let newList = contentList.data else { return .none }

            state.domain.unclassifiedContentList = contentList
            state.domain.unclassifiedContentList.data = list + newList
            state.domain.pageable.size = 10
            newList.forEach { content in
                state.contents.append(.init(content: content))
            }
            return .none
            
        case let .미분류_카테고리_컨텐츠_삭제_API_반영(contentId: contentId):
            guard
                let index = state.domain.unclassifiedContentList.data?.firstIndex(where: {
                    $0.id == contentId
                })
            else { return .none }
            state.domain.unclassifiedContentList.data?.remove(at: index)
            state.contents.removeAll { $0.content.id == contentId }
            state.isPokitDeleteSheetPresented = false
            return .none
            
        case .페이지네이션_초기화:
            state.domain.pageable.page = 0
            state.domain.categoryList.data = nil
            state.domain.unclassifiedContentList.data = nil
            state.isLoading = true
            state.contents.removeAll()
            
            switch state.folderType {
            case .folder(.포킷):
                return .send(.async(.카테고리_조회_API), animation: .pokitDissolve)
                
            case .folder(.미분류):
                return .send(.async(.미분류_카테고리_조회_API), animation: .pokitDissolve)
                
            default: return .none
            }
        }
    }

    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .카테고리_삭제_API(categoryId):
            return .run { _ in try await categoryClient.카테고리_삭제(categoryId) }
            
        case .미분류_카테고리_페이징_조회_API:
            state.domain.pageable.page += 1
            return .run { [pageable = state.domain.pageable] send in
                let request = BasePageableRequest(page: pageable.page, size: pageable.size, sort: pageable.sort)
                let contentList = try await contentClient.미분류_카테고리_컨텐츠_조회(request).toDomain()
                await send(.inner(.미분류_카테고리_페이징_조회_API_반영(contentList: contentList)))
            }
            
        case .카테고리_페이징_조회_API:
            state.domain.pageable.page += 1
            return .run { [pageable = state.domain.pageable] send in
                let request = BasePageableRequest(page: pageable.page, size: pageable.size, sort: pageable.sort)
                let classified = try await categoryClient.카테고리_목록_조회(request, true, false).toDomain()
                await send(.inner(.카테고리_페이징_조회_API_반영(contentList: classified)))
            }
            
        case .미분류_카테고리_조회_API:
            state.domain.pageable.page = 0
            return .run { [pageable = state.domain.pageable] send in
                let request = BasePageableRequest(page: pageable.page, size: pageable.size, sort: pageable.sort)
                let contentList = try await contentClient.미분류_카테고리_컨텐츠_조회(request).toDomain()
                await send(.inner(.미분류_카테고리_조회_API_반영(contentList: contentList)), animation: .pokitSpring)
            }
            
        case .미분류_전쳬_링크_조회_API:
            return .run { [pageable = state.domain.pageable] send in
                let request = BasePageableRequest(page: 0, size: 100, sort: pageable.sort)
                let contentList = try await contentClient.미분류_카테고리_컨텐츠_조회(request).toDomain()
                await send(.inner(.미분류_전쳬_링크_조회_API_반영(contentList: contentList)))
            }
            
        case .카테고리_조회_API:
            state.domain.pageable.page = 0
            return .run { [pageable = state.domain.pageable] send in
                let request = BasePageableRequest(page: pageable.page, size: pageable.size, sort: pageable.sort)
                let classified = try await categoryClient.카테고리_목록_조회(request, true, false).toDomain()
                await send(.inner(.카테고리_조회_API_반영(categoryList: classified)), animation: .pokitSpring)
            }
            
        case .미분류_카테고리_페이징_재조회_API:
            return .run { [pageable = state.domain.pageable] send in
                let stream = AsyncThrowingStream<BaseContentListInquiry, Error> { continuation in
                    Task {
                        for page in 0...pageable.page {
                            let contentList = try await contentClient.미분류_카테고리_컨텐츠_조회(
                                BasePageableRequest(
                                    page: page,
                                    size: pageable.size,
                                    sort: pageable.sort
                                )
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
                await send(
                    .inner(.미분류_카테고리_조회_API_반영(contentList: contentItems)),
                    animation: .pokitSpring
                )
            }
        case .카테고리_페이징_재조회_API:
            return .run { [pageable = state.domain.pageable] send in
                let stream = AsyncThrowingStream<BaseCategoryListInquiry, Error> { continuation in
                    Task {
                        for page in 0...pageable.page {
                            let categoryList = try await categoryClient.카테고리_목록_조회(
                                BasePageableRequest(
                                    page: page,
                                    size: pageable.size,
                                    sort: pageable.sort
                                ),
                                true,
                                false
                            ).toDomain()
                            continuation.yield(categoryList)
                        }
                        continuation.finish()
                    }
                }
                var categoryItems: BaseCategoryListInquiry? = nil
                for try await categoryList in stream {
                    let items = categoryItems?.data ?? []
                    let newItems = categoryList.data ?? []
                    categoryItems = categoryList
                    categoryItems?.data = items + newItems
                }
                guard let categoryItems else { return }
                await send(.inner(.카테고리_조회_API_반영(categoryList: categoryItems)), animation: .pokitSpring)
            }
        }
    }

    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        /// - Kebob BottomSheet Delegate
        case .bottomSheet(.shareCellButtonTapped):
            /// Todo: 공유하기
            guard let selectedItem = state.selectedKebobItem else {
                /// 🚨 Error Case [1]: 항목을 공유하려는데 항목이 없을 때
                return .none
            }
            kakaoShareClient.카테고리_카카오톡_공유(
                CategoryKaKaoShareModel(
                    categoryName: selectedItem.categoryName,
                    categoryId: selectedItem.id,
                    imageURL: selectedItem.categoryImage.imageURL
                )
            )
            state.isKebobSheetPresented = false
            return .none

        case .bottomSheet(.editCellButtonTapped):
            state.isKebobSheetPresented = false
            /// [2] 수정하기로 이동
            return .run { [item = state.selectedKebobItem] send in
                guard let item else { return }
                await send(.delegate(.수정하기(item)))
            }

        case .bottomSheet(.deleteCellButtonTapped):
            return .run { send in
                await send(.inner(.카테고리_시트_활성화(false)))
                await send(.inner(.카테고리_삭제_시트_활성화(true)))
            }

        /// - Pokit Delete BottomSheet Delegate
        case .deleteBottomSheet(.cancelButtonTapped):
            state.isPokitDeleteSheetPresented = false
            return .none

        case .deleteBottomSheet(.deleteButtonTapped):
            guard let selectedItem = state.selectedKebobItem else {
                /// 🚨 Error Case [1]: 항목을 삭제하려는데 항목이 없을 때
                return .none
            }
            guard let index = state.domain.categoryList.data?.firstIndex(of: selectedItem) else {
                return .none
            }
            state.domain.categoryList.data?.remove(at: index)
            state.isPokitDeleteSheetPresented = false

            return .run { send in await send(.async(.카테고리_삭제_API(categoryId: selectedItem.id))) }
            
        case let .contents(.element(id: _, action: .delegate(.컨텐츠_항목_케밥_버튼_눌렀을때(content)))):
            return .send(.delegate(.contentDetailTapped(content)))
        case .contents:
            return .none
            
        case let .linkEdit(.presented(.delegate(.링크_편집_종료(list, type)))):
            /// 링크가 비어있을때는 전부 삭제
            if list.isEmpty {
                state.contents.removeAll()
            } else {
                /// 링크가 일부 있을 때 -> 그 일부를 붙여넣기
                var linkIds = IdentifiedArrayOf<ContentCardFeature.State>()
                list.forEach { item in
                    state.contents.forEach { content in
                        if item.id == content.content.id {
                            linkIds.append(content)
                        }
                    }
                }
                state.contents.removeAll()
                state.contents = linkIds
            }
            state.linkEdit = nil
            
            if case let .링크이동(categoryName) = type {
                let text = "\(categoryName)\n카테고리로 이동되었습니다."
                return .send(.delegate(.linkPopup(text: text)))
            }
            return .none
            
        case .linkEdit:
            return .none
            
        default: return .none
        }
    }

    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        switch action {
        case .미분류_카테고리_컨텐츠_조회:
            switch state.folderType {
            case .folder(.포킷):
                return .send(.async(.카테고리_페이징_재조회_API), animation: .pokitSpring)
                
            case .folder(.미분류):
                return .send(.async(.미분류_카테고리_페이징_재조회_API), animation: .pokitSpring)
                
            default: return .none
            }
        case .미분류_카테고리_활성화:
            state.folderType = .folder(.미분류)
            state.sortType = .sort(.최신순)
            return .send(.inner(.sort))
        default:
            return .none
        }
    }
}
