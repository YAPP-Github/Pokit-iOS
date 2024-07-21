//
//  AddLinkFeature.swift
//  Feature
//
//  Created by 김도형 on 7/17/24.

import UIKit

import ComposableArchitecture
import CoreLinkPresentation
import Util

@Reducer
public struct AddLinkFeature {
    /// - Dependency
    @Dependency(\.linkPresentation) private var linkPresentation
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(link: AddLinkMock? = nil) {
            let pokitList = PokitMock.addLinkMock
            self.pokitList = pokitList
            self.selectedPokit = link?.pokit ?? .init(categoryType: "미분류", contentSize: 15)
            self.link = link
            self.urlText = link?.urlText ?? ""
            self.title = link?.title ?? ""
            self.memo = link?.memo ?? ""
            self.isRemind = link?.isRemind ?? false
        }
        
        var urlText: String
        var title: String
        var memo: String
        var isRemind: Bool
        var pokitList: [PokitMock]
        var selectedPokit: PokitMock
        var link: AddLinkMock?
        var linkTitle: String? = nil
        var linkImage: UIImage? = nil
        @Presents var addPokitSheet: AddPokitSheetFeature.State?
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case addPokitSheet(PresentationAction<AddPokitSheetFeature.Action>)
        
        @CasePathable
        public enum View: Equatable, BindableAction {
            case binding(BindingAction<State>)
            case pokitSelectButtonTapped
            case pokitSelectItemButtonTapped(pokit: PokitMock)
            case addLinkViewOnAppeared
            case saveBottomButtonTapped
            case addPokitButtonTapped
        }
        
        public enum InnerAction: Equatable {
            case fetchMetadata(url: URL)
            case parsingInfo(title: String?, image: UIImage?)
            case parsingURL
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable {
            case addPokitSheet(AddPokitSheetFeature.Action.DelegateAction)
        }
        
        public enum DelegateAction: Equatable { case doNothing }
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
        case .addPokitSheet(.presented(.delegate(let delegate))):
            return .send(.scope(.addPokitSheet(delegate)))
        case .addPokitSheet:
            return .none
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
            .ifLet(\.$addPokitSheet, action: \.addPokitSheet) {
                AddPokitSheetFeature()
            }
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
            return .send(.inner(.parsingURL))
        case .saveBottomButtonTapped:
            state.link = .init(
                title: state.title,
                urlText: state.urlText,
                createAt: .now,
                memo: state.memo,
                isRemind: state.isRemind,
                pokit: state.selectedPokit
            )
            return .none
        case .addPokitButtonTapped:
            state.addPokitSheet = AddPokitSheetFeature.State()
            return .none
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .fetchMetadata(url: let url):
            return .run { send in
                let (title, item) = await linkPresentation.provideMetadata(url)
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
            guard let url = URL(string: state.urlText) else {
                state.linkTitle = nil
                state.linkImage = nil
                return .none
            }
            return .send(.inner(.fetchMetadata(url: url)), animation: .smooth)
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        case .addPokitSheet(.addPokit(pokit: let pokit)):
            state.pokitList.append(pokit)
            return .none
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
