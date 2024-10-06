//
//  LinkListFeature.swift
//  Feature
//
//  Created by 김도형 on 8/2/24.

import Foundation

import ComposableArchitecture
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct ContentListFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(PasteboardClient.self)
    private var pasteBoard
    @Dependency(RemindClient.self)
    private var remindClient
    @Dependency(ContentClient.self)
    private var contentClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(contentType: ContentType) {
            self.contentType = contentType
        }

        let contentType: ContentType
        fileprivate var domain = ContentList()
        var contents: IdentifiedArrayOf<BaseContentItem>? {
            guard let contentList = domain.contentList.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseContentItem>()
            contentList.forEach { identifiedArray.append($0) }
            return identifiedArray
        }
        var contentCount: Int {
            get { domain.contentCount }
        }
        var isListDescending = true
        /// sheet item
        var bottomSheetItem: BaseContentItem? = nil
        var alertItem: BaseContentItem? = nil
        var shareSheetItem: BaseContentItem? = nil
        /// pagenation
        var hasNext: Bool {
            domain.contentList.hasNext
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
        public enum View: Equatable, BindableAction {
            /// - Binding
            case binding(BindingAction<State>)
            
            case pagenation
            /// - Button Tapped
            case bottomSheet(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContentItem
            )
            case 컨텐츠_항목_눌렀을때(content: BaseContentItem)
            case 컨텐츠_항목_케밥_버튼_눌렀을때(content: BaseContentItem)
            case 컨텐츠_삭제_눌렀을때(content: BaseContentItem)
            case 정렬_버튼_눌렀을때
            case 뒤로가기_버튼_눌렀을때
            /// - On Appeared
            case 뷰가_나타났을때
            
            case 링크_공유시트_해제
            case 경고시트_해제
        }

        public enum InnerAction: Equatable {
            case 바텀시트_해제
            case 컨텐츠_목록_조회_API_반영(BaseContentListInquiry)
            case 컨텐츠_삭제_API_반영(id: Int)
            case 컨텐츠_목록_조회_페이징_API_반영(BaseContentListInquiry)
            case 페이징_초기화
            case 컨텐츠_개수_업데이트(Int)
        }

        public enum AsyncAction: Equatable {
            case 컨텐츠_삭제_API(id: Int)
            case 컨텐츠_목록_조회_페이징_API
            case 컨텐츠_목록_조회_API
            case 컨텐츠_개수_조회_API
        }

        public enum ScopeAction: Equatable {
            case bottomSheet(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContentItem
            )
        }

        public enum DelegateAction: Equatable {
            case 링크상세(content: BaseContentItem)
            case 링크수정(contentId: Int)
            case linkCopyDetected(URL?)
            case 컨텐츠_목록_조회
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
            ._printChanges()
    }
}
//MARK: - FeatureAction Effect
private extension ContentListFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_항목_케밥_버튼_눌렀을때(let content):
            state.bottomSheetItem = content
            return .none
        case .컨텐츠_항목_눌렀을때(let content):
            return .send(.delegate(.링크상세(content: content)))
        case .bottomSheet(let delegate, let content):
            return .concatenate(
                .send(.inner(.바텀시트_해제)),
                .send(.scope(.bottomSheet(delegate: delegate, content: content)))
            )
        case .컨텐츠_삭제_눌렀을때:
            guard let id = state.alertItem?.id else { return .none }
            return .send(.async(.컨텐츠_삭제_API(id: id)))
        case .binding:
            return .none
        case .정렬_버튼_눌렀을때:
            state.isListDescending.toggle()
            state.domain.pageable.sort = [
                state.isListDescending ? "createdAt,desc" : "createdAt,asc"
            ]
            return .send(.inner(.페이징_초기화), animation: .pokitDissolve)
        case .뒤로가기_버튼_눌렀을때:
            return .run { _ in await dismiss() }
        case .뷰가_나타났을때:
            return .merge(
                .send(.async(.컨텐츠_개수_조회_API)),
                .send(.async(.컨텐츠_목록_조회_API)),
                .run { send in
                    for await _ in self.pasteBoard.changes() {
                        let url = try await pasteBoard.probableWebURL()
                        await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                    }
                }
            )
        case .pagenation:
            return .send(.async(.컨텐츠_목록_조회_페이징_API))
        case .링크_공유시트_해제:
            state.shareSheetItem = nil
            return .none
        case .경고시트_해제:
            state.alertItem = nil
            return .none
        }
    }

    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .바텀시트_해제:
            state.bottomSheetItem = nil
            return .none
        case .컨텐츠_목록_조회_페이징_API_반영(let contentList):
            let list = state.domain.contentList.data ?? []
            guard let newList = contentList.data else { return .none }

            state.domain.contentList = contentList
            state.domain.contentList.data = list + newList
            return .none
        case .컨텐츠_삭제_API_반영(id: let id):
            state.alertItem = nil
            state.domain.contentList.data?.removeAll { $0.id == id }
            return .none
        case .컨텐츠_목록_조회_API_반영(let contentList):
            state.domain.contentList = contentList
            return .none
        case .페이징_초기화:
            state.domain.pageable.page = 0
            state.domain.contentList.data = nil
            return .send(.async(.컨텐츠_목록_조회_API), animation: .pokitDissolve)
        case let .컨텐츠_개수_업데이트(count):
            state.domain.contentCount = count
            return .none
        }
    }

    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_삭제_API(id: let id):
            let count = state.domain.contentCount
            let newCount = count - 1
            
            return .merge(
                .send(.inner(.컨텐츠_개수_업데이트(newCount))),
                .run { send in
                    let _ = try await contentClient.컨텐츠_삭제("\(id)")
                    await send(.inner(.컨텐츠_삭제_API_반영(id: id)), animation: .pokitSpring)
                }
            )
            
        case .컨텐츠_목록_조회_페이징_API:
            state.domain.pageable.page += 1
            return .run { [
                type = state.contentType,
                pageableRequest = BasePageableRequest(
                    page: state.domain.pageable.page,
                    size: state.domain.pageable.size,
                    sort: state.domain.pageable.sort
                )
            ] send in
                let contentList: BaseContentListInquiry
                switch type {
                case .unread:
                    contentList = try await remindClient.읽지않음_컨텐츠_조회(
                        pageableRequest
                    ).toDomain()
                case .favorite:
                    contentList = try await remindClient.즐겨찾기_링크모음_조회(
                        pageableRequest
                    ).toDomain()
                }
                
                await send(.inner(.컨텐츠_목록_조회_페이징_API_반영(contentList)))
            }
        case .컨텐츠_목록_조회_API:
            return contentListFetch(state: &state)
        case .컨텐츠_개수_조회_API:
            return .run { [ contentType = state.contentType ] send in
                switch contentType {
                case .favorite:
                    let count = try await remindClient.즐겨찾기_컨텐츠_개수_조회().count
                    await send(.inner(.컨텐츠_개수_업데이트(count)), animation: .pokitSpring)
                case .unread:
                    let count = try await remindClient.읽지않음_컨텐츠_개수_조회().count
                    await send(.inner(.컨텐츠_개수_업데이트(count)), animation: .pokitSpring)
                }
            }
        }
    }

    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        /// - 링크에 대한 `공유` /  `수정` / `삭제` delegate
        switch action {
        case .bottomSheet(let delegate, let content):
            switch delegate {
            case .deleteCellButtonTapped:
                state.alertItem = content
                return .none
            case .editCellButtonTapped:
                return .send(.delegate(.링크수정(contentId: content.id)))
            case .favoriteCellButtonTapped:
                return .none
            case .shareCellButtonTapped:
                state.shareSheetItem = content
                return .none
            }
        }
    }

    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_목록_조회:
            return .send(.async(.컨텐츠_목록_조회_API))
        default:
            return .none
        }
    }
    
    func contentListFetch(state: inout State) -> Effect<Action> {
        return .run { [
            pageable = state.domain.pageable,
            contentType = state.contentType
        ] send in
            let stream = AsyncThrowingStream<BaseContentListInquiry, Error> { continuation in
                Task {
                    for page in 0...pageable.page {
                        let paeagableRequest = BasePageableRequest(
                            page: page,
                            size: pageable.size,
                            sort: pageable.sort
                        )
                        switch contentType {
                        case .favorite:
                            let contentList = try await remindClient.즐겨찾기_링크모음_조회(
                                paeagableRequest
                            ).toDomain()
                            continuation.yield(contentList)
                        case .unread:
                            let contentList = try await remindClient.읽지않음_컨텐츠_조회(
                                paeagableRequest
                            ).toDomain()
                            continuation.yield(contentList)
                        }
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
            await send(.inner(.컨텐츠_목록_조회_API_반영(contentItems)))
        }
    }
}

public extension ContentListFeature {
    enum ContentType: String {
        case unread = "안읽음"
        case favorite = "즐겨찾기"

        var title: String { self.rawValue }
    }
}
