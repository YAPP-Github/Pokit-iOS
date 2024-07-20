//
//  Settings+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 7/13/24.
//

import ProjectDescription

public extension Settings {
    static var settings: Settings {
        return .settings(
            base: ["OTHER_LDFLAGS": "$(inherited) -ObjC"]
        )
    }
}
