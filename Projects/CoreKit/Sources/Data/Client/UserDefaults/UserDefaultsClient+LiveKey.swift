//
//  UserDefaultsClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Foundation

import Dependencies

extension UserDefaultsClient: DependencyKey {
    public static var liveValue: Self = {
        let defaults = { UserDefaults(suiteName: "group.com.pokitmons.pokit") }
        
        return Self(
            boolKey: { defaults()?.bool(forKey: $0.rawValue) ?? false },
            stringKey: { defaults()?.string(forKey: $0.rawValue) },
            stringArrayKey: { defaults()?.stringArray(forKey: $0.rawValue) },
            
            removeBool: { defaults()?.removeObject(forKey: $0.rawValue) },
            removeString: { defaults()?.removeObject(forKey: $0.rawValue) },
            removeStringArray: { defaults()?.removeObject(forKey: $0.rawValue) },
            
            setBool: { defaults()?.set($0, forKey: $1.rawValue) },
            setString: { defaults()?.set($0, forKey: $1.rawValue) },
            setStringArray: { defaults()?.set($0, forKey: $1.rawValue) }
        )
    }()
}
