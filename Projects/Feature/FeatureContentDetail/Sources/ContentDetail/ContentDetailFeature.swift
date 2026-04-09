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
    @Dependency(CategoryClient.self)
    private var categoryClient
    @Dependency(UserDefaultsClient.self)
    private var userDefaults
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
        var showReportSheet: Bool = false
        var shouldPresentReportSheetAfterReasonFetch: Bool = false
        var showSelectSheet: Bool = false
        var memoTextAreaState: PokitInputStyle.State = .memo(isReadOnly: true)
        var linkPopup: PokitLinkPopup.PopupType?
        var currentUserId: Int?
        var pokitList: [BaseCategoryItem]?
        var selectedPokit: BaseCategoryItem?
        var reportReasons: [BaseReportReason] = []
        var isMine: Bool {
            guard
                let currentUserId,
                let authorUserId = domain.content?.authorUserId
            else { return true }
            return currentUserId == authorUserId
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
            case 내포킷에_저장하기_버튼_눌렀을때
            case 신고하기_버튼_눌렀을때
            case 신고하기_확인_버튼_눌렀을때(String)
            case 신고시트_해제
            case 포킷선택_항목_눌렀을때(BaseCategoryItem)
            case 포킷_추가하기_버튼_눌렀을때
            case 키보드_취소_버튼_눌렀을때
            case 키보드_완료_버튼_눌렀울때
            
            case 경고시트_해제

            case 링크_공유_완료되었을때
        }

        @CasePathable
        public enum InnerAction: Equatable {
            case 컨텐츠_상세_조회_API_반영(content: BaseContentDetail)
            case 즐겨찾기_API_반영(Bool)
            case 컨텐츠_신고사유_조회_API_반영([BaseReportReason])
            case 카테고리_목록_조회_API_반영(BaseCategoryListInquiry)
            case 링크팝업_활성화(PokitLinkPopup.PopupType)
        }

        @CasePathable
        public enum AsyncAction: Equatable {
            case 컨텐츠_상세_조회_API(id: Int)
            case 즐겨찾기_API(id: Int)
            case 즐겨찾기_취소_API(id: Int)
            case 컨텐츠_삭제_API(id: Int)
            case 컨텐츠_신고사유_조회_API
            case 컨텐츠_신고_API(id: Int, reportReason: String)
            case 카테고리_목록_조회_API
            case 컨텐츠_추가_API(categoryId: Int)
            case 컨텐츠_수정_API
        }

        @CasePathable
        public enum ScopeAction: Equatable { case 없음 }

        @CasePathable
        public enum DelegateAction: Equatable {
            case editButtonTapped(contentId: Int)
            case 즐겨찾기_갱신_완료
            case 컨텐츠_조회_완료
            case 컨텐츠_삭제_완료
            case 포킷_추가하기_버튼_눌렀을때
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
            if let userIdString = userDefaults.stringKey(.userId),
               let userId = Int(userIdString) {
                state.currentUserId = userId
            }
            syncMemoState(for: &state)
            if let id = state.domain.contentId {
                return .send(.async(.컨텐츠_상세_조회_API(id: id)))
            }
            if let content = state.domain.content {
                state.memo = content.memo
                syncMemoState(for: &state)
                return .none
            }
            return .none
        case .공유_버튼_눌렀을때:
            state.showShareSheet = true
            return .none
        case .수정_버튼_눌렀을때:
            guard state.isMine else { return .none }
            guard let content = state.domain.content else { return .none }
            return .send(.delegate(.editButtonTapped(contentId: content.id)))
        case .삭제_버튼_눌렀을때:
            guard state.isMine else { return .none }
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
            guard
                let content = state.domain.content,
                let favorites = state.domain.content?.favorites
            else { return .none }
            return favorites
            ? .send(.async(.즐겨찾기_취소_API(id: content.id)))
            : .send(.async(.즐겨찾기_API(id: content.id)))
        case .내포킷에_저장하기_버튼_눌렀을때:
            state.showSelectSheet = true
            return .send(.async(.카테고리_목록_조회_API))
        case .신고하기_버튼_눌렀을때:
            guard !state.reportReasons.isEmpty else {
                state.shouldPresentReportSheetAfterReasonFetch = true
                return .send(.async(.컨텐츠_신고사유_조회_API))
            }
            state.showReportSheet = true
            return .none
        case let .신고하기_확인_버튼_눌렀을때(reportReason):
            guard let content = state.domain.content else { return .none }
            state.showReportSheet = false
            state.shouldPresentReportSheetAfterReasonFetch = false
            return .send(.async(.컨텐츠_신고_API(id: content.id, reportReason: reportReason)))
        case .신고시트_해제:
            state.showReportSheet = false
            state.shouldPresentReportSheetAfterReasonFetch = false
            return .none
        case let .포킷선택_항목_눌렀을때(pokit):
            state.selectedPokit = pokit
            state.showSelectSheet = false
            return .send(.async(.컨텐츠_추가_API(categoryId: pokit.id)))
        case .포킷_추가하기_버튼_눌렀을때:
            state.showSelectSheet = false
            return .send(.delegate(.포킷_추가하기_버튼_눌렀을때))
        case .링크_공유_완료되었을때:
            state.showShareSheet = false
            return .none
        case .경고시트_해제:
            state.showAlert = false
            return .none
        case .키보드_취소_버튼_눌렀을때:
            guard state.isMine else { return .none }
            state.memo = state.domain.content?.memo ?? ""
            return .none
        case .키보드_완료_버튼_눌렀울때:
            guard state.isMine else { return .none }
            let memo = state.memo
            guard memo != state.domain.content?.memo else { return .none }
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
            syncMemoState(for: &state)
            return .send(.delegate(.컨텐츠_조회_완료))
        case .즐겨찾기_API_반영(let favorite):
            state.domain.content?.favorites = favorite
            return .send(.delegate(.즐겨찾기_갱신_완료))
        case let .컨텐츠_신고사유_조회_API_반영(reasons):
            state.reportReasons = reasons
            if state.shouldPresentReportSheetAfterReasonFetch {
                state.showReportSheet = true
                state.shouldPresentReportSheetAfterReasonFetch = false
            }
            return .none
        case let .카테고리_목록_조회_API_반영(categoryList):
            guard
                let unclassifiedItemIdx = categoryList.data?.firstIndex(where: {
                    $0.categoryName == Constants.미분류
                }),
                let unclassifiedItem = categoryList.data?.first(where: {
                    $0.categoryName == Constants.미분류
                })
            else {
                state.pokitList = categoryList.data
                return .none
            }

            var list = categoryList
            list.data?.remove(at: unclassifiedItemIdx)
            list.data?.insert(unclassifiedItem, at: 0)
            state.pokitList = list.data
            state.selectedPokit = unclassifiedItem
            return .none
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
                await send(
                    .inner(.컨텐츠_상세_조회_API_반영(content: contentResponse)),
                    animation: .pokitDissolve
                )
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
        case .컨텐츠_신고사유_조회_API:
            return .run { send in
                let reasons = try await contentClient.컨텐츠_신고사유_조회().toDomain()
                await send(.inner(.컨텐츠_신고사유_조회_API_반영(reasons)))
            }
        case let .컨텐츠_신고_API(id, reportReason):
            return .run { send in
                let request = ContentReportRequest(reportReason: reportReason)
                try await contentClient.컨텐츠_신고_사유(id, request)
                await send(
                    .inner(.링크팝업_활성화(.report(title: "신고가 완료되었습니다"))),
                    animation: .pokitSpring
                )
            }
        case .카테고리_목록_조회_API:
            return .run { send in
                let request = BasePageableRequest(page: 0, size: 30, sort: ["createdAt,desc"])
                let categoryList = try await categoryClient.카테고리_목록_조회(
                    request,
                    false,
                    true
                ).toDomain()
                await send(.inner(.카테고리_목록_조회_API_반영(categoryList)))
            }
        case let .컨텐츠_추가_API(categoryId):
            guard let content = state.domain.content else { return .none }
            return .run { [swiftSoup] send in
                let imageURL = try? await swiftSoup.parseOGImageURL(URL(string: content.data)!)
                let request = ContentBaseRequest(
                    data: content.data,
                    title: content.title,
                    categoryId: categoryId,
                    memo: content.memo,
                    alertYn: "NO",
                    thumbNail: imageURL
                )
                let _ = try await contentClient.컨텐츠_추가(request)
                await send(
                    .inner(.링크팝업_활성화(.success(title: Constants.링크_저장_완료_문구, until: 4))),
                    animation: .pokitSpring
                )
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
                    .inner(.링크팝업_활성화(.success(title: Constants.메모_수정_완료_문구))),
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

    func syncMemoState(for state: inout State) {
        state.memoTextAreaState = .memo(isReadOnly: !state.isMine)
    }
}
