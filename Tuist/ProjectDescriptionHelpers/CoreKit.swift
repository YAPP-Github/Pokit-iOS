//
//  CoreKit.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 7/4/24.
//

import ProjectDescription

public enum CoreKit: String, CaseIterable {
    case core = "Core"
    case data = "Data"
    case network = "Network"
    
    private var dependencies: [TargetDependency] {
        switch self {
        case .core :
            return [
                .project(target: "Util", path: .relativeToRoot("Projects/Util"))
            ]
        case .data:
            return [
                .project(target: "Util", path: .relativeToRoot("Projects/Util")),
                .project(target: "ThirdPartyLib", path: .relativeToRoot("Projects/ThirdPartyLib"))
            ]
        case .network:
            return [
                .project(target: "Util", path: .relativeToRoot("Projects/Util")),
                .project(target: "ThirdPartyLib", path: .relativeToRoot("Projects/ThirdPartyLib"))
            ]
        }
    }
    
    public var target: Target {
        .makeChildTarget(
            name: "\(self.rawValue)",
            product: .staticLibrary,
            bundleName: "CoreKit.\(self.rawValue)",
            dependencies: self.dependencies
        )
    }
}
