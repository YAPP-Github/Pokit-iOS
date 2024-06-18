//
//  target.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import ProjectDescription

let frameworkProjectAttribute: Template.Attribute = .required("project")
let frameworkTargetAttribute: Template.Attribute = .required("target")

let frameworkTemplate = Template(
    description: "Target template",
    attributes: [
        frameworkProjectAttribute,
        frameworkTargetAttribute
    ],
    items: [
        .file(
            path: "Projects/\(frameworkProjectAttribute)/\(frameworkTargetAttribute)/Sources/Source.swift",
            templatePath: "Dummy.stencil"),
        .file(
            path: "Projects/\(frameworkProjectAttribute)/\(frameworkTargetAttribute)/Resources/Resource.swift",
            templatePath: "Dummy.stencil")
    ]
)
