//
//  SwiftSoupClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Foundation

import Dependencies
import SwiftSoup

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
}
