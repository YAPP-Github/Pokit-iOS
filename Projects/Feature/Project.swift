//
//  Project.stencil.swift
//  Packages
//
//  Created by 김도형 on 6/16/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let targets = Feature.allCases.map { feature in
    return feature.target
}

let demoTargets = Feature.allCases.map { feature in
    return feature.demoTarget
}

let testTargets = Feature.allCases.map { feature in
    return feature.testTarget
}

let project = Project(
    name: "Feature",
    targets: targets + demoTargets + testTargets
)
