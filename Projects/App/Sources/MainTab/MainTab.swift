//
//  MainTab.swift
//  App
//
//  Created by 김민호 on 7/11/24.
//

import Foundation

import DSKit

public enum MainTab: String, CaseIterable {
    case pokit = "포킷"
    case recommend = "링크추천"
    
    var title: String { return self.rawValue }
    
    var icon: PokitImage {
        switch self {
        case .pokit:  return .icon(.folderFill)
        case .recommend: return .icon(.remind)
        }
    }
}
