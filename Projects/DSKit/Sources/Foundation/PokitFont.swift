//
//  PokitFont.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

public enum PokitFont {
    case title1
    case title2
    case title3
    case b1(Self.Weight)
    case b2(Self.Weight)
    case b3(Self.Weight)
    case detail1
    case detail2
    case l1(Self.Weight)
    case l2(Self.Weight)
    case l3(Self.Weight)
    case l4
    
    private var convertible: DSKitFontConvertible {
        let pretendard = DSKitFontFamily.Pretendard.self
        
        switch self {
        case .title1:
            return pretendard.bold
        case .title2:
            return pretendard.bold
        case .title3:
            return pretendard.medium
        case .b1(let weight):
            switch weight {
            case .b:
                return pretendard.semiBold
            case .m:
                return pretendard.medium
            case .r:
                return pretendard.regular
            }
        case .b2(let weight):
            switch weight {
            case .b:
                return pretendard.semiBold
            case .m:
                return pretendard.medium
            case .r:
                return pretendard.regular
            }
        case .b3(let weight):
            switch weight {
            case .b:
                return pretendard.semiBold
            case .m:
                return pretendard.medium
            case .r:
                return pretendard.regular
            }
        case .detail1:
            return pretendard.medium
        case .detail2:
            return pretendard.regular
        case .l1(let weight):
            switch weight {
            case .b:
                return pretendard.semiBold
            case .m:
                return pretendard.medium
            case .r:
                return pretendard.regular
            }
        case .l2(let weight):
            switch weight {
            case .b:
                return pretendard.semiBold
            case .m:
                return pretendard.medium
            case .r:
                return pretendard.regular
            }
        case .l3(let weight):
            switch weight {
            case .b:
                return pretendard.semiBold
            case .m:
                return pretendard.medium
            case .r:
                return pretendard.regular
            }
        case .l4:
            return pretendard.medium
        }
    }
    
    var uiFont: UIFont {
        return self.convertible.font(size: self.size)
    }
    
    var swiftUIFont: Font {
        return self.convertible.swiftUIFont(size: self.size)
    }
    
    var height: CGFloat {
        switch self {
        case .title1:
            return 32
        case .title2:
            return 28
        case .title3:
            return 24
        case .b1:
            return 24
        case .b2:
            return 20
        case .b3(let weight):
            switch weight {
            case .b, .m:
                return 18
            case .r:
                return 24
            }
        case .detail1:
            return 20
        case .detail2:
            return 16
        case .l1(let weight):
            return 24
        case .l2(let weight):
            return 20
        case .l3(let weight):
            return 16
        case .l4:
            return 12
        }
    }
    
    var kerning: CGFloat {
        switch self {
        case .title1:
            return -0.26
        case .title2:
            return -0.6
        case .title3:
            return 0
        case .b1:
            return -0.54
        case .b2:
            return -0.18
        case .b3(let weight):
            switch weight {
            case .b, .m:
                return -0.15
            case .r:
                return -0.42
            }
        case .detail1:
            return -0.15
        case .detail2:
            return -0.13
        case .l1:
            return -0.2
        case .l2(let weight):
            return -0.18
        case .l3:
            return -0.15
        case .l4:
            return -0.11
        }
    }
    
    var size: CGFloat {
        switch self {
        case .title1:
            return 24
        case .title2:
            return 20
        case .title3:
            return 18
        case .b1:
            return 18
        case .b2:
            return 16
        case .b3:
            return 14
        case .detail1:
            return 14
        case .detail2:
            return 12
        case .l1:
            return 18
        case .l2:
            return 16
        case .l3:
            return 14
        case .l4:
            return 10
        }
    }
}

public extension PokitFont {
    enum Weight {
        case b
        case m
        case r
    }
}
