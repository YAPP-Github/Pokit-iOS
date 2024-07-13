//
//  Settings+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 7/13/24.
//

import ProjectDescription

public extension Settings {
    static var settings: Settings {
        let base = SettingsDictionary().otherLinkerFlags(["-ObjC"])
        
        return .settings(base: base, configurations: [.debug(name: .debug), .release(name: .release)])
    }
}
