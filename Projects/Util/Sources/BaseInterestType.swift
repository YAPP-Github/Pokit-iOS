//
//  BaseInterestType.swift
//  Util
//
//  Created by 김민호 on 1/6/25.
//

public enum BaseInterestType: String, CaseIterable {
    case `default`
    case 스포츠_레저
    case 문구_오피스
    case 패션
    case 여행
    case 경제_시사
    case 영화_드라마
    case 맛집
    case 인테리어
    case IT
    case 디자인
    case 자기계발
    case 유머
    case 음악
    case 취업정보
    
    public var title: String {
        switch self {
        case .경제_시사:  return "경제/시사"
        case .스포츠_레저: return "스포츠/레저"
        case .영화_드라마: return "영화/드라마"
        case .문구_오피스: return "문구/오피스"
            
        default: return self.rawValue
        }
    }
}

public extension String {
    var slashConvertUnderBar: String {
        return self.replacingOccurrences(of: "/", with: "_")
    }
}
