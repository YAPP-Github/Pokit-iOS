//
//  AlertMock.swift
//  FeatureSetting
//
//  Created by 김민호 on 7/21/24.
//

import Foundation

public struct AlertMock: Identifiable, Equatable {
    public let id = UUID()
    let title: String
    let contents: String
    let thumbnail: String
    let ago: String
}

public extension AlertMock {
    public static var mock: [Self] = [
        Self(
            title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
            contents: "내일 알림이 예정되어있어요!\n잊지 말고 링크를 확인하세요~",
            thumbnail: "https://picsum.photos/seed/picsum/200/300",
            ago: "1시간 전"
        ),
        Self(
            title: "두번째 알람 정보",
            contents: "알림 내용",
            thumbnail: "https://picsum.photos/seed/picsum/200/300",
            ago: "4일 전"
        ),
    ]
}
