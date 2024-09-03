//
//  Project.stencil.swift
//  Packages
//
//  Created by 김도형 on 6/16/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Util",
    targets: [
        .target(
            name: "Util",
            destinations: .appDestinations,
            // TODO: 프로젝트에 맞는 product로 변경해야 함
            product: TuistRelease.isRelease ? .staticFramework : .framework,
            bundleId: .moduleBundleId(name: "Util"),
            deploymentTargets: .appMinimunTarget,
            infoPlist: .file(path: .relativeToRoot("Projects/App/Resources/Pokit-info.plist")),
            sources: ["Sources/**"],
            dependencies: [
                // TODO: 의존성 추가
            ]
        )
    ]
)
