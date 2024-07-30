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
    /// 로그인
    case login(DummyBody)
    /// 토큰 재발급
    case reissueToken(reqeust: PokitTokenRefreshRequest)
}

extension AuthEndpoint: TargetType {
    public var baseURL: URL {
        return URL(string: "")!
    }
    
    public var path: String {
        switch self {
        case .login: return "/login"
        case .reissueToken: return "/login/refresh"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .login, .reissueToken: return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case let .login(dum):
            return .requestJSONEncodable(dum)
        case let .reissueToken(dum):
            return .requestJSONEncodable(dum)
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case let .login:
            return ["Authorization": "Bearer "]
        default: return ["Content-Type": "application/json"]
        }
    }
}
