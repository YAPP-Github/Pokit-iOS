//
//  Feature.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 7/4/24.
//

import ProjectDescription
import Foundation

public enum Feature: String, CaseIterable {
    case contentDetail = "ContentDetail"
    case contentSetting = "ContentSetting"
    case categorySetting = "CategorySetting"
    case remind = "Remind"
    case login = "Login"
    case pokit = "Pokit"
    case categoryDetail = "CategoryDetail"
    case setting = "Setting"
    case contentList = "ContentList"
    case categorySharing = "CategorySharing"
    case contentCard = "ContentCard"
    
    public var target: Target {
        return .makeTarget(
            name: "Feature\(self.rawValue)",
            product: TuistRelease.isRelease ? .staticFramework : .framework,
            bundleName: "Feature.\(self.rawValue)",
            infoPlist: .file(path: .relativeToRoot("Projects/App/Resources/Pokit-info.plist")),
            dependencies: self.depenecies + [
                .project(target: "DSKit", path: .relativeToRoot("Projects/DSKit")),
                .project(target: "Domain", path: .relativeToRoot("Projects/Domain"))
            ]
        )
    }
    
    public var demoTarget: Target {
        return .makeTarget(
            name: "Feature\(self.rawValue)Demo",
            product: .app,
            bundleName: "Feature.\(self.rawValue)Demo",
            infoPlist: .file(path: .relativeToRoot("Projects/App/Resources/Pokit-info.plist")),
            resources: ["Feature\(self.rawValue)Demo/Resources/**"],
            dependencies: [
                .target(self.target)
            ]
        )
    }
    
    public var testTarget: Target {
        return .makeTarget(
            name: "Feature\(self.rawValue)Tests",
            product: .unitTests,
            bundleName: "Feature.\(self.rawValue)Tests",
            infoPlist: .dictionary(["ENABLE_TESTING_SEARCH_PATHS": "YES"]),
            resources: ["Feature\(self.rawValue)Tests/Resources/**"],
            dependencies: [
                .target(self.target)
            ]
        )
    }
    
    public var depenecies: [TargetDependency] {
        switch self {
        case .contentDetail: return []
        case .contentSetting: return []
        case .categorySetting: return []
        case .remind: return []
        case .login: return []
        case .pokit:
            return [
                .project(target: "FeatureContentCard", path: .relativeToRoot("Projects/Feature"))
            ]
        case .categoryDetail:
            return [
                .project(target: "FeatureContentCard", path: .relativeToRoot("Projects/Feature"))
            ]
        case .setting:
            return [
                .project(target: "FeatureContentCard", path: .relativeToRoot("Projects/Feature"))
            ]
        case .contentList:
            return [
                .project(target: "FeatureContentCard", path: .relativeToRoot("Projects/Feature"))
            ]
        case .categorySharing:
            return [
                .project(target: "FeatureContentCard", path: .relativeToRoot("Projects/Feature"))
            ]
        case .contentCard: return []
        }
    }
}
