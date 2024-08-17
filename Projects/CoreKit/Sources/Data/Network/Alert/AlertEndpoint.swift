//
//  AlertEndpoint.swift
//  CoreKit
//
//  Created by 김민호 on 8/17/24.
//

import Foundation

import Util
import Moya
/// Alert을 위한 Moya Endpoint
public enum AlertEndpoint {
    case 알람_목록_조회(model: BasePageableRequest)
    case 알람_삭제(alertId: String)
}

extension AlertEndpoint: TargetType {
    public var baseURL: URL {
        return Constants.serverURL.appendingPathComponent(Constants.alertPath, conformingTo: .url)
    }
    
    public var path: String {
        switch self {
        case .알람_목록_조회: return ""
        case let .알람_삭제(alertId): return "/\(alertId)"
            
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .알람_목록_조회:
            return .get
        case .알람_삭제:
            return .put
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case let .알람_목록_조회(model):
            return .requestParameters(
                parameters: [
                    "page": model.page,
                    "size": model.size,
                    "sort": model.sort.map { String($0) }.joined(separator: ",")
                ],
                encoding: URLEncoding.default
            )
        case .알람_삭제:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }
}
