//
//  BaseError.swift
//  Domain
//
//  Created by 김민호 on 8/23/24.
//

import Foundation

import CoreKit

public enum BaseError: Equatable {
    case CA_001(message: String)
    case CA_002(message: String)
    case CA_007(message: String)
    case unknown(message: String)
    
    public var title: String {
        switch self {
        case .CA_002: return "포킷 조회 오류"
        case .CA_001, .CA_007: return "포킷 저장 오류"
        case .unknown: return "알 수 없는 오류"
        }
    }
    
    public var message: String {
        switch self {
        case let .CA_001(message),
             let .CA_002(message),
             let .CA_007(message),
             let .unknown(message):
            return message
        }
    }
    
    public init(response: ErrorResponse) {
        switch response.code {
        case "CA_001":
            self = .CA_001(message: response.message)
        case "CA_002":
            self = .CA_002(message: response.message)
        case "CA_007":
            self = .CA_007(message: response.message)
        default:
            self = .unknown(message: response.message)
            
        }
    }
}
