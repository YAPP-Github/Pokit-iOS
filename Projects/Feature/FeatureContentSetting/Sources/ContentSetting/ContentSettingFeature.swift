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
    @Dependency(SwiftSoupClient.self)
    private var swiftSoup
    @Dependency(PasteboardClient.self)
    private var pasteboard
    @Dependency(ContentClient.self)
    private var contentClient
    @Dependency(CategoryClient.self)
    private var categoryClient
    @Dependency(KeyboardClient.self)
    private var keyboardClient
    @Dependency(\.amplitude.track)
    private var amplitudeTrack
    
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(
            contentId: Int? = nil,
            urlText: String? = nil,
            isShareExtension: Bool = false
        ) {
            self.domain = .init(contentId: contentId, data: urlText)
            self.isShareExtension = isShareExtension
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
        var content: BaseContentDetail? {
            get { domain.content }
        }
        var pokitList: [BaseCategoryItem]? {
            get { domain.categoryListInQuiry.data }
        }
        
        var linkTextInputState: PokitInputStyle.State = .default
        var titleTextInpuState: PokitInputStyle.State = .default
        var memoTextAreaState: PokitInputStyle.State = .default
        @Shared(.inMemory("SelectCategory")) var categoryId: Int?
        var selectedPokit: BaseCategoryItem?
        var linkTitle: String? = nil
        var linkImageURL: String? = nil
        var linkPopup: PokitLinkPopup.PopupType?
        var contentLoading: Bool = false
        var saveIsLoading: Bool = false
        var link: String?
        var showLinkPreview = false
        var isShareExtension: Bool
        var pokitAddSheetPresented: Bool = false
        var isKeyboardVisible: Bool = false
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
            case 포킷선택_버튼_눌렀을때
            case 포킷선택_항목_눌렀을때(pokit: BaseCategoryItem)
            case 뷰가_나타났을때
            case 저장_버튼_눌렀을때
            case 포킷추가_버튼_눌렀을때
            case 링크팝업_버튼_눌렀을때
            case 링크지우기_버튼_눌렀을때
            case 제목지우기_버튼_눌렀을때
            case 뒤로가기_버튼_눌렀을때
        }

        public enum InnerAction {
            case linkPopup(URL?)
            case linkPreview
            case 메타데이터_조회_수행(url: URL)
            case 메타데이텨_조회_반영(title: String?, imageURL: String?)
            case URL_유효성_확인
            case 링크복사_반영(String?)
            case 컨텐츠_상세_조회_API_반영(content: BaseContentDetail)
            case 카테고리_목록_조회_API_반영(categoryList: BaseCategoryListInquiry)
            case 선택한_포킷_인메모리_삭제
            case 링크팝업_활성화(PokitLinkPopup.PopupType)
            case error(Error)
            case 키보드_감지_반영(Bool)
            case 선택_카테고리_반영(BaseCategoryItem?)
        }

        public enum AsyncAction: Equatable {
            case 컨텐츠_상세_조회_API(id: Int)
            case 카테고리_목록_조회_API
            case 컨텐츠_수정_API
            case 컨텐츠_추가_API
            case 클립보드_감지
            case 키보드_감지
        }

        public enum ScopeAction: Equatable { case 없음 }

        public enum DelegateAction: Equatable {
            case 저장하기_완료(category: BaseCategoryItem)
            case 포킷추가하기
            case dismiss
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
            return .send(.inner(.URL_유효성_확인)).debounce(
                /// - 1초마다 `urlText`변화의 마지막을 감지하여 이벤트 방출
                id: CancelID.urlTextChanged,
                for: 1,
                scheduler: DispatchQueue.main
            )
        case .binding:
            return .none
        case .포킷선택_버튼_눌렀을때:
            return .send(.async(.카테고리_목록_조회_API))
        case .포킷선택_항목_눌렀을때(pokit: let pokit):
            state.selectedPokit = pokit
            return .none
        case .뷰가_나타났을때:
            var mergeEffect: [Effect<Action>] = [
                .send(.async(.카테고리_목록_조회_API)),
                .send(.inner(.URL_유효성_확인)),
                .send(.async(.클립보드_감지)),
                .send(.async(.키보드_감지))
            ]
            if let id = state.domain.contentId {
                mergeEffect.append(.send(.async(.컨텐츠_상세_조회_API(id: id))))
            }
            return .merge(mergeEffect)
        case .저장_버튼_눌렀을때:
            let isEdit = state.domain.categoryId != nil
            if state.domain.title == Constants.제목을_입력해주세요_문구 {
                state.domain.title = state.title
            }
            state.saveIsLoading = true
            
            return isEdit
            ? .send(.async(.컨텐츠_수정_API))
            : .send(.async(.컨텐츠_추가_API))
        case .포킷추가_버튼_눌렀을때:
            guard state.domain.categoryTotalCount < 30 else {
                /// 🚨 Error Case [1]: 포킷 갯수가 30개 이상일 경우
                state.linkPopup = .text(title: Constants.포킷_최대_갯수_문구)
                return .none
            }
            /// 바텀시트 내리고 `포킷추가하기` depth 추가
            state.pokitAddSheetPresented = false
            return .send(.delegate(.포킷추가하기))
        case .뒤로가기_버튼_눌렀을때:
            state.categoryId = nil
            return state.isShareExtension
            ? .send(.delegate(.dismiss))
            : .run { _ in await dismiss() }
        case .링크팝업_버튼_눌렀을때:
            guard case .link = state.linkPopup else { return .none }
            return .send(.inner(.링크복사_반영(state.link)))
        case .링크지우기_버튼_눌렀을때:
            state.domain.data = ""
            state.domain.title = ""
            return .none
        case .제목지우기_버튼_눌렀을때:
            state.domain.title = ""
            return .none
        }
    }

    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .linkPopup(url):
            guard let url else { return .none }
            state.link = url.absoluteString
            state.linkPopup = .link(
                title: Constants.복사한_링크_저장하기_문구,
                url: url.absoluteString
            )
            return .none
        case .linkPreview:
            state.showLinkPreview = true
            return .none
        case .메타데이터_조회_수행(url: let url):
            return .run { send in
                async let title = try? swiftSoup.parseOGTitle(url)
                async let imageURL = try? swiftSoup.parseOGImageURL(url)
                await send(
                    .inner(.메타데이텨_조회_반영(title: title, imageURL: imageURL)),
                    animation: .pokitDissolve
                )
            }
        case let .메타데이텨_조회_반영(title: title, imageURL: imageURL):
            let contentTitle = state.title.isEmpty
            ? Constants.제목을_입력해주세요_문구
            : state.title
            state.linkImageURL = imageURL ?? Constants.기본_썸네일_주소.absoluteString
            state.linkTitle = title ?? contentTitle
            if let title, state.domain.title.isEmpty {
                state.domain.title = title
            }
            state.domain.thumbNail = imageURL
            return .send(.inner(.linkPreview), animation: .pokitDissolve)
        case .URL_유효성_확인:
            guard
                let url = URL(string: state.domain.data),
                !state.domain.data.isEmpty
            else {
                /// 🚨 Error Case [1]: 올바른 링크가 아닐 때
                state.linkPopup = nil
                state.linkTitle = nil
                state.domain.title = ""
                state.linkImageURL = nil
                state.domain.thumbNail = nil
                return .none
            }
            return .send(.inner(.메타데이터_조회_수행(url: url)), animation: .pokitDissolve)
        case .링크복사_반영(let urlText):
            state.linkPopup = nil
            state.link = nil
            guard let urlText else { return .none }
            state.domain.data = urlText
            return .send(.inner(.URL_유효성_확인))
        case .컨텐츠_상세_조회_API_반영(content: let content):
            state.domain.content = content
            state.domain.data = content.data
            state.domain.contentId = content.id
            state.domain.title = content.title
            state.domain.categoryId = content.category.categoryId
            state.domain.memo = content.memo
            state.domain.alertYn = content.alertYn
            state.contentLoading = false
            return .send(.inner(.URL_유효성_확인))
        case .카테고리_목록_조회_API_반영(categoryList: let categoryList):
            /// [3]. 도메인 항목 리스트에 list 할당
            state.domain.categoryListInQuiry = categoryList
            
            /// [4]. 최초 진입시: `미분류`로 설정함. 포킷 추가하고 왔다면 `@Shared`에 값이 있기 때문에 기존 값을 업데이트함
            if state.selectedPokit == nil {
                state.selectedPokit = categoryList.data?.first
            }
            return .run { [
                id = state.domain.categoryId,
                sharedId = state.categoryId
            ] send in
                let selectedCategory = categoryList.data?.first { category in
                    return category.id == id || category.id == sharedId
                }
                await send(.inner(.선택_카테고리_반영(selectedCategory)))
            }
        case .선택한_포킷_인메모리_삭제:
            state.selectedPokit = nil
            return .none
        case let .링크팝업_활성화(type):
            state.linkPopup = type
            state.saveIsLoading = false
            return .none
        case let .error(error):
            guard let errorResponse = error as? ErrorResponse else { return .none }
            return .send(
                .inner(.링크팝업_활성화(.error(title: errorResponse.message))),
                animation: .pokitSpring
            )
        case let .키보드_감지_반영(response):
            state.isKeyboardVisible = response
            return .none
        case let .선택_카테고리_반영(selectedCategory):
            state.selectedPokit = selectedCategory
            return .none
        }
    }

    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_상세_조회_API(id: let id):
            state.contentLoading = true
            return .run { send in
                let content = try await contentClient.컨텐츠_상세_조회("\(id)").toDomain()
                await send(.inner(.컨텐츠_상세_조회_API_반영(content: content)), animation: .pokitDissolve)
            }
        case .카테고리_목록_조회_API:
            let request = BasePageableRequest(
                page: state.domain.pageable.page,
                size: 30,
                sort: state.domain.pageable.sort
            )
            return categoryListFetch(request: request)
        case .컨텐츠_수정_API:
            guard
                let contentId = state.domain.contentId,
                let categoryId = state.selectedPokit?.id,
                let category = state.domain.categoryListInQuiry.data?.first(where: {
                    $0.id == categoryId
                })
            else { return .none }
            let request = ContentBaseRequest(
                data: state.domain.data,
                title: state.domain.title,
                categoryId: categoryId,
                memo: state.domain.memo,
                alertYn: state.domain.alertYn.rawValue,
                thumbNail: state.domain.thumbNail
            )
            return .run { send in
                let _ = try await contentClient.컨텐츠_수정(
                    "\(contentId)",
                    request
                )
                await send(.inner(.선택한_포킷_인메모리_삭제))
                await send(.delegate(.저장하기_완료(category: category)))
            } catch: { error, send in
                await send(.inner(.error(error)))
            }
        case .컨텐츠_추가_API:
            guard
                let categoryId = state.selectedPokit?.id,
                let category = state.domain.categoryListInQuiry.data?.first(where: {
                    $0.id == categoryId
                })
            else { return .none }
            let request = ContentBaseRequest(
                data: state.domain.data,
                title: state.domain.title,
                categoryId: categoryId,
                memo: state.domain.memo,
                alertYn: state.domain.alertYn.rawValue,
                thumbNail: state.domain.thumbNail
            )
            return .run { send in
                let response = try await contentClient.컨텐츠_추가(request)
                amplitudeTrack(.add_link(
                    folderId: "\(response.contentId)",
                    linkDomain: response.data
                ))
                await send(.inner(.선택한_포킷_인메모리_삭제))
                await send(.delegate(.저장하기_완료(category: category)))
            } catch: { error, send in
                await send(.inner(.error(error)))
            }
        case .클립보드_감지:
            return .run { send in
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.inner(.linkPopup(url)), animation: .pokitSpring)
                }
            }
        
        case .키보드_감지:
            return .run { send in
                for await detect in await keyboardClient.isVisible() {
                    await send(.inner(.키보드_감지_반영(detect)), animation: .pokitSpring)
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
    
    func categoryListFetch(request: BasePageableRequest) -> Effect<Action> {
        return .run { send in
            let categoryList = try await categoryClient.카테고리_목록_조회(request, false, true).toDomain()
            /// - `카테고리_목록_조회`의 filter 옵션을 `false`로 해두었기 때문에 `미분류` 카테고리 또한 항목에서 조회가 가능함

            /// [1]. `미분류`에 해당하는 인덱스 번호와 항목을 체크, 없다면 목록갱신이 불가함
            guard let unclassifiedItemIdx = categoryList.data?.firstIndex(where: {
                    $0.categoryName == Constants.미분류
                })
            else { return }
            guard let unclassifiedItem = categoryList.data?.first(where: {
                    $0.categoryName == Constants.미분류
                })
            else { return }
            
            /// [2]. 새로운 list변수를 만들어주고 카테고리 항목 순서를 재배치 (최신순 정렬 시  미분류는 항상 맨 마지막)
            var list = categoryList
            list.data?.remove(at: unclassifiedItemIdx)
            list.data?.insert(unclassifiedItem, at: 0)
            
            await send(.inner(.카테고리_목록_조회_API_반영(categoryList: list)), animation: .pokitDissolve)
        }
    }
}
