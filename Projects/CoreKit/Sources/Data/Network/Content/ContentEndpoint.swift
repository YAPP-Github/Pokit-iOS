//
//  ContentEndpoint.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation

import Moya
/// 컨텐츠 전용 Endpont
public enum ContentEndpoint {
    case 컨텐츠_삭제(contentId: String)
    case 컨텐츠_상세_조회(contentId: String, model: ContentBaseRequest)
    case 컨텐츠_수정(contentId: String, model: ContentBaseRequest)
    case 즐겨찾기_취소(contentId: String)
    case 즐겨찾기(contentId: String)
    case 컨텐츠_추가(model: ContentBaseRequest)
    case 카태고리_내_컨텐츠_목록_조회(contentId: String, model: BasePageableRequest)
}

extension ContentEndpoint: TargetType {
    public var baseURL: URL {
        return URL(string: "")!
    }
    
    public var path: String {
        switch self {
        case let .컨텐츠_삭제(categoryId):
            return "/api/v1/content/\(categoryId)"
        case let .컨텐츠_상세_조회(contentId, _):
            return "/api/v1/content/\(contentId)"
        case let .컨텐츠_수정(contentId, _):
            return "/api/v1/content/\(contentId)"
        case let .즐겨찾기_취소(contentId):
            return "/api/v1/content/\(contentId)/bookmark"
        case let .즐겨찾기(contentId):
            return "/api/v1/content/\(contentId)/bookmark"
        case .컨텐츠_추가:
            return "/api/v1/content"
        case let .카태고리_내_컨텐츠_목록_조회(contentId, _):
            return "/api/v1/content/\(contentId)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .컨텐츠_삭제,
             .즐겨찾기_취소:
            return .put
            
        case .컨텐츠_상세_조회,
             .즐겨찾기,
             .컨텐츠_추가:
            return .post
            
        case .컨텐츠_수정:
            return .patch
            
        case .카태고리_내_컨텐츠_목록_조회:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .컨텐츠_삭제:
            return .requestPlain
        case let .컨텐츠_상세_조회(_, model):
            return .requestJSONEncodable(model)
        case let .컨텐츠_수정(_, model):
            return .requestJSONEncodable(model)
        case .즐겨찾기_취소:
            return .requestPlain
        case .즐겨찾기:
            return .requestPlain
        case let .컨텐츠_추가(model):
            return .requestJSONEncodable(model)
        case let .카태고리_내_컨텐츠_목록_조회(_, model):
            return .requestParameters(
                parameters: [
                    "page": model.page,
                    "size": model.size,
                    "sort": model.sort
                ],
                encoding: URLEncoding.default
            )
        }
    }
    
    public var headers: [String : String]? { nil }
}
