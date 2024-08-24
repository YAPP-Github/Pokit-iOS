//
//  UserEndpoint.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation

import Util
import Moya
/// 컨텐츠 전용 Endpont
public enum UserEndpoint {
    case 닉네임_수정(model: NicknameEditRequest)
    case 회원등록(model: SignupRequest)
    case 닉네임_중복_체크(nickname: String)
    case 관심사_목록_조회
    case 닉네임_조회
}

extension UserEndpoint: TargetType {
    public var baseURL: URL {
        return Constants.serverURL.appendingPathComponent(Constants.userPath, conformingTo: .url)
    }
    
    public var path: String {
        switch self {
        case .닉네임_수정, .닉네임_조회:
            return "/nickname"
        case .회원등록:
            return "/signup"
        case let .닉네임_중복_체크(nickname):
            return "/duplicate/\(nickname)"
        case .관심사_목록_조회:
            return "/interests"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .닉네임_수정:
            return .put
            
        case .회원등록:
            return .post
        
        case .닉네임_중복_체크,
             .관심사_목록_조회,
             .닉네임_조회:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case let .닉네임_수정(model):
            return .requestJSONEncodable(model)
        case let .회원등록(model):
            return .requestJSONEncodable(model)
        case .닉네임_중복_체크,
             .관심사_목록_조회,
             .닉네임_조회:
            return .requestPlain
        }
    }
    
    public var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}

