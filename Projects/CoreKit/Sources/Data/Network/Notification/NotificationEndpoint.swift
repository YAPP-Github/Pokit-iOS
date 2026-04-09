//
//  NotificationEndpoint.swift
//  CoreKit
//
//  Created by Codex on 2026-04-06.
//

import Foundation

import Moya
import Util

public enum NotificationEndpoint {
    case 알림_목록_조회(model: BasePageableRequest)
    case 알림_읽음(notificationId: Int)
    case 알림_삭제(notificationId: Int)
}

extension NotificationEndpoint: TargetType {
    public var baseURL: URL {
        Constants.serverURL.appendingPathComponent(Constants.notificationPath, conformingTo: .url)
    }

    public var path: String {
        switch self {
        case .알림_목록_조회:
            return ""
        case let .알림_읽음(notificationId):
            return "/\(notificationId)/read"
        case let .알림_삭제(notificationId):
            return "/\(notificationId)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .알림_목록_조회:
            return .get
        case .알림_읽음:
            return .patch
        case .알림_삭제:
            return .delete
        }
    }

    public var task: Moya.Task {
        switch self {
        case let .알림_목록_조회(model):
            return .requestParameters(
                parameters: [
                    "page": model.page,
                    "size": model.size,
                    "sort": model.sort.map { String($0) }.joined(separator: ",")
                ],
                encoding: URLEncoding.default
            )
        case .알림_읽음,
             .알림_삭제:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
