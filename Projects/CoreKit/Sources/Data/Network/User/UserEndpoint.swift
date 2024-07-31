//
//  UserEndpoint.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation

import Moya
/// 컨텐츠 전용 Endpont
public enum UserEndpoint {
    case 닉네임_수정(model: NicknameEditRequest)
    case 회원등록(model: SignupRequest)
    case 닉네임_중복_체크(nickname: String)
}

extension UserEndpoint: TargetType {
    public var baseURL: URL {
        return URL(string: "")!
    }
    
    public var path: String {
        switch self {
        case .닉네임_수정:
            return "/api/v1/user/nickname"
        case .회원등록:
            return "/api/v1/user/signup"
        case let .닉네임_중복_체크(nickname):
            return "/api/v1/user/duplicate/\(nickname)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .닉네임_수정:
            return .put
            
        case .회원등록:
            return .post
        
        case .닉네임_중복_체크:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case let .닉네임_수정(model):
            return .requestJSONEncodable(model)
        case let .회원등록(model):
            return .requestJSONEncodable(model)
        case .닉네임_중복_체크:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? { nil }
}

