//
//  AddLinkFeature.swift
//  Feature
//
//  Created by 김도형 on 7/17/24.

import UIKit

import ComposableArchitecture
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct ContentSettingFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(\.linkPresentation)
    private var linkPresentation
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
        var isRemind: ContentDetail.Content.RemindState {
            get { domain.alertYn }
            set { domain.alertYn = newValue }
        }
        var content: ContentDetail.Content? {
            get { domain.content }
        }
        var pokitList: [BaseCategory] {
            get { domain.categoryListInQuiry.data }
        }
        var selectedPokit: BaseCategory? = nil
        var linkTitle: String? = nil
        var linkImage: UIImage? = nil
        var showPopup: Bool = false
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
            case pokitSelectItemButtonTapped(pokit: BaseCategory)
            case contentSettingViewOnAppeared
            case saveBottomButtonTapped
            case addPokitButtonTapped

            case dismiss
        }

        public enum InnerAction: Equatable {
            case fetchMetadata(url: URL)
            case parsingInfo(title: String?, image: UIImage?)
            case parsingURL
            case showPopup
            case updateURLText(String?)
            case 컨텐츠_갱신(content: ContentDetail.Content)
            case 카테고리_갱신(category: BaseCategoryDetail)
            case 카테고리_목록_갱신(categoryList: BaseCategoryListInquiry)
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
                    await send(.inner(.updateURLText(url?.absoluteString)))
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
        }
    }

    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .fetchMetadata(url: let url):
            return .run { send in
                /// - 링크에 대한 메타데이터의 제목 및 썸네일 항목 파싱
                let (title, item) = await linkPresentation.provideMetadata(url)
                /// - 썸네일을 `UIImage`로 변환
                let image = linkPresentation.convertImage(item)
                await send(
                    .inner(.parsingInfo(title: title, image: image)),
                    animation: .smooth
                )
            }
        case .parsingInfo(title: let title, image: let image):
            state.linkTitle = title
            state.linkImage = image
            return .none
        case .parsingURL:
            guard let url = URL(string: state.domain.data) else {
                /// 🚨 Error Case [1]: 올바른 링크가 아닐 때
                state.linkTitle = nil
                state.linkImage = nil
                return .none
            }
            return .send(.inner(.fetchMetadata(url: url)), animation: .smooth)
        case .showPopup:
            state.showPopup = true
            return .none
        case .updateURLText(let urlText):
            guard let urlText else { return .none }
            state.domain.data = urlText
            return .send(.inner(.parsingURL))
        case .컨텐츠_갱신(content: let content):
            state.domain.content = content
            state.domain.data = content.data
            state.domain.contentId = content.id
            state.domain.title = content.title
            state.domain.categoryId = content.categoryId
            state.domain.memo = content.memo
            state.domain.alertYn = content.alertYn
            return .run { [id = content.categoryId] send in
                await send(.inner(.parsingURL))
                await send(.async(.카테고리_상세_조회(id: id)))
            }
        case .카테고리_갱신(category: let category):
            state.selectedPokit = .init(
                id: category.categoryId,
                userId: 0,
                categoryName: category.categoryName,
                categoryImage: category.categoryImage,
                contentCount: 0
            )
            return .none
        case .카테고리_목록_갱신(categoryList: let categoryList):
            state.domain.categoryListInQuiry = categoryList
            return .none
        }
    }

    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_상세_조회(id: let id):
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
                    .init(
                        page: pageable.page,
                        size: pageable.size,
                        sort: pageable.sort
                    ),
                    true
                ).toDomain()
                await send(.inner(.카테고리_목록_갱신(categoryList: categoryList)))
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
                alertYn = state.domain.alertYn
            ] send in
                let _ = try await contentClient.컨텐츠_수정(
                    "\(id)",
                    ContentBaseRequest(
                        data: data,
                        title: title,
                        categoryId: categoryId,
                        memo: memo,
                        alertYn: alertYn.rawValue
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
                alertYn = state.domain.alertYn
            ] send in
                let _ = try await contentClient.컨텐츠_추가(
                    ContentBaseRequest(
                        data: data,
                        title: title,
                        categoryId: categoryId,
                        memo: memo,
                        alertYn: alertYn.rawValue
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
