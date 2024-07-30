//
//  UserDefaultsKey.swift
//  Data
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

public enum UserDefaultsKey {
    enum BoolKey: String {
        case doNothing
    }
    enum StringKey: String {
        /// `구글` or `애플`
        case authPlatform
    }
}
