//
//  ShareRootFeature.swift
//  ShareExtension
//
//  Created by 김도형 on 10/17/24.
//

import Foundation
import UniformTypeIdentifiers

import ComposableArchitecture
import FeatureLogin
import FeatureContentSetting
import UIKit
import CoreKit
import Util

@Reducer
struct ShareRootFeature {
    @Dependency(SocialLoginClient.self)
    private var socialLogin
    
    @ObservableState
    struct State {
        var intro: IntroFeature.State? = .init()
        var contentSetting: ContentSettingFeature.State? = nil
        
        var url: URL?
        var context: NSExtensionContext?
        var controller: UIViewController?
    }
    
    enum Action {
        case intro(IntroFeature.Action)
        case contentSetting(ContentSettingFeature.Action)
        case viewDidLoad(UIViewController?, NSExtensionContext?)
        case parseURL(URL)
        case dismiss
    }
    
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .intro(.delegate(.moveToTab)):
            guard let url = state.url else { return .none }
            state.contentSetting = .init(urlText: url.absoluteString)
            state.intro = nil
            return .none
        case .intro:
            return .none
        case .contentSetting(.delegate(.저장하기_완료)):
            state.context?.completeRequest(returningItems: [])
            return .none
        case .contentSetting:
            return .none
        case let .viewDidLoad(controller, context):
            state.context = context
            state.controller = controller
            socialLogin.setRootViewController(controller)
            guard let item = context?.inputItems.first as? NSExtensionItem,
                  let itemProvider = item.attachments?.first,
                  itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) else {
                return .none
            }
            
            return .run { send in
                let urlItem = try await itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier)
                guard let url = urlItem as? URL else { return }
                await send(.parseURL(url))
            }
        case let .parseURL(url):
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
    
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
            .ifLet(\.intro, action: \.intro) { IntroFeature() }
            .ifLet(\.contentSetting, action: \.contentSetting) { ContentSettingFeature() }
            ._printChanges()
    }
}
