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
        dependencies: [TargetDependency]
    ) -> Target {
        return .target(
            name: name,
            destinations: .appDestinations,
            product: product,
            bundleId: .moduleBundleId(name: bundleName),
            sources: ["\(name)/Sources/**"],
            dependencies: dependencies
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
            sources: ["Sources\(name)/Sources"],
            dependencies: dependencies
        )
    }
}
