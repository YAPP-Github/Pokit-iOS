//
//  UserDefaults.swift
//  Data
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

import Dependencies

extension DependencyValues {
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

public struct UserDefaultsClient {
    public var boolKey: @Sendable (UserDefaultsKey.BoolKey) -> Bool = { _ in false }
    public var stringKey: @Sendable (UserDefaultsKey.StringKey) -> String? = { _ in "" }
    public var removeBool: @Sendable (UserDefaultsKey.BoolKey) async -> Void
    public var removeString: @Sendable (UserDefaultsKey.StringKey) async -> Void
    public var setBool: @Sendable (Bool, UserDefaultsKey.BoolKey) async -> Void
    public var setString: @Sendable (String, UserDefaultsKey.StringKey) async -> Void
}

extension UserDefaultsClient: DependencyKey {
    public static var liveValue: Self = {
        let defaults = { UserDefaults.standard }
        
        return Self(
            boolKey: { defaults().bool(forKey: $0.rawValue) },
            stringKey: { defaults().string(forKey: $0.rawValue) },
            
            removeBool: { defaults().removeObject(forKey: $0.rawValue) },
            removeString: { defaults().removeObject(forKey: $0.rawValue) },
            
            setBool: { defaults().set($0, forKey: $1.rawValue) },
            setString: { defaults().set($0, forKey: $1.rawValue) }
        )
    }()
    
    public static let testValue: Self = {
        Self(
            removeBool: { _ in },
            removeString: { _ in },
            setBool: { _, _ in },
            setString: { _, _ in }
        )
    }()
}
