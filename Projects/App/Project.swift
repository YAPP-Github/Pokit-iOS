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
            entitlements: .file(path: .relativeToRoot("Projects/App/Resources/Pokit-iOS.entitlements")),
            dependencies: features + [
                // TODO: 의존성 추가
                .external(name: "FirebaseMessaging")
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": "$(inherited) -ObjC",
                    "CODE_SIGN_IDENTITY": "Apple Distribution",
                    "PROVISIONING_PROFILE_SPECIFIER": "match AppStore com.pokitmons.pokit 1721720816",
                    "PROVISIONING_PROFILE": "match AppStore com.pokitmons.pokit 1721720816",
                    "DEVELOPMENT_TEAM": "\(developmentTeam ?? "")"
                ]
            )
        )
    ]
)
