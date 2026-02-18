//
//  DeeplinkRouteClient.swift
//  CoreKit
//
//  Created by 김도형 on 2/17/26.
//

import Foundation

import DependenciesMacros

@DependencyClient
public struct DeeplinkRouteClient: Sendable {
    public var routeTo: @Sendable (URL?) async -> Void = { _ in }
    public var routeStream: @Sendable () -> AsyncStream<DeeplinkRoute> = { .finished }
}
