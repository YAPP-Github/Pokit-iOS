//
//  RemindEndpoint.swift
//  CoreKit
//
//  Created by 김도형 on 8/8/24.
//

import Foundation

import Util
import Moya

public enum RemindEndpoint {
    case 오늘의_리마인드_조회
    case 읽지않음_컨텐츠_조회(model: BasePageableRequest)
    case 즐겨찾기_링크모음_조회(model: BasePageableRequest)
}

extension RemindEndpoint: TargetType {
    public var baseURL: URL {
        Constants
            .serverURL
            .appendingPathComponent(
                Constants.remindPath,
                conformingTo: .url
            )
    }
    
    public var path: String {
        switch self {
        case .오늘의_리마인드_조회: return "/today"
        case .읽지않음_컨텐츠_조회(_): return "/unread"
        case .즐겨찾기_링크모음_조회(_): return "/bookmark"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .오늘의_리마인드_조회,
             .읽지않음_컨텐츠_조회,
             .즐겨찾기_링크모음_조회:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .오늘의_리마인드_조회:
            return .requestPlain
        case .읽지않음_컨텐츠_조회(let model),
             .즐겨찾기_링크모음_조회(let model):
            return .requestJSONEncodable(model)
        }
    }
    
    public var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }
}
