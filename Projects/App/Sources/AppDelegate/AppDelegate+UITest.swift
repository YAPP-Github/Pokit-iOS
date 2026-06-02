//
//  AppDelegate+UITest.swift
//  App
//
//  Created by Codex on 2026-03-22.
//

#if DEBUG
import Foundation

import ComposableArchitecture
import CoreKit
import Dependencies

extension AppDelegate {
    static var shouldSkipLaunchAnalytics: Bool {
        UITestLaunchConfig.current.isEnabled
    }

    static func makeUITestStore() -> StoreOf<AppDelegateFeature> {
        Store(initialState: AppDelegateFeature.State()) {
            AppDelegateFeature()
        } withDependencies: {
            $0.applyAppMainTabDeeplinkTestDependencies()
        }
    }
}

struct UITestLaunchConfig: Sendable {
    enum Scenario: String, Sendable {
        case deeplink
    }

    static let modeKey = "UITEST_MODE"
    static let scenarioKey = "UITEST_SCENARIO"
    static let forceMainTabKey = "UITEST_FORCE_MAIN_TAB"
    static let routeBeforeMainTabKey = "UITEST_ROUTE_BEFORE_MAIN_TAB"
    static let deeplinksJSONKey = "UITEST_DEEPLINKS_JSON"

    let isEnabled: Bool
    let scenario: Scenario?
    let shouldForceMainTab: Bool
    let routeBeforeMainTab: Bool
    let deeplinkURLs: [URL]

    static let current = UITestLaunchConfig(environment: ProcessInfo.processInfo.environment)

    init(environment: [String: String]) {
        self.isEnabled = Self.boolValue(for: Self.modeKey, in: environment)
        self.scenario = environment[Self.scenarioKey].flatMap(Scenario.init(rawValue:))
        self.shouldForceMainTab = Self.boolValue(for: Self.forceMainTabKey, in: environment)
        self.routeBeforeMainTab = Self.boolValue(for: Self.routeBeforeMainTabKey, in: environment)
        self.deeplinkURLs = Self.parseDeeplinkURLs(environment[Self.deeplinksJSONKey])
    }

    var shouldRunDeeplinkScenario: Bool {
        self.isEnabled && self.scenario == .deeplink && !self.deeplinkURLs.isEmpty
    }

    private static func boolValue(for key: String, in environment: [String: String]) -> Bool {
        guard let value = environment[key]?.lowercased() else {
            return false
        }

        switch value {
        case "1", "true", "yes", "y":
            return true
        default:
            return false
        }
    }

    private static func parseDeeplinkURLs(_ rawValue: String?) -> [URL] {
        guard let rawValue, !rawValue.isEmpty else {
            return []
        }

        if
            let data = rawValue.data(using: .utf8),
            let urls = try? JSONDecoder().decode([String].self, from: data)
        {
            return urls.compactMap(URL.init(string:)).filter { $0.scheme?.isEmpty == false }
        }

        if
            let url = URL(string: rawValue),
            url.scheme?.isEmpty == false
        {
            return [url]
        }

        return []
    }
}
#endif
