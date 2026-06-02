//
//  DeeplinkRouteClient+TestKey.swift
//  CoreKit
//
//  Created by 김도형 on 2/17/26.
//

import Foundation

import Dependencies

extension DeeplinkRouteClient: TestDependencyKey {
    public static let previewValue: Self = .noop
    public static let testValue: Self = .noop
}

public extension DeeplinkRouteClient {
    static let noop: Self = .init(
        routeTo: { _ in },
        routeStream: { .finished }
    )
}
