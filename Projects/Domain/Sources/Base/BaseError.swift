//
//  BaseError.swift
//  Domain
//
//  Created by 김민호 on 8/23/24.
//

import Foundation

import CoreKit

public enum BaseError: Equatable {
    case CA_002(message: String)
    case CA_007(message: String)
    case CA_008(message: String)
    case CA_009(message: String)
    case unknown(message: String)
    
    public var title: String {
        switch self {
        case .CA_002: return "포킷 조회 오류"
        case .CA_007, .CA_008: return "포킷 저장 오류"
        case .CA_009: return "포킷명을 변경하시겠습니까?"
        case .unknown: return "알 수 없는 오류"
        }
    }
    
    public var message: String {
        switch self {
        case let .CA_002(message),
             let .CA_007(message),
             let .CA_008(message),
             let .CA_009(message),
             let .unknown(message):
            return message
        }
    }
    
    public init(response: ErrorResponse) {
        switch response.code {
        case "CA_002":
            self = .CA_002(message: response.message)
        case "CA_007":
            self = .CA_007(message: response.message)
        case "CA_008":
            self = .CA_008(message: response.message)
        case "CA_009":
            self = .CA_009(message: response.message)
        default:
            self = .unknown(message: response.message)
            
        }
    }
}
