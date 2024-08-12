//
//  AuthEndpoint.swift
//  CoreKit
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

import Util
import Moya
/// Auth를 위한 Moya Endpoint
public enum AuthEndpoint {
    case 로그인(SignInRequest)
    case 회원탈퇴(WithdrawRequest)
    case 토큰재발급(ReissueRequest)
    case apple(AppleTokenRequest)
}

extension AuthEndpoint: TargetType {
    public var baseURL: URL {
        switch self {
        case .apple:
            return URL(string: "https://appleid.apple.com/auth/token")!
        default:
            return Constants.serverURL.appendingPathComponent(Constants.authPath, conformingTo: .url)
        }
    }
    
    public var path: String {
        switch self {
        case .로그인: return "/signin"
        case .회원탈퇴: return "/withdraw"
        case .토큰재발급: return "/reissue"
        case .apple: return ""
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .로그인, .토큰재발급, .apple: return .post
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
            
        case let .apple(requestModel):
            return .requestParameters(
                parameters: [
                    "client_id": "com.pokitmons.pokit",
                    "client_secret": requestModel.jwt,
                    "code": requestModel.authCode,
                    "grant_type": "authorization_code"
                    ],
                encoding: URLEncoding.default
            )
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case .apple: ["Content-Type": "application/x-www-form-urlencoded"]
        default: ["Content-Type": "application/json"]
        }
    }
}
