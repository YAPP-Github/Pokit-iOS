//
//  PokitCategorySettingType.swift
//  FeatureCategorySetting
//
//  Created by 김민호 on 7/25/24.
//

import Foundation

public enum SettingType {
    case 추가
    case 수정
    
    var title: String {
        switch self {
        case .추가: return "포킷 추가"
        case .수정: return "포킷 수정"
        }
    }
}
