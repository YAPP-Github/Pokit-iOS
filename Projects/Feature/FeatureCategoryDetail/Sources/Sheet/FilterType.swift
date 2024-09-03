//
//  FilterType.swift
//  FeatureCategoryDetail
//
//  Created by 김민호 on 7/19/24.
//

import Foundation

public enum SortType: String {
    case 최신순
    case 오래된순
    
    var title: String { self.rawValue }
}

public enum SortCollectType: String {
    case 즐겨찾기
    case 안읽음
    
    var title: String { self.rawValue }
}
