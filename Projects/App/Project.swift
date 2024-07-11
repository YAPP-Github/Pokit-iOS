//
//  Project.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let features: [TargetDependency] = Feature.allCases.map { feature in
        .project(target: "Feature\(feature.rawValue)", path: .relativeToRoot("Projects/Feature"))
}

let project = Project(
    name: "App",
    targets: [
        .target(
            name: "App",
            destinations: .appDestinations,
            product: .app,
            bundleId: "com.pokitmons.pokit",
            deploymentTargets: .appMinimunTarget,
            infoPlist: .file(path: .relativeToRoot("Projects/App/Resources/Pokit-info.plist")),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                // TODO: 의존성 추가
                .project(target: "FeatureHome", path: .relativeToRoot("Projects/Feature")),
                .project(target: "FeatureAddCategory", path: .relativeToRoot("Projects/Feature")),
                .project(target: "FeatureAddLink", path: .relativeToRoot("Projects/Feature")),
                .project(target: "FeatureLinkDetail", path: .relativeToRoot("Projects/Feature")),
                .project(target: "FeatureMyFolder", path: .relativeToRoot("Projects/Feature")),
                .project(target: "FeatureMyPage", path: .relativeToRoot("Projects/Feature")),
                .project(target: "FeatureLogin", path: .relativeToRoot("Projects/Feature")),
                .project(target: "FeatureRoot", path: .relativeToRoot("Projects/Feature"))
            ],
            settings: .settings
        )
    ]
)
