//
//  library.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import ProjectDescription

let libraryParentAttribute: Template.Attribute = .required("parent")
let libraryChildAttribute: Template.Attribute = .required("child")

let libraryTemplate = Template(
    description: "Target template",
    attributes: [
        libraryParentAttribute,
        libraryChildAttribute
    ],
    items: [
        .file(
            path: "Projects/\(libraryParentAttribute)/Sources/\(libraryChildAttribute)/Source.swift",
            templatePath: "Dummy.stencil")
    ]
)
