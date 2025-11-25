import Foundation

/// Analytics 이벤트 타입
public enum AnalyticsEvent {
    case app_open(deviceOS: String, appVersion: String)
    case view_splash
    case login_start(method: LoginMethod)
    case login_complete(method: LoginMethod)
    case interest_select(interests: [String])
    case onboarding_complete
    case view_home_pokit(entryPoint: String)
    case view_home_recommend(entryPoint: String)
    case add_folder(folderName: String)
    case add_link(folderId: String, linkDomain: String, entryPoint: String? = nil, linkId: String? = nil, positionIndex: Int? = nil, algoVersion: String? = nil)
    case view_folder_detail(folderId: String)
    case view_link_detail(linkId: String, linkDomain: String, entryPoint: String? = nil, positionIndex: Int? = nil, cardType: String? = nil, algoVersion: String? = nil)
    case share_link(linkId: String, shareTarget: String)
    case session_end(duration: Int)

    /// 이벤트명 (rawValue)
    public var eventName: String {
        switch self {
        case .app_open: return "app_open"
        case .view_splash: return "view_splash"
        case .login_start: return "login_start"
        case .login_complete: return "login_complete"
        case .interest_select: return "interest_select"
        case .onboarding_complete: return "onboarding_complete"
        case .view_home_pokit: return "view_home_pokit"
        case .view_home_recommend: return "view_home_recommend"
        case .add_folder: return "add_folder"
        case .add_link: return "add_link"
        case .view_folder_detail: return "view_folder_detail"
        case .view_link_detail: return "view_link_detail"
        case .share_link: return "share_link"
        case .session_end: return "session_end"
        }
    }

    /// Amplitude에 전송할 속성값
    public var properties: [String: Any] {
        switch self {
        case let .app_open(deviceOS, appVersion):
            return [
                PropertyKey.device_os.rawValue: deviceOS,
                PropertyKey.app_version.rawValue: appVersion
            ]

        case .view_splash:
            return [:]

        case let .login_start(method):
            return [PropertyKey.method.rawValue: method.rawValue]

        case let .login_complete(method):
            return [PropertyKey.method.rawValue: method.rawValue]

        case let .interest_select(interests):
            return [PropertyKey.interests.rawValue: interests]

        case .onboarding_complete:
            return [:]

        case let .view_home_pokit(entryPoint):
            return [PropertyKey.entry_point.rawValue: entryPoint]

        case let .view_home_recommend(entryPoint):
            return [PropertyKey.entry_point.rawValue: entryPoint]

        case let .add_folder(folderName):
            return [PropertyKey.folder_name.rawValue: folderName]

        case let .add_link(folderId, linkDomain, entryPoint, linkId, positionIndex, algoVersion):
            var props: [String: Any] = [
                PropertyKey.folder_id.rawValue: folderId,
                PropertyKey.link_domain.rawValue: linkDomain
            ]
            if let entryPoint = entryPoint {
                props[PropertyKey.entry_point.rawValue] = entryPoint
            }
            if let linkId = linkId {
                props[PropertyKey.link_id.rawValue] = linkId
            }
            if let positionIndex = positionIndex {
                props[PropertyKey.position_index.rawValue] = positionIndex
            }
            if let algoVersion = algoVersion {
                props[PropertyKey.algo_version.rawValue] = algoVersion
            }
            return props

        case let .view_folder_detail(folderId):
            return [PropertyKey.folder_id.rawValue: folderId]

        case let .view_link_detail(linkId, linkDomain, entryPoint, positionIndex, cardType, algoVersion):
            var props: [String: Any] = [
                PropertyKey.link_id.rawValue: linkId,
                PropertyKey.link_domain.rawValue: linkDomain
            ]
            if let entryPoint = entryPoint {
                props[PropertyKey.entry_point.rawValue] = entryPoint
            }
            if let positionIndex = positionIndex {
                props[PropertyKey.position_index.rawValue] = positionIndex
            }
            if let cardType = cardType {
                props[PropertyKey.card_type.rawValue] = cardType
            }
            if let algoVersion = algoVersion {
                props[PropertyKey.algo_version.rawValue] = algoVersion
            }
            return props

        case let .share_link(linkId, shareTarget):
            return [
                PropertyKey.link_id.rawValue: linkId,
                PropertyKey.share_target.rawValue: shareTarget
            ]

        case let .session_end(duration):
            return [PropertyKey.duration.rawValue: duration]
        }
    }
}

/// Analytics 속성 키
public enum PropertyKey: String {
    case device_os
    case app_version
    case method
    case interests
    case entry_point
    case folder_name
    case folder_id
    case link_domain
    case link_id
    case share_target
    case duration
    case position_index
    case card_type
    case algo_version
}

/// 로그인 방식
public enum LoginMethod: String {
    case apple = "Apple"
    case google = "Google"
    case kakao = "Kakao"
}

extension LoginMethod {
    init?(authPlatform: String) {
        switch authPlatform.lowercased() {
        case "apple":
            self = .apple
        case "google":
            self = .google
        case "kakao":
            self = .kakao
        default:
            return nil
        }
    }
}
