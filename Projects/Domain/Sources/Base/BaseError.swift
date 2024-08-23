//
//  BaseError.swift
//  Domain
//
//  Created by 김민호 on 8/23/24.
//

import Foundation

import CoreKit

public enum BaseError: Equatable {
    case C_007(message: String)
    case unknown(message: String)
    
    public var title: String {
        switch self {
        case .C_007: return "포킷 저장 오류"
        case .unknown: return ""
        }
    }
    
    public var message: String {
        switch self {
        case let .C_007(message),
             let .unknown(message):
            return message
        }
    }
    
    public init(response: ErrorResponse) {
        switch response.code {
        case "C_007":
            self = .C_007(message: response.message)
        default:
            self = .unknown(message: response.message)
            
        }
    }
}
