//
//  RemoteNotificationsClient.swift
//  CoreKit
//
//  Created by 김민호 on 7/5/24.
//

import DependenciesMacros

@DependencyClient
public struct RemoteNotificationsClient {
  public var isRegistered: @Sendable () async -> Bool = { false }
  public var register: @Sendable () async -> Void
  public var unregister: @Sendable () async -> Void
}
