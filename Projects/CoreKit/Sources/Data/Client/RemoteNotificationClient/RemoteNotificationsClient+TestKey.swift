//
//  RemoteNotificationsClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 7/4/24.
//

import UIKit
import Dependencies

extension DependencyValues {
  public var remoteNotifications: RemoteNotificationsClient {
    get { self[RemoteNotificationsClient.self] }
    set { self[RemoteNotificationsClient.self] = newValue }
  }
}

@available(iOSApplicationExtension, unavailable)
extension RemoteNotificationsClient: DependencyKey {
  public static let liveValue = Self(
    isRegistered: { UIApplication.shared.isRegisteredForRemoteNotifications },
    register: { UIApplication.shared.registerForRemoteNotifications() },
    unregister: { UIApplication.shared.unregisterForRemoteNotifications() }
  )
}

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
