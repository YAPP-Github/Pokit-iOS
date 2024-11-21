//
//  UserDefaultsClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Foundation

import Dependencies

extension UserDefaultsClient: TestDependencyKey {
    public static var testValue = Self()
}
