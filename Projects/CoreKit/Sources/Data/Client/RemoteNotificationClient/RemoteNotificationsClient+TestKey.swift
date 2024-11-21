//
//  RemoteNotificationsClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 7/4/24.
//

import UIKit
import Dependencies

extension RemoteNotificationsClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension RemoteNotificationsClient {
    public static let noop = Self(
        isRegistered: { true },
        register: {},
        unregister: {}
    )
}
