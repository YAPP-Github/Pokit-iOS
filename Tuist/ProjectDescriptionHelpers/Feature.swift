//
//  Feature.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 7/4/24.
//

import ProjectDescription

public enum Feature: String, CaseIterable {
    case myPage = "MyPage"
    case myFolder = "MyFolder"
    case linkDetail = "LinkDetail"
    case addLink = "AddLink"
    case addCategory = "AddCategory"
    case home = "Home"
    
    public var target: Target {
        return .makeTarget(
            name: "Feature\(self.rawValue)",
            product: .framework,
            bundleName: "Feature.\(self.rawValue)",
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
            dependencies: [
                .target(self.target)
            ]
        )
    }
}
