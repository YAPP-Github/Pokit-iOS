//
//  CoreKit.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 7/4/24.
//

import ProjectDescription

public enum CoreKit: String, CaseIterable {
    case core = "Core"
    case coreNetwork = "CoreNetwork"
    case coreLinkPresentation = "CoreLinkPresentation"
    case data = "Data"
    
    private var dependencies: [TargetDependency] {
        switch self {
        case .core :
            return [
                .project(target: "Util", path: .relativeToRoot("Projects/Util")),
                .project(target: "SharedThirdPartyLib", path: .relativeToRoot("Projects/SharedThirdPartyLib"))
            ]
        case .coreNetwork:
            return [
                .project(target: "Util", path: .relativeToRoot("Projects/Util")),
                .project(target: "SharedThirdPartyLib", path: .relativeToRoot("Projects/SharedThirdPartyLib")),
                .external(name: "Moya")
            ]
        case .coreLinkPresentation:
            return [
                .project(target: "Util", path: .relativeToRoot("Projects/Util")),
                .project(target: "SharedThirdPartyLib", path: .relativeToRoot("Projects/SharedThirdPartyLib"))
            ]
        case .data:
            return [
                .external(name: "GoogleSignInSwift"),
                .project(target: "Core", path: .relativeToRoot("Projects/CoreKit"))
            ]
        }
    }
    
    public var target: Target {
        .makeChildTarget(
            name: "\(self.rawValue)",
            product: TuistRelease.isRelease ? .staticFramework : .framework,
            bundleName: "CoreKit.\(self.rawValue)",
            dependencies: self.dependencies
        )
    }
}
