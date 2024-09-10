//
//  VersionEndpoint.swift
//  CoreKit
//
//  Created by 김민호 on 9/10/24.
//

import Foundation
import Util
import Moya

/// Version을 위한 Moya Endpoint
public enum VersionEndpoint {
    case 버전체크
}

extension VersionEndpoint: TargetType {
    public var baseURL: URL {
        return Constants.serverURL.appendingPathComponent(Constants.versionPath, conformingTo: .url)
    }
    
    public var path: String {
        /// 확장성을 위해 switch문으로 놔둠
        switch self {
        case .버전체크: return ""
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .버전체크:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .버전체크:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }
}
