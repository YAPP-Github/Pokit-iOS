//
//  UserDefaultsKey.swift
//  Data
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

public enum UserDefaultsKey {
    public enum BoolKey: String {
        case autoSaveSearch
        /// - 배너를 클릭해서 들어왔을 때
        case fromBanner
    }
    public enum StringKey: String {
        /// `구글` or `애플`
        case authPlatform
        case authCode
        case jwt
        case fcmToken
        case userId
    }
    public enum ArrayKey: String {
        case searchWords
    }
}
