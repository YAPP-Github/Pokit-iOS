//
//  PastboardClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 8/2/24.
//

import UIKit
import Combine
import ConcurrencyExtras

extension PasteboardClient {
    public static let live: Self = {
        .init(
            changes: { UIPasteboard.general.changes },
            probableWebURL: { () -> URL? in
                do {
                    let pasteboard = UIPasteboard.general
                    
                    guard pasteboard.hasURLs else { return nil }
                    
                    let detectedPatterns = try await pasteboard
                        .detectedPatterns(for: [\.probableWebURL])
                    
                    guard detectedPatterns.contains(\.probableWebURL) else { return nil }
                    
                    return pasteboard.url
                } catch { throw error }
            }
        )
    }()
}

extension UIPasteboard {
    var changes: AsyncStream<Void> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIPasteboard.changedNotification)
                .compactMap { [weak self] _ in self?.changeCount },
            NotificationCenter.default
                .publisher(for: UIApplication.didBecomeActiveNotification)
                .compactMap { [weak self] _ in self?.changeCount }
        )
        .removeDuplicates()
        .map { _ in }
        .values
        .eraseToStream()
    }
}

