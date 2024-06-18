//
//  app.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
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
            path: "Projects/\(appProjectAttribute)/\(appTargetAttribute)/Sources/\(appTargetAttribute)App.swift",
            templatePath: "App.stencil"),
    ]
)
