//
//  BaseInterestType.swift
//  Util
//
//  Created by 김민호 on 1/6/25.
//

public enum BaseInterestType: String, CaseIterable {
    case `default`
    case 스포츠_레저
    case 기획_마케팅
    case 쇼핑
    case 여행
    case 경제_시사
    case 영화_드라마
    case 장소
    case 인테리어
    case IT
    case 디자인
    case 자기계발
    case 유머
    case 음악
    case 독서
    case 취업정보
    case 요리_레시피
    case 반려동물
    
    public var title: String {
        switch self {
        case .스포츠_레저: return "스포츠/레저"
        case .기획_마케팅: return "기획/마케팅"
        case .경제_시사:  return "경제/시사"
        case .영화_드라마: return "영화/드라마"
        case .요리_레시피: return "요리/레시피"
            
        default: return self.rawValue
        }
    }
}

public extension String {
    var slashConvertUnderBar: String {
        return self.replacingOccurrences(of: "/", with: "_")
    }
}
