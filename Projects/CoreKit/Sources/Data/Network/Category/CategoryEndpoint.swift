//
//  CategoryEndpoint.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation

import Moya
/// 카테고리 전용 Endpont
public enum CategoryEndpoint {
    case 카테고리_삭제(categoryId: String)
    case 카테고리_수정(categoryId: String, model: CategoryEditRequest)
    case 카테고리_목록_조회(model: CategoryListInquiryRequest)
    case 카테고리생성(model: CategoryEditRequest)
    case 카테고리_프로필_목록_조회
    case 유저_카테고리_개수_조회
    
}

extension CategoryEndpoint: TargetType {
    public var baseURL: URL {
        return URL(string: "")!
    }
    
    public var path: String {
        switch self {
        case let .카테고리_삭제(categoryId):
            return "/api/v1/category/\(categoryId)"
        case let .카테고리_수정(categoryId, _):
            return "/api/v1/category/\(categoryId)"
        case .카테고리_목록_조회:
            return "/api/v1/category"
        case .카테고리생성:
            return "/api/v1/category"
        case .카테고리_프로필_목록_조회:
            return "/api/v1/category/images"
        case .유저_카테고리_개수_조회:
            return "/api/v1/category/count"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .카테고리_삭제: 
            return .put
            
        case .카테고리_수정:
            return .patch
            
        case .카테고리_목록_조회,
             .카테고리_프로필_목록_조회,
             .유저_카테고리_개수_조회: 
            return .get
            
        case .카테고리생성:
            return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .카테고리_삭제:
            return .requestPlain
        case let .카테고리_수정(_, model):
            return .requestJSONEncodable(model)
        case let .카테고리_목록_조회(model):
            return .requestParameters(
                parameters: [
                    "page": model.page,
                    "size": model.size,
                    "sort": model.sort
                ],
                encoding: URLEncoding.default
            )
        case let .카테고리생성(model):
            return .requestJSONEncodable(model)
        case .카테고리_프로필_목록_조회:
            return .requestPlain
        case .유저_카테고리_개수_조회:
            return .requestPlain
        }
    }
    public var headers: [String : String]? { nil }
}
