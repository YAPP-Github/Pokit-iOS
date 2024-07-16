//
//  PokitRootType.swift
//  FeaturePokit
//
//  Created by 김민호 on 7/16/24.
//

public enum PokitRootFilterType: Equatable {
    case folder(Folder)
    case sort(Sort)
    
    public enum Folder {
        case 포킷
        case 미분류
    }
    public enum Sort {
        case 최신순
        case 이름순
    }
}
