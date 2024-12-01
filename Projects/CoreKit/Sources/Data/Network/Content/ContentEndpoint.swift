//
//  ContentEndpoint.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation

import Util
import Moya
/// 컨텐츠 전용 Endpont
public enum ContentEndpoint {
    case 컨텐츠_삭제(contentId: String)
    case 컨텐츠_상세_조회(contentId: String)
    case 컨텐츠_수정(contentId: String, model: ContentBaseRequest)
    case 즐겨찾기_취소(contentId: String)
    case 즐겨찾기(contentId: String)
    case 컨텐츠_추가(model: ContentBaseRequest)
    case 카태고리_내_컨텐츠_목록_조회(
        contentId: String,
        pageable: BasePageableRequest,
        condition: BaseConditionRequest
    )
    case 미분류_카테고리_컨텐츠_조회(model: BasePageableRequest)
    case 컨텐츠_검색(
        pageable: BasePageableRequest,
        condition: BaseConditionRequest
    )
    case 썸네일_수정(contentId: String, model: ThumbnailRequest)
}

extension ContentEndpoint: TargetType {
    public var baseURL: URL {
        return Constants.serverURL.appendingPathComponent(Constants.contentPath, conformingTo: .url)
    }
    
    public var path: String {
        switch self {
        case let .컨텐츠_삭제(categoryId):
            return "/\(categoryId)"
        case let .컨텐츠_상세_조회(contentId):
            return "/\(contentId)"
        case let .컨텐츠_수정(contentId, _):
            return "/\(contentId)"
        case let .즐겨찾기_취소(contentId):
            return "/\(contentId)/bookmark"
        case let .즐겨찾기(contentId):
            return "/\(contentId)/bookmark"
        case .컨텐츠_추가:
            return ""
        case let .카태고리_내_컨텐츠_목록_조회(contentId, _, _):
            return "/\(contentId)"
        case .미분류_카테고리_컨텐츠_조회:
            return "/uncategorized"
        case .컨텐츠_검색:
            return ""
        case let .썸네일_수정(contentId, _):
            return "/thumbnail/\(contentId)"
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
            
        case .컨텐츠_수정,
             .썸네일_수정:
            return .patch
            
        case .카태고리_내_컨텐츠_목록_조회,
             .미분류_카테고리_컨텐츠_조회,
             .컨텐츠_검색:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .컨텐츠_삭제:
            return .requestPlain
        case .컨텐츠_상세_조회:
            return .requestPlain
        case let .컨텐츠_수정(_, model):
            return .requestJSONEncodable(model)
        case .즐겨찾기_취소:
            return .requestPlain
        case .즐겨찾기:
            return .requestPlain
        case let .컨텐츠_추가(model):
            return .requestJSONEncodable(model)
        case let .카태고리_내_컨텐츠_목록_조회(_, pageable, condition):
            return .requestParameters(
                parameters: [
                    "page": pageable.page,
                    "size": pageable.size,
                    "sort": pageable.sort.map { String($0) }.joined(separator: ","),
                    "isRead": condition.isUnreadFiltered ? condition.isUnreadFiltered : "",
                    "favorites": condition.isFavoriteFlitered ? condition.isFavoriteFlitered : "",
                    "startDate": condition.startDate ?? "",
                    "endDate": condition.endDate ?? ""
                ],
                encoding: URLEncoding.default
            )
        case let .미분류_카테고리_컨텐츠_조회(model):
            return .requestParameters(
                parameters: [
                    "page": model.page,
                    "size": model.size,
                    "sort": model.sort.map { String($0) }.joined(separator: ",")
                ],
                encoding: URLEncoding.default
            )
        case let .컨텐츠_검색(pageable, condition):
            return .requestParameters(
                parameters: [
                    "page": pageable.page,
                    "size": pageable.size,
                    "sort": pageable.sort.map { String($0) }.joined(separator: ","),
                    "isRead": condition.isUnreadFiltered ? condition.isUnreadFiltered : "",
                    "favorites": condition.isFavoriteFlitered ? condition.isFavoriteFlitered : "",
                    "startDate": condition.startDate ?? "",
                    "endDate": condition.endDate ?? "",
                    "categoryIds": condition.categoryIds.map { String($0) }.joined(separator: ","),
                    "searchWord": condition.searchWord
                ],
                encoding: URLEncoding.default
            )
        case let .썸네일_수정(_, model):
            return .requestJSONEncodable(model)
        }
    }
    
    public var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
