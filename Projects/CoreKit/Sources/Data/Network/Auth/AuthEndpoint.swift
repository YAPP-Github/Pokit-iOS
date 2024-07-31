//
//  AuthEndpoint.swift
//  CoreKit
//
//  Created by 김민호 on 7/30/24.
//

import Foundation
import Moya
/// Auth를 위한 Moya Endpoint
public enum AuthEndpoint {
    case 로그인(SignInRequest)
    case 회원탈퇴(WithdrawRequest)
    case 토큰재발급(ReissueRequest)
}

extension AuthEndpoint: TargetType {
    public var baseURL: URL {
        return URL(string: "")!
    }
    
    public var path: String {
        switch self {
        case .로그인: return "/api/v1/auth/signin"
        case .회원탈퇴: return "/api/v1/auth/withdraw"
        case .토큰재발급: return "/api/v1/auth/reissue"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .로그인, .토큰재발급: return .post
        case .회원탈퇴: return .put
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case let .로그인(requestModel):
            return .requestJSONEncodable(requestModel)
            
        case let .회원탈퇴(requestModel):
            return .requestJSONEncodable(requestModel)
            
        case let .토큰재발급(requestModel):
            return .requestJSONEncodable(requestModel)
        }
    }
    
    public var headers: [String: String]? {
        return ["Authorization": "Bearer "]
    }
}
