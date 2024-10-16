//
//  Project.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let developmentTeam = ProcessInfo.processInfo.environment["TUIST_DEVELOPMENT_TEAM"]

let features: [TargetDependency] = Feature.allCases.map { feature in
        .project(target: "Feature\(feature.rawValue)", path: .relativeToRoot("Projects/Feature"))
}

let shareExtensionTarget: Target = .target(
    name: "ShareExtension",
    destinations: .appDestinations,
    product: .appExtension,
    bundleId: "com.pokitmons.pokit.ShareExtension",
    deploymentTargets: .appMinimunTarget,
    infoPlist: .file(path: .relativeToRoot("Projects/App/ShareExtension/Info.plist")),
    sources: ["ShareExtension/Sources/**"],
    entitlements: .file(path: .relativeToRoot("Projects/App/ShareExtension/ShareExtension.entitlements")),
    dependencies: features,
    settings: .settings(
        .release(
            name: "Release",
            settings: [
                "CODE_SIGN_IDENTITY": "Apple Distribution"
            ],
            xcconfig: .relativeToRoot("xcconfig/Release.xcconfig")
        )
    )
)

let projectTarget: Target = .target(
    name: "App",
    destinations: .appDestinations,
    product: .app,
    bundleId: "com.pokitmons.pokit",
    deploymentTargets: .appMinimunTarget,
    infoPlist: .file(path: .relativeToRoot("Projects/App/Resources/Pokit-info.plist")),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    entitlements: .file(path: .relativeToRoot("Projects/App/Resources/Pokit-iOS.entitlements")),
    dependencies: features + [
        // TODO: 의존성 추가
        .external(name: "FirebaseMessaging"),
        .target(shareExtensionTarget)
    ],
    settings: .settings(
        .release(
            name: "Release",
            settings: [
                "CODE_SIGN_IDENTITY": "Apple Distribution"
            ],
            xcconfig: .relativeToRoot("xcconfig/Release.xcconfig")
        )
    )
)

let project = Project(
    name: "App",
    options: .options(
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko"
    ),
    targets: [
        projectTarget,
        shareExtensionTarget
    ]
)
