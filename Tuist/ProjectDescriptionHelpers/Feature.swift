//
//  Feature.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 7/4/24.
//

import ProjectDescription
import Foundation

public enum Feature: String, CaseIterable {
    case linkDetail = "LinkDetail"
    case addLink = "AddLink"
    case categorySetting = "CategorySetting"
    case remind = "Remind"
    case login = "Login"
    case pokit = "Pokit"
    case categoryDetail = "CategoryDetail"
    case setting = "Setting"
    case linkList = "LinkList"
    
    public var target: Target {
        return .makeTarget(
            name: "Feature\(self.rawValue)",
            product: TuistRelease.isRelease ? .staticFramework : .framework,
            bundleName: "Feature.\(self.rawValue)",
            infoPlist: .file(path: .relativeToRoot("Projects/App/Resources/Pokit-info.plist")),
            dependencies: [
                .project(target: "DSKit", path: .relativeToRoot("Projects/DSKit")),
                .project(target: "Domain", path: .relativeToRoot("Projects/Domain"))
            ]
        )
    }
    
    public var demoTarget: Target {
        return .makeTarget(
            name: "Feature\(self.rawValue)Demo",
            product: .app,
            bundleName: "Feature.\(self.rawValue)Demo",
            infoPlist: .file(path: .relativeToRoot("Projects/App/Resources/Pokit-info.plist")),
            resources: ["Feature\(self.rawValue)Demo/Resources/**"],
            dependencies: [
                .target(self.target)
            ]
        )
    }
}
