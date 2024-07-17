//
//  PreviewLinkFeature.swift
//  Feature
//
//  Created by 김도형 on 7/17/24.

import Foundation
import LinkPresentation
import UniformTypeIdentifiers

import ComposableArchitecture
import Util

@Reducer
public struct PreviewLinkFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(url urlText: String) {
            self.urlText = urlText
        }
        var title: String? = nil
        var image: UIImage? = nil
        var urlText: String
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum View: Equatable {
            case previewLinkOnAppeared
        }
        
        public enum InnerAction: Equatable {
            case fetchMetadata(url: URL)
            case parsingInfo(title: String?, image: UIImage?)
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable { case doNothing }
        
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
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension PreviewLinkFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .previewLinkOnAppeared:
            guard let url = URL(string: state.urlText) else { return .none }
            return .send(.inner(.fetchMetadata(url: url)))
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .fetchMetadata(url: let url):
            return .run { send in
                let provider = LPMetadataProvider()
                let metadata = try? await provider.startFetchingMetadata(for: url)
                let title = metadata?.title
                var image: UIImage?
                let item = try? await metadata?.imageProvider?.loadItem(forTypeIdentifier: String(describing: UTType.image))
                if item is UIImage {
                    image = item as? UIImage
                }
                
                if item is URL {
                    guard let url = item as? URL,
                          let data = try? Data(contentsOf: url) else { return }
                    
                    image = UIImage(data: data)
                }
                
                if item is Data {
                    guard let data = item as? Data else { return }
                    
                    image = UIImage(data: data)
                }
                
                await send(.inner(.parsingInfo(title: title, image: image)))
            }
        case .parsingInfo(title: let title, image: let image):
            state.title = title
            state.image = image
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
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
