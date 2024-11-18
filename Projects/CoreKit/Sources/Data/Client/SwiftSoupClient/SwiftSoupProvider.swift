//
//  SwiftSoupProvider.swift
//  CoreKit
//
//  Created by 김도형 on 11/17/24.
//

import SwiftUI
import SwiftSoup

final class SwiftSoupProvider {
    func parseOGTitle(_ url: URL) async throws -> String? {
        try await parseOGMeta(url: url, type: "og:title")
    }
    
    func parseOGImageURL(_ url: URL) async throws -> String? {
        try await parseOGMeta(url: url, type: "og:image")
    }
    
    func parseOGMeta(url: URL, type: String) async throws -> String? {
        let html = try String(contentsOf: url)
        let document = try SwiftSoup.parse(html)
        
        if let metaData = try document.select("meta[property=\(type)]").first()?.attr("content") {
            return metaData
        } else {
            var request = URLRequest(url: url)
            request.setValue(
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36",
                forHTTPHeaderField: "User-Agent"
            )
            
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let html = String(data: data, encoding: .utf8) else {
                return nil
            }
            let document = try SwiftSoup.parse(html)
            let metaData = try document.select("meta[property=\(type)]").first()?.attr("content")
            
            return metaData
        }
    }
}
