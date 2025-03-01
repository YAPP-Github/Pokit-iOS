//
//  BaseInterest.swift
//  Domain
//
//  Created by 김도형 on 1/29/25.
//

import Foundation

public struct BaseInterest: Equatable, Identifiable, Hashable {
    public let id = UUID()
    public let code: Code
    public let description: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
    
    public static func ==(lhs: BaseInterest, rhs: BaseInterest) -> Bool {
        lhs.code == rhs.code
    }
    
    public init(code: Code, description: String) {
        self.code = code
        self.description = description
    }
}

extension BaseInterest {
    public enum Code: String {
        case `default` = "DEFAULT"
        case 스포츠_레저 = "SPORTS"
        case 문구_오피스 = "OFFICE"
        case 패션 = "FASHION"
        case 여행 = "TRAVEL"
        case 경제_시사 = "ECONOMY"
        case 영화_드라마 = "MOVIE_DRAMA"
        case 맛집 = "RESTAURANT"
        case 인테리어 = "INTERIOR"
        case IT = "IT"
        case 디자인 = "DESIGN"
        case 자기계발 = "SELF_IMPROVEMENT"
        case 유머 = "HUMOR"
        case 음악 = "MUSIC"
        case 취업정보 = "JOB_INFO"
    }
}
