//
//  project.swift
//  Manifests
//
//  Created by 김도형 on 6/16/24.
//

import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let projectTemplate = Template(
    description: "Project template",
    attributes: [
        nameAttribute
    ],
    items: [
        .file(
            path: "Projects/\(nameAttribute)/Project.swift",
            templatePath: "Project.stencil"
        ),
        .file(
            path: "Projects/\(nameAttribute)/Sources/Source.swift",
            templatePath: "Dummy.stencil"),
        .file(
            path: "Projects/\(nameAttribute)/Resources/Resource.swift",
            templatePath: "Dummy.stencil"),
    ]
)
