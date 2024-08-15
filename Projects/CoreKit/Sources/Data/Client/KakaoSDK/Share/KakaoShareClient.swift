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
    public var 컨텐츠_카카오톡_공유: (
        _ model: KakaoShareModel,
        _ webShare: @escaping (_ url: URL) -> Void
    ) -> Void
}

extension KakaoShareClient: DependencyKey {
    public static var liveValue: KakaoShareClient {
        return Self(
            컨텐츠_카카오톡_공유: { model, webShare in
                /// 딥링크
                let appLink = Link(
                    androidExecutionParams: [
                        "userId": "\(model.userId)",
                        "contentId": "\(model.contentId)"
                    ], iosExecutionParams: [
                        "userId": "\(model.userId)",
                        "contentId": "\(model.contentId)"
                    ]
                )
                
                /// 카카오톡 메세지의 앱 이동 버튼
                let button = Button(
                    title: "앱에서 보기",
                    link: appLink
                )
                
                /// 카카오톡 메세지 내용
                let content = Content(
                    title: model.title,
                    imageUrl: URL(string: model.imageURL),
                    description: model.description,
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
                    /// 웹공유로 이동
                    if let url = ShareApi.shared.makeDefaultUrl(templatable: template) {
                        webShare(url)
                    }
                    return
                }
                
                ShareApi.shared.shareDefault(
                    templateObject: templateJsonObject
                ) { linkResult, error in
                    if let error = error {
                        print("error : \(error)")
                    } else {
                        print("defaultLink(templateObject:templateJsonObject) success.")
                        guard let linkResult = linkResult else { return }
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


