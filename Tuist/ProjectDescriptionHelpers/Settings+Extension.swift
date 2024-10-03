//
//  Settings+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 7/13/24.
//

import ProjectDescription

public extension Settings {
    static func settings(_ release: Configuration? = nil) -> Settings {
        var settings: Settings = .settings(
            base: [
                "OTHER_LDFLAGS": "$(inherited) -ObjC",
                "CODE_SIGN_STYLE": "Manual"
            ],
            configurations: [
                .debug(name: "Debug", xcconfig: .relativeToRoot("xcconfig/Debug.xcconfig"))
            ]
        )
        
        if let release {
            settings.configurations.append(release)
        }
        
        return settings
    }
}
