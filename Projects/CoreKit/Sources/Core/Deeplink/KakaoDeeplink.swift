//
//  KakaoDeeplink.swift
//  CoreKit
//
//  Created by 김도형 on 2/17/26.
//

import Foundation

import SharedThirdPartyLib

@SchemeRoutable
enum KakaoDeeplink: Equatable, Sendable {
    static var scheme: String {
        guard
            let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String,
            !appKey.isEmpty
        else {
            return "__invalid_kakao_scheme__"
        }
        return "kakao\(appKey)"
    }

    @SchemePattern("kakaolink?categoryId=${categoryId}&shareType=${shareType}")
    case sharedCategory(categoryId: Int, shareType: String?)
}
