//
//  library.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import ProjectDescription

let libraryProjectAttribute: Template.Attribute = .required("project")
let libraryTargetAttribute: Template.Attribute = .required("target")

let libraryTemplate = Template(
    description: "Target template",
    attributes: [
        libraryProjectAttribute,
        libraryTargetAttribute
    ],
    items: [
        .file(
            path: "Projects/\(libraryProjectAttribute)/\(libraryTargetAttribute)/Sources/Source.swift",
            templatePath: "Dummy.stencil")
    ]
)
