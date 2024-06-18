//
//  Project.stencil.swift
//  Packages
//
//  Created by 김도형 on 6/16/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

//MARK: - Mypage
let mypageTarget: Target = .makeTarget(
    name: "FeatureMyPage",
    product: .framework,
    bundleName: "Feature.MyPage",
    dependencies: [
        .project(target: "DSKit", path: .relativeToRoot("Projects/DSkit")),
        .project(target: "Domain", path: .relativeToRoot("Projects/Domain"))
    ]
)

let mypageDemoTarget: Target = .makeTarget(
    name: "FeatureMyPageDemo",
    product: .app,
    bundleName: "Feature.MyPageDemo",
    dependencies: [
        .target(mypageTarget)
    ]
)
//MARK: - MyFolder
let myFolderTarget: Target = .makeTarget(
    name: "FeatureMyFolder",
    product: .framework,
    bundleName: "Feature.MyFolder",
    dependencies: [
        .project(target: "DSKit", path: .relativeToRoot("Projects/DSkit")),
        .project(target: "Domain", path: .relativeToRoot("Projects/Domain"))
    ]
)

let myFolderDemoTarget: Target = .makeTarget(
    name: "FeatureMyFolderDemo",
    product: .app,
    bundleName: "Feature.MyFolderDemo",
    dependencies: [
        .target(myFolderTarget)
    ]
)
//MARK: - Link Detail
let linkDetailTarget: Target = .makeTarget(
    name: "FeatureLinkDetail",
    product: .framework,
    bundleName: "Feature.LinkDetail",
    dependencies: [
        .project(target: "DSKit", path: .relativeToRoot("Projects/DSkit")),
        .project(target: "Domain", path: .relativeToRoot("Projects/Domain"))
    ]
)

let linkDetailDemoTarget: Target = .makeTarget(
    name: "FeatureLinkDetailDemo",
    product: .app,
    bundleName: "Feature.LinkDetailDemo",
    dependencies: [
        .target(linkDetailTarget)
    ]
)

//MARK: - AddLink
let addLinkTarget: Target = .makeTarget(
    name: "FeatureAddLink",
    product: .framework,
    bundleName: "Feature.AddLink",
    dependencies: [
        .project(target: "DSKit", path: .relativeToRoot("Projects/DSkit")),
        .project(target: "Domain", path: .relativeToRoot("Projects/Domain"))
    ]
)

let addLinkDemoTarget: Target = .makeTarget(
    name: "FeatureAddLinkDemo",
    product: .app,
    bundleName: "Feature.AddLinkDemo",
    dependencies: [
        .target(addLinkTarget)
    ]
)
//MARK: - Add Category
let addCategoryTarget: Target = .makeTarget(
    name: "FeatureAddCategory",
    product: .framework,
    bundleName: "Feature.AddCategory",
    dependencies: [
        .project(target: "DSKit", path: .relativeToRoot("Projects/DSkit")),
        .project(target: "Domain", path: .relativeToRoot("Projects/Domain"))
    ]
)

let addCategoryDemoTarget: Target = .makeTarget(
    name: "FeatureAddCategoryDemo",
    product: .app,
    bundleName: "Feature.AddCategoryDemo",
    dependencies: [
        .target(addCategoryTarget)
    ]
)
//MARK: - Home
let homeTarget: Target = .makeTarget(
    name: "FeatureHome",
    product: .framework,
    bundleName: "Feature.Home",
    dependencies: [
        .project(target: "DSKit", path: .relativeToRoot("Projects/DSkit")),
        .project(target: "Domain", path: .relativeToRoot("Projects/Domain"))
    ]
)

let homeDemoTarget: Target = .makeTarget(
    name: "FeatureHomeDemo",
    product: .app,
    bundleName: "Feature.HomeDemo",
    dependencies: [
        .target(homeTarget)
    ]
)

let project = Project(
    name: "Feature",
    targets: [
        homeTarget,
        homeDemoTarget,
        addLinkTarget,
        addLinkDemoTarget,
        addCategoryTarget,
        addCategoryDemoTarget,
        linkDetailTarget,
        linkDetailDemoTarget,
        mypageTarget,
        mypageDemoTarget,
        myFolderTarget,
        myFolderDemoTarget
    ]
)
