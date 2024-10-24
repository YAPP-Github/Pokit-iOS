//
//  DeploymentTarget+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/12/24.
//

import ProjectDescription

public extension DeploymentTargets {
    static let appMinimunTarget: DeploymentTargets = .multiplatform(iOS: "16.0", macOS: "13.0")
}
