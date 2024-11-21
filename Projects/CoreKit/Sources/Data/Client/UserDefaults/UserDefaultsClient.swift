//
//  UserDefaultsClient.swift
//  CoreKit
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

import DependenciesMacros

@DependencyClient
public struct UserDefaultsClient {
    public var boolKey: @Sendable (UserDefaultsKey.BoolKey) -> Bool = { _ in false }
    public var stringKey: @Sendable (UserDefaultsKey.StringKey) -> String? = { _ in "" }
    public var stringArrayKey: @Sendable (UserDefaultsKey.ArrayKey) -> [String]? = { _ in [] }
    public var removeBool: @Sendable (UserDefaultsKey.BoolKey) async -> Void
    public var removeString: @Sendable (UserDefaultsKey.StringKey) async -> Void
    public var removeStringArray: @Sendable (UserDefaultsKey.ArrayKey) async -> Void
    public var setBool: @Sendable (Bool, UserDefaultsKey.BoolKey) async -> Void
    public var setString: @Sendable (String, UserDefaultsKey.StringKey) async -> Void
    public var setStringArray: @Sendable ([String], UserDefaultsKey.ArrayKey) async -> Void
}
