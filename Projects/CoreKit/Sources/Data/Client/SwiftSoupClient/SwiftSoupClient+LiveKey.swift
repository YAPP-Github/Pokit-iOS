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
        let provider = SwiftSoupProvider()
        
        return Self(
            parseOGTitle: { url in
                try await provider.parseOGTitle(url)
            },
            parseOGImageURL: { url in
                try await provider.parseOGImageURL(url)
            }
        )
    }()
}
