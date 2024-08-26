//
//  Project.stencil.swift
//  Packages
//
//  Created by 김도형 on 6/16/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

//let targets = CoreKit.allCases.map { core in
//    return core.target
//}

//let coreKitDependencies: [TargetDependency] = targets.map { target in
//    return .target(target)
//}

let coreKit: Target = .target(
    name: "CoreKit",
    destinations: .appDestinations,
    // TODO: 프로젝트에 맞는 product로 변경해야 함
    product: TuistRelease.isRelease ? .staticFramework : .framework,
    bundleId: .moduleBundleId(name: "CoreKit"),
    deploymentTargets: .appMinimunTarget,
    infoPlist: .file(path: .relativeToRoot("Projects/App/Resources/Pokit-info.plist")),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    dependencies: [
        .project(target: "Util", path: .relativeToRoot("Projects/Util")),
        .project(target: "SharedThirdPartyLib", path: .relativeToRoot("Projects/SharedThirdPartyLib")),
        .external(name: "Moya"),
        .external(name: "GoogleSignIn"),
        .external(name: "SwiftJWT"),
        .external(name: "SwiftSoup"),
        .external(name: "KakaoSDKCommon"),
        .external(name: "KakaoSDKShare"),
        .external(name: "KakaoSDKTemplate"),
    ],
    settings: .settings(
        base: [
            "OTHER_LDFLAGS": "$(inherited) -ObjC",
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: .relativeToRoot("xcconfig/Secret.xcconfig")),
            .release(name: "Release", xcconfig: .relativeToRoot("xcconfig/Secret.xcconfig"))
        ]
    )
)

let project = Project(
    name: "CoreKit",
    settings: .settings,
    targets: [coreKit]
)
