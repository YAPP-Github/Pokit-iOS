//
//  DeviceClient.swift
//  CoreKit
//
//  Created by 김도형 on 10/25/24.
//

import Foundation
import DependenciesMacros

@DependencyClient
public struct DeviceClient: Sendable {
    public var isPhone: @Sendable () -> Bool = { false }
    public var isPad: @Sendable () -> Bool = { false }
    public var isMac: @Sendable () -> Bool = { false }
}
