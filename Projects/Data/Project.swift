//
//  Project.stencil.swift
//  Packages
//
//  Created by 김도형 on 6/16/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Data",
    targets: [
        .target(
            name: "Data",
            destinations: .appDestinations,
            // TODO: 프로젝트에 맞는 product로 변경해야 함
            product: .staticFramework,
            bundleId: .moduleBundleId(name: "Data"),
            deploymentTargets: .appMinimunTarget,
            infoPlist: .file(path: .relativeToRoot("Projects/App/Resources/Pokit-info.plist")),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                // TODO: 의존성 추가
                .project(target: "CoreKit", path: .relativeToRoot("Projects/CoreKit")),
                .project(target: "Domain", path: .relativeToRoot("Projects/Domain")),
                .external(name: "FirebaseMessaging")
            ],
            settings: .settings
        )
    ]
)
