//
//  KeywordSelectType.swift
//  Feature
//
//  Created by 김민호 on 1/23/25.
//
import SwiftUI

import DSKit

public enum KeywordSelectType: Equatable {
    case normal
    case select(keywordName: String)
    case warnning
    
    var fontColor: Color {
        switch self {
        case .normal, .select:
            return .pokit(.text(.tertiary))
        case .warnning:
            return .pokit(.text(.error))
        }
    }
    
    var label: String {
        switch self {
        case .normal:
            return "추천을 위해 포킷 키워드를 선택해 주세요."
            
        case let .select(keywordName):
            return "#\(keywordName)"
            
        case .warnning:
            return "포킷 키워드를 선택해 주세요."
        }
    }
}
