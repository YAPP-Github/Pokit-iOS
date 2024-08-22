//
//  CategoryEndpoint.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation

import Util
import Moya
/// 카테고리 전용 Endpont
public enum CategoryEndpoint {
    case 카테고리_삭제(categoryId: Int)
    case 카테고리_수정(categoryId: Int, model: CategoryEditRequest)
    case 카테고리_목록_조회(model: BasePageableRequest, filterUncategorized: Bool)
    case 카테고리생성(model: CategoryEditRequest)
    case 카테고리_프로필_목록_조회
    case 유저_카테고리_개수_조회
    case 카테고리_상세_조회(categoryId: String)
    case 공유받은_카테고리_조회(categoryId: String, model: BasePageableRequest)
    case 공유받은_카테고리_저장(model: CopiedCategoryRequest)
    
}

extension CategoryEndpoint: TargetType {
    public var baseURL: URL {
        return Constants.serverURL.appendingPathComponent(Constants.categoryPath, conformingTo: .url)
    }
    
    public var path: String {
        switch self {
        case let .카테고리_삭제(categoryId):
            return "/\(categoryId)"
        case let .카테고리_수정(categoryId, _):
            return "/\(categoryId)"
        case .카테고리_프로필_목록_조회:
            return "/images"
        case .유저_카테고리_개수_조회:
            return "/count"
        case .카테고리_목록_조회,
             .카테고리생성:
            return ""
        case .카테고리_상세_조회(let categoryId):
            return "/\(categoryId)"
        case let .공유받은_카테고리_조회(categoryId, _):
            return "/share/\(categoryId)"
        case .공유받은_카테고리_저장(model: let model):
            return "/share"
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
             .유저_카테고리_개수_조회,
             .카테고리_상세_조회,
             .공유받은_카테고리_조회:
            return .get
            
        case .카테고리생성,
             .공유받은_카테고리_저장:
            return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .카테고리_삭제:
            return .requestPlain
        case let .카테고리_수정(_, model):
            return .requestJSONEncodable(model)
        case let .카테고리_목록_조회(model, categorized):
            return .requestParameters(
                parameters: [
                    "page": model.page,
                    "size": model.size,
                    "sort": model.sort.map { String($0) }.joined(separator: ","),
                    "filterUncategorized": categorized
                ],
                encoding: URLEncoding.default
            )
        case let .카테고리생성(model):
            return .requestJSONEncodable(model)
        case .카테고리_프로필_목록_조회:
            return .requestPlain
        case .유저_카테고리_개수_조회:
            return .requestPlain
        case .카테고리_상세_조회:
            return .requestPlain
        case let .공유받은_카테고리_조회(_, model):
            return .requestParameters(
                parameters: [
                    "page": model.page,
                    "size": model.size,
                    "sort": model.sort.map { String($0) }.joined(separator: ",")
                ],
                encoding: URLEncoding.default
            )
        case let .공유받은_카테고리_저장(model):
            return .requestParameters(
                parameters: [
                    "originCategoryId": model.originCategoryId,
                    "categoryName": model.categoryName
                ],
                encoding: URLEncoding.default
            )
        }
    }
    public var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
