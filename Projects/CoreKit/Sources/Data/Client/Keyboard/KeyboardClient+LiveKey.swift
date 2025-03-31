//
//  KeyboardClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 3/31/25.
//

import UIKit
import Combine
import Dependencies

extension KeyboardClient: DependencyKey {
    public static let liveValue: Self = {
        .init(
            isVisible: {
                AsyncStream { continuation in
                    let notificationCenter = NotificationCenter.default
                    
                    let showObserver = notificationCenter
                        .publisher(for: UIResponder.keyboardWillShowNotification)
                        .map { _ in true }
                    
                    let hideObserver = notificationCenter
                        .publisher(for: UIResponder.keyboardWillHideNotification)
                        .map { _ in false }
                    
                    let cancellable = Publishers.Merge(showObserver, hideObserver)
                        .removeDuplicates()
                        .sink { isVisible in
                            continuation.yield(isVisible)
                        }
                    
                    continuation.onTermination = { _ in cancellable.cancel() }
                }
            }
        )
    }()
}

