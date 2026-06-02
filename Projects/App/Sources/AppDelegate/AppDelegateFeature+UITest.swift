//
//  AppDelegateFeature+UITest.swift
//  App
//
//  Created by Codex on 3/22/26.
//

#if DEBUG
import Foundation

import ComposableArchitecture
import CoreKit

extension AppDelegateFeature {
    func handleDidFinishLaunchingForUITest() -> Effect<Action>? {
        let config = UITestLaunchConfig.current
        guard config.isEnabled else { return nil }

        return .run { send in
            if config.shouldRunDeeplinkScenario, config.routeBeforeMainTab {
                await self.routeUITestDeeplinks(config.deeplinkURLs)
            }

            if config.shouldForceMainTab {
                await send(.root(._sceneChange(.mainTab())))
            }

            if config.shouldRunDeeplinkScenario, !config.routeBeforeMainTab {
                await self.routeUITestDeeplinks(config.deeplinkURLs)
            }
        }
    }

    private func routeUITestDeeplinks(_ deeplinkURLs: [URL]) async {
        guard !deeplinkURLs.isEmpty else { return }
        for deeplinkURL in deeplinkURLs {
            await self.deeplinkRouter.routeTo(deeplinkURL)
        }
    }
}
#endif
