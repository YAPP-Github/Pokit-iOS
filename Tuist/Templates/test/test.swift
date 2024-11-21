//
//  test.swift
//  ProjectDescriptionHelpers
//
//  Created by 김민호 on 10/10/24.
//

import ProjectDescription

let appProjectAttribute: Template.Attribute = .required("project")
let appTargetAttribute: Template.Attribute = .required("target")

let appTemplate = Template(
    description: "Target template",
    attributes: [
        appProjectAttribute,
        appTargetAttribute
    ],
    items: [
        .file(
            path: "Projects/\(appProjectAttribute)/\(appTargetAttribute)Tests/Sources/\(appTargetAttribute)Tests.swift",
            templatePath: "Test.stencil"),
        .file(
            path: "Projects/\(appProjectAttribute)/\(appTargetAttribute)Tests/Resources/info.plist",
            templatePath: "InfoPlist.stencil"),
    ]
)
