//
//  UserNotificationClient.swift
//  CoreKit
//
//  Created by 김민호 on 7/4/24.
//

import Dependencies

extension UserNotificationClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension UserNotificationClient {
    public static let noop = Self(
        add: { _ in },
        delegate: { AsyncStream { _ in } },
        getNotificationSettings: { Notification.Settings(authorizationStatus: .notDetermined) },
        removeDeliveredNotificationsWithIdentifiers: { _ in },
        removePendingNotificationRequestsWithIdentifiers: { _ in },
        requestAuthorization: { _ in false }
    )
}


