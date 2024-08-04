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
public struct AddLinkFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(\.linkPresentation)
    private var linkPresentation
    @Dependency(\.pasteboard)
    private var pasteboard
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(link: BaseContent? = nil) {
            self.domain = .init(content: link)
        }
        fileprivate var domain: AddLink
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
        var isRemind: BaseContent.RemindState {
            get { domain.alertYn }
            set { domain.alertYn = newValue }
        }
        var link: BaseContent? {
            get { domain.content }
        }
        var pokitList: IdentifiedArrayOf<BaseCategory> {
            var identifiedArray = IdentifiedArrayOf<BaseCategory>()
            domain.categoryListInQuiry.data.forEach { category in
                identifiedArray.append(category)
            }
            return identifiedArray
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
            case addLinkViewOnAppeared
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
        }

        public enum AsyncAction: Equatable {
            case 저장하기_네트워크
        }

        public enum ScopeAction: Equatable { case doNothing }

        public enum DelegateAction: Equatable {
            case 저장하기_네트워크이후
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
private extension AddLinkFeature {
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
            return .none
        case .pokitSelectItemButtonTapped(pokit: let pokit):
            state.selectedPokit = pokit
            return .none
        case .addLinkViewOnAppeared:
            return .run { send in
                await send(.inner(.parsingURL))
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.inner(.updateURLText(url?.absoluteString)))
                }
            }
        case .saveBottomButtonTapped:
            return .run { send in await send(.async(.저장하기_네트워크)) }
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
        }
    }

    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .저장하기_네트워크:
            //TODO: 저장하기 네트워크 코드작성
            return .run { send in await send(.delegate(.저장하기_네트워크이후)) }
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
