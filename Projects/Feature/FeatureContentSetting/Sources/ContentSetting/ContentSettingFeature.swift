//
//  AddLinkFeature.swift
//  Feature
//
//  Created by 김도형 on 7/17/24.

import UIKit

import ComposableArchitecture
import DSKit
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct ContentSettingFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(\.swiftSoup)
    private var swiftSoup
    @Dependency(\.pasteboard)
    private var pasteboard
    @Dependency(\.contentClient)
    private var contentClient
    @Dependency(\.categoryClient)
    private var categoryClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(
            contentId: Int? = nil,
            urlText: String? = nil
        ) {
            self.domain = .init(contentId: contentId, data: urlText)
        }
        fileprivate var domain: ContentSetting
        var urlText: String {
            get { domain.data }
            set { domain.data = newValue }
        }
        var title: String {
            get { domain.title }
            set { domain.title = newValue }
        }
        var memo: String {
            get { domain.memo }
            set { domain.memo = newValue }
        }
        var isRemind: BaseContentDetail.RemindState {
            get { domain.alertYn }
            set { domain.alertYn = newValue }
        }
        var content: BaseContentDetail? {
            get { domain.content }
        }
        var pokitList: [BaseCategoryItem]? {
            get { domain.categoryListInQuiry.data }
        }
        
        var linkTextInputState: PokitInputStyle.State = .default
        var titleTextInpuState: PokitInputStyle.State = .default
        var memoTextAreaState: PokitInputStyle.State = .default
        var selectedPokit: BaseCategoryItem? = nil
        var linkTitle: String? = nil
        var linkImageURL: String? = nil
        var showMaxCategoryPopup: Bool = false
        var showDetectedURLPopup: Bool = false
        var contentLoading: Bool = false
        var saveIsLoading: Bool = false
        var link: String?
        var showLinkPreview = false
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
            /// - Button Tapped
            case pokitSelectButtonTapped
            case pokitSelectItemButtonTapped(pokit: BaseCategoryItem)
            case contentSettingViewOnAppeared
            case saveBottomButtonTapped
            case addPokitButtonTapped
            case linkCopyButtonTapped

            case dismiss
        }

        public enum InnerAction: Equatable {
            case fetchMetadata(url: URL)
            case parsingInfo(title: String?, imageURL: String?)
            case parsingURL
            case showPopup
            case showLinkPopup(URL?)
            case updateURLText(String?)
            case 컨텐츠_갱신(content: BaseContentDetail)
            case 카테고리_갱신(category: BaseCategory)
            case 카테고리_목록_갱신(categoryList: BaseCategoryListInquiry)
            case 링크미리보기_presented
        }

        public enum AsyncAction: Equatable {
            case 컨텐츠_상세_조회(id: Int)
            case 카테고리_상세_조회(id: Int)
            case 카테고리_목록_조회
            case 컨텐츠_수정
            case 컨텐츠_추가
        }

        public enum ScopeAction: Equatable { case doNothing }

        public enum DelegateAction: Equatable {
            case 저장하기_완료
            case 포킷추가하기
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
private extension ContentSettingFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding(\.urlText):
            enum CancelID { case urlTextChanged }
            return .run { send in
                await send(.inner(.parsingURL))
            }
            /// - 1초마다 `urlText`변화의 마지막을 감지하여 이벤트 방출
            .throttle(
                id: CancelID.urlTextChanged,
                for: 1,
                scheduler: DispatchQueue.main,
                latest: true
            )
        case .binding:
            return .none
        case .pokitSelectButtonTapped:
            return .send(.async(.카테고리_목록_조회))
        case .pokitSelectItemButtonTapped(pokit: let pokit):
            state.selectedPokit = pokit
            return .none
        case .contentSettingViewOnAppeared:
            return .run { [id = state.domain.contentId] send in
                if let id {
                    await send(.async(.컨텐츠_상세_조회(id: id)))
                }
                await send(.async(.카테고리_목록_조회))
                await send(.inner(.parsingURL))
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.inner(.showLinkPopup(url)), animation: .pokitSpring)
                }
            }
        case .saveBottomButtonTapped:
            return .run { [isEdit = state.domain.categoryId != nil] send in
                if isEdit {
                    await send(.async(.컨텐츠_수정))
                } else {
                    await send(.async(.컨텐츠_추가))
                }
            }
        case .addPokitButtonTapped:
            guard state.domain.categoryTotalCount < 30 else {
                /// 🚨 Error Case [1]: 포킷 갯수가 30개 이상일 경우
                return .send(.inner(.showPopup), animation: .pokitSpring)
            }
            return .send(.delegate(.포킷추가하기))

        case .dismiss:
            return .run { _ in await dismiss() }
        case .linkCopyButtonTapped:
            return .send(.inner(.updateURLText(state.link)))
        }
    }

    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .fetchMetadata(url: let url):
            return .run { send in
                let (title, imageURL) = await swiftSoup.parseOGTitleAndImage(url) {
                    await send(.inner(.링크미리보기_presented), animation: .pokitDissolve)
                }
                await send(
                    .inner(.parsingInfo(title: title, imageURL: imageURL)),
                    animation: .pokitDissolve
                )
            }
        case let .parsingInfo(title: title, imageURL: imageURL):
            state.linkTitle = title
            state.linkImageURL = imageURL
            if let title, state.domain.title.isEmpty {
                state.domain.title = title
            }
            state.domain.thumbNail = imageURL
            return .none
        case .parsingURL:
            guard let url = URL(string: state.domain.data),
                  !state.domain.data.isEmpty else {
                /// 🚨 Error Case [1]: 올바른 링크가 아닐 때
                state.showDetectedURLPopup = false
                state.linkTitle = nil
                state.domain.title = ""
                state.linkImageURL = nil
                state.domain.thumbNail = nil
                return .none
            }
            return .send(.inner(.fetchMetadata(url: url)), animation: .pokitDissolve)
        case .showPopup:
            state.showMaxCategoryPopup = true
            return .none
        case .updateURLText(let urlText):
            state.showDetectedURLPopup = false
            state.link = nil
            guard let urlText else { return .none }
            state.domain.data = urlText
            return .send(.inner(.parsingURL))
        case .컨텐츠_갱신(content: let content):
            state.domain.content = content
            state.domain.data = content.data
            state.domain.contentId = content.id
            state.domain.title = content.title
            state.domain.categoryId = content.category.categoryId
            state.domain.memo = content.memo
            state.domain.alertYn = content.alertYn
            state.contentLoading = false
            return .run { [id = content.category.categoryId] send in
                await send(.inner(.parsingURL))
                await send(.async(.카테고리_상세_조회(id: id)))
            }
        case .카테고리_갱신(category: let category):
            state.selectedPokit = BaseCategoryItem(
                id: category.categoryId,
                userId: 0,
                categoryName: category.categoryName,
                categoryImage: category.categoryImage,
                contentCount: 0,
                createdAt: ""
            )
            return .none
        case .카테고리_목록_갱신(categoryList: let categoryList):
            /// - `카테고리_목록_조회`의 filter 옵션을 `false`로 해두었기 때문에 `미분류` 카테고리 또한 항목에서 조회가 가능함

            /// [1]. `미분류`에 해당하는 인덱스 번호와 항목을 체크, 없다면 목록갱신이 불가함
            guard let unclassifiedItemIdx = categoryList.data?.firstIndex(where: { $0.categoryName == "미분류" }) else { return .none }
            guard let unclassifiedItem = categoryList.data?.first(where: { $0.categoryName == "미분류" }) else { return .none }
            
            /// [2]. 새로운 list변수를 만들어주고 카테고리 항목 순서를 재배치 (최신순 정렬 시  미분류는 항상 맨 마지막)
            var list = categoryList
            list.data?.remove(at: unclassifiedItemIdx)
            list.data?.insert(unclassifiedItem, at: 0)
            
            /// [3]. 도메인 항목 리스트에 list 할당
            state.domain.categoryListInQuiry = list
            
            /// [4]. 선택한 카테고리는 최초 진입시 항상 `미분류`이므로 설정 추가
            state.selectedPokit = unclassifiedItem
            
            return .none
        case let .showLinkPopup(url):
            guard let url else { return .none }
            state.link = url.absoluteString
            state.showDetectedURLPopup = true
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
            state.contentLoading = true
            return .run { [id] send in
                let content = try await contentClient.컨텐츠_상세_조회("\(id)").toDomain()
                await send(.inner(.컨텐츠_갱신(content: content)))
            }
        case .카테고리_상세_조회(id: let id):
            return .run { [id] send in
                let category = try await categoryClient.카테고리_상세_조회("\(id)").toDomain()
                await send(.inner(.카테고리_갱신(category: category)))
            }
        case .카테고리_목록_조회:
            return .run { [pageable = state.domain.pageable] send in
                let categoryList = try await categoryClient.카테고리_목록_조회(
                    BasePageableRequest(
                        page: pageable.page,
                        size: 100,
                        sort: pageable.sort
                    ),
                    false
                ).toDomain()
                await send(.inner(.카테고리_목록_갱신(categoryList: categoryList)), animation: .pokitDissolve)
            }
        case .컨텐츠_수정:
            guard let contentId = state.domain.contentId else {
                return .none
            }
            guard let categoryId = state.selectedPokit?.id else {
                return .none
            }
            return .run { [
                id = contentId,
                data = state.domain.data,
                title = state.domain.title,
                categoryId = categoryId,
                memo = state.domain.memo,
                alertYn = state.domain.alertYn,
                thumbNail = state.domain.thumbNail
            ] send in
                let _ = try await contentClient.컨텐츠_수정(
                    "\(id)",
                    ContentBaseRequest(
                        data: data,
                        title: title,
                        categoryId: categoryId,
                        memo: memo,
                        alertYn: alertYn.rawValue,
                        thumbNail: thumbNail
                    )
                )
                await send(.delegate(.저장하기_완료))
            }
        case .컨텐츠_추가:
            guard let categoryId = state.selectedPokit?.id else {
                return .none
            }
            
            return .run { [
                data = state.domain.data,
                title = state.domain.title,
                categoryId = categoryId,
                memo = state.domain.memo,
                alertYn = state.domain.alertYn,
                thumbNail = state.domain.thumbNail
            ] send in
                let _ = try await contentClient.컨텐츠_추가(
                    ContentBaseRequest(
                        data: data,
                        title: title,
                        categoryId: categoryId,
                        memo: memo,
                        alertYn: alertYn.rawValue,
                        thumbNail: thumbNail
                    )
                )
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
        return .none
    }
}
