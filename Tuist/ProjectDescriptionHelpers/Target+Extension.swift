//
//  Target+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/18/24.
//

import ProjectDescription

public extension Target {
    static func makeTarget(
        name: String,
        product: Product,
        bundleName: String,
        infoPlist: InfoPlist? = nil,
        resources: ResourceFileElements? = nil,
        dependencies: [TargetDependency]
    ) -> Target {
        return .target(
            name: name,
            destinations: .appDestinations,
            product: product,
            bundleId: .moduleBundleId(name: bundleName),
            deploymentTargets: .appMinimunTarget,
            infoPlist: infoPlist,
            sources: ["\(name)/Sources/**"],
            resources: resources,
            dependencies: dependencies,
            settings: .settings()
        )
    }
    
    static func makeChildTarget(
        name: String,
        product: Product,
        bundleName: String,
        dependencies: [TargetDependency]
    ) -> Target {
        return .target(
            name: "\(name)",
            destinations: .appDestinations,
            product: product,
            bundleId: .moduleBundleId(name: bundleName),
            deploymentTargets: .appMinimunTarget,
            sources: ["Sources/\(name)/Sources/**"],
            dependencies: dependencies,
            settings: .settings()
        )
    }
}
