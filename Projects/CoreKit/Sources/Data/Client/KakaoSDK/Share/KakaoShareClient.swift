//
//  KakaoShareClient.swift
//  CoreKit
//
//  Created by 김도형 on 8/15/24.
//

import UIKit

import DependenciesMacros

@DependencyClient
public struct KakaoShareClient {
    public var 카테고리_카카오톡_공유: (_ model: CategoryKaKaoShareModel) -> Void
}


