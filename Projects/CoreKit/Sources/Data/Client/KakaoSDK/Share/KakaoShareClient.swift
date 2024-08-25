//
//  KakaoShareClient.swift
//  CoreKit
//
//  Created by 김도형 on 8/15/24.
//

import UIKit

import Dependencies
import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate

public struct KakaoShareClient {
    public var 카테고리_카카오톡_공유: (
        _ model: CategoryKaKaoShareModel
    ) -> Void
}

extension KakaoShareClient: DependencyKey {
    public static var liveValue: KakaoShareClient {
        return Self(
            카테고리_카카오톡_공유: { model in
                /// 딥링크
                let appLink = Link(
                    androidExecutionParams: [
                        "categoryId": "\(model.categoryId)"
                    ], iosExecutionParams: [
                        "categoryId": "\(model.categoryId)"
                    ]
                )
                
                /// 카카오톡 메세지의 앱 이동 버튼
                let button = Button(
                    title: "앱에서 보기",
                    link: appLink
                )
                
                /// 카카오톡 메세지 내용
                let content = Content(
                    title: "\(model.categoryName) 포킷을 공유받았어요!",
                    imageUrl: URL(string: model.imageURL),
                    description: "소중한 링크들이 담긴 포킷을 Pokit 앱에서 지금 바로 확인해보세요!",
                    link: appLink
                )
                
                /// 피드 템플릿
                let template = FeedTemplate(
                    content: content,
                    buttons: [button]
                )
                
                guard ShareApi.isKakaoTalkSharingAvailable(),
                      let templateJsonData = try? SdkJSONEncoder.custom.encode(template),
                      let templateJsonObject = SdkUtils.toJsonObject(templateJsonData) else {
                    /// 🚨 Error Case [1]: 카카오톡 미설치
                    guard let url = URL(string: "itms-apps://itunes.apple.com/app/id362057947"),
                          UIApplication.shared.canOpenURL(url) else {
                        return
                    }
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return
                }
                
                let serverCallbackArgs = ["categoryId": "\(model.categoryId)"]
                
                ShareApi.shared.shareDefault(
                    templateObject: templateJsonObject,
                    serverCallbackArgs: serverCallbackArgs
                ) { linkResult, error in
                    if let error = error {
                        print("error : \(error)")
                    } else {
                        print("defaultLink(templateObject:templateJsonObject) success.")
                        guard let linkResult else { return }
                        UIApplication.shared.open(
                            linkResult.url,
                            options: [:],
                            completionHandler: nil
                        )
                    }
                }
            }
        )
    }
}

extension DependencyValues {
    public var kakaoShareClient: KakaoShareClient {
        get { self[KakaoShareClient.self] }
        set { self[KakaoShareClient.self] = newValue }
    }
}


