//
//  ShareRootFeature.swift
//  ShareExtension
//
//  Created by 김도형 on 10/17/24.
//

import UIKit
import UniformTypeIdentifiers

import ComposableArchitecture
import FeatureLogin
import FeatureContentSetting
import FeatureCategorySetting
import CoreKit
import Util
import Social

@Reducer
struct ShareRootFeature {
    @Dependency(SocialLoginClient.self)
    private var socialLogin
    
    @ObservableState
    struct State {
        var intro: IntroFeature.State? = .init()
        var contentSetting: ContentSettingFeature.State? = nil
        var path = StackState<Path.State>()
        
        var url: URL?
        var context: NSExtensionContext?
        var controller: SLComposeServiceViewController?
    }
    
    enum Action {
        case intro(IntroFeature.Action)
        case contentSetting(ContentSettingFeature.Action)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case controller(ControllerAction)
        case path(StackActionOf<Path>)
        
        enum InnerAction {
            case dismiss
            case URL_파싱_수행_반영(URL?)
        }
        enum AsyncAction {
            case URL_파싱_수행
        }
        enum ScopeAction {
            case intro(IntroFeature.Action)
            case contentSetting(ContentSettingFeature.Action)
            case categorySetting(PokitCategorySettingFeature.Action)
        }
        enum ControllerAction {
            case viewDidLoad(SLComposeServiceViewController?, NSExtensionContext?)
            case viewDidAppear
            case presentationControllerDidDismiss
        }
    }
    
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .intro(let introAction):
            return .send(.scope(.intro(introAction)))
        case .contentSetting(let contentSettingAction):
            return .send(.scope(.contentSetting(contentSettingAction)))
            /// - Inner
        case .inner(let innerAction):
            return handleInnerAction(innerAction, state: &state)
            /// - Async
        case .async(let asyncAction):
            return handleAsyncAction(asyncAction, state: &state)
            /// - Scope
        case .scope(let scopeAction):
            return handleScopeAction(scopeAction, state: &state)
            /// - Controller
        case .controller(let controllerAction):
            return handleControllerAction(controllerAction, state: &state)
            /// - Path
        case .path(let pathAction):
            return handlePathAction(pathAction, state: &state)
        }
    }
    
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .URL_파싱_수행_반영(url):
            state.url = url
            return .none
        case .dismiss:
            state.controller?.dismiss(animated: true) { [context = state.context] in
                let error =  NSError(
                    domain: "com.pokitmons.pokit.ShareExtension",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "User cancelled the action."]
                )
                context?.cancelRequest(withError: error)
            }
            return .none
        }
    }
    
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .URL_파싱_수행:
            guard let item = state.context?.inputItems.first as? NSExtensionItem,
                  let itemProvider = item.attachments?.first else {
                return .none
            }
            
            return .run { send in
                var urlItem: (any NSSecureCoding)? = nil
                
                if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    urlItem = try await itemProvider.loadItem(
                        forTypeIdentifier: UTType.url.identifier
                    )
                    let url = urlItem as? URL
                    await send(.inner(.URL_파싱_수행_반영(url)))
                    
                } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    urlItem = try await itemProvider.loadItem(
                        forTypeIdentifier: UTType.plainText.identifier
                    )
                    guard let urlString = urlItem as? String else { return }
                    await send(.inner(.URL_파싱_수행_반영(URL(string: urlString))))
                }
            }
        }
    }
    
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        case .intro(.delegate(.moveToTab)):
            state.contentSetting = .init(
                urlText: state.url?.absoluteString,
                isShareExtension: true
            )
            state.intro = nil
            return .none
        case .intro:
            return .none
        case .contentSetting(.delegate(.저장하기_완료)):
            state.controller?.dismiss(animated: true) { [context = state.context] in
                context?.completeRequest(returningItems: [])
            }
            return .none
        case .contentSetting(.delegate(.dismiss)):
            return .send(.inner(.dismiss))
        case .contentSetting(.delegate(.포킷추가하기)):
            state.path.append(.categorySetting(PokitCategorySettingFeature.State(type: .추가)))
            return .none
        case .contentSetting:
            return .none
        case .categorySetting(.delegate(.settingSuccess)):
            state.path.removeLast()
            return .none
        case .categorySetting:
            return .none
        }
    }
    
    func handleControllerAction(_ action: Action.ControllerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .viewDidLoad(controller, context):
            state.context = context
            state.controller = controller
            socialLogin.setRootViewController(controller)
            return .send(.async(.URL_파싱_수행))
        case .viewDidAppear:
            state.controller?.textView.resignFirstResponder()
            return .none
        case .presentationControllerDidDismiss:
            let error =  NSError(
                domain: "com.pokitmons.pokit.ShareExtension",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User cancelled the action."]
            )
            state.context?.cancelRequest(withError: error)
            return .none
        }
    }
    
    func handlePathAction(_ action: StackActionOf<Path>, state: inout State) -> Effect<Action> {
        switch action {
        case let .element(id: _, action: .categorySetting(categorySettingAction)):
            return .send(.scope(.categorySetting(categorySettingAction)))
        case .element, .popFrom, .push:
            return .none
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
            .ifLet(\.intro, action: \.intro) { IntroFeature() }
            .ifLet(\.contentSetting, action: \.contentSetting) { ContentSettingFeature() }
            .forEach(\.path, action: \.path)
            ._printChanges()
    }
}

extension ShareRootFeature {
    @Reducer
    enum Path {
        case categorySetting(PokitCategorySettingFeature)
    }
}
