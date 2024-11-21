//
//  RemoteNotificationsClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 7/5/24.
//

import UIKit

import Dependencies

extension RemoteNotificationsClient: DependencyKey {
    public static let liveValue = Self(
        isRegistered: { await UIApplication.shared.isRegisteredForRemoteNotifications },
        register: { await UIApplication.shared.registerForRemoteNotifications() },
        unregister: { await UIApplication.shared.unregisterForRemoteNotifications() }
    )
}
