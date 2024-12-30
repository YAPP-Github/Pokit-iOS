//
//  Version.swift
//  Domain
//
//  Created by 김민호 on 12/30/24.
//

import Foundation

public struct Version: Comparable {
    let major: Int
    let minor: Int
    let patch: Int
    public let trackId: Int

    public init(_ version: String, trackId: Int) {
        let components = version.split(separator: ".").compactMap { Int($0) }
        self.major = components.count > 0 ? components[0] : 0
        self.minor = components.count > 1 ? components[1] : 0
        self.patch = components.count > 2 ? components[2] : 0
        self.trackId = trackId
    }

    public static func < (
        lhs: Version,
        rhs: Version
    ) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        return lhs.minor < rhs.minor
    }

    public static func == (
        lhs: Version,
        rhs: Version
    ) -> Bool {
        return lhs.major == rhs.major && 
               lhs.minor == rhs.minor
    }
    
}
