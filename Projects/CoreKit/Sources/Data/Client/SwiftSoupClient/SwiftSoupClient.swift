//
//  SwiftSoupClient.swift
//  CoreKit
//
//  Created by 김도형 on 7/19/24.
//

import Foundation

import SwiftSoup
import Dependencies

public struct SwiftSoupClient {
    public var parseOGTitleAndImage: @Sendable (
        _ url: URL,
        _ completion: @Sendable () async -> Void
    ) async -> (String?, String?)
}

extension SwiftSoupClient: DependencyKey {
    public static let liveValue: Self = {
        return Self(
            parseOGTitleAndImage: { url, completion in
                guard let html = try? String(contentsOf: url),
                      let document = try? SwiftSoup.parse(html) else {
                    await completion()
                    return (nil, nil)
                }
                
                let title = try? document.select("meta[property=og:title]").first()?.attr("content")
                let imageURL = try? document.select("meta[property=og:image]").first()?.attr("content")
                
                guard title != nil || imageURL != nil else {
                    var request = URLRequest(url: url)
                    request.setValue(
                        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36",
                        forHTTPHeaderField: "User-Agent"
                    )
                    
                    guard let data = try? await URLSession.shared.data(for: request).0,
                          let html = String(data: data, encoding: .utf8),
                          let document = try? SwiftSoup.parse(html) else {
                        return (nil, nil)
                    }
                    
                    let title = try? document.select("meta[property=og:title]").first()?.attr("content")
                    let imageURL = try? document.select("meta[property=og:image]").first()?.attr("content")
                    
                    await completion()
                    
                    return (title, imageURL)
                }
                
                await completion()
                
                return (title, imageURL)
            }
        )
    }()
    
    public static let previewValue: Self = liveValue
}

public extension DependencyValues {
    var swiftSoup: SwiftSoupClient {
        get { self[SwiftSoupClient.self] }
        set { self[SwiftSoupClient.self] = newValue }
    }
}
