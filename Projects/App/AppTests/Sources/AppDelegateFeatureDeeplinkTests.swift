import ComposableArchitecture
import CoreKit
import Foundation
import Testing
import UserNotifications

@testable import App

@MainActor
struct AppDelegateFeatureDeeplinkTests {
    @Test("푸시 payload deeplink가 있으면 라우터에 해당 URL을 전달")
    func deeplinkPayloadRoutesToRouter() async throws {
        let recorder = URLRecorder()
        var completionCalled = false
        
        let response = makeResponse(
            userInfo: ["deepLink": "pokit://shared?categoryId=10&contentId=2&userId=3"]
        )
        
        let store = TestStore(initialState: AppDelegateFeature.State()) {
            AppDelegateFeature()
        } withDependencies: {
            $0[DeeplinkRouteClient.self].routeTo = { url in
                await recorder.append(url)
            }
        }
        
        let task = await store.send(.userNotifications(.didReceiveResponse(
            response,
            completionHandler: { completionCalled = true }
        )))
        await task.finish()
        
        let urls = await recorder.values()
        try assertSingleURL(
            urls,
            expected: "pokit://shared?categoryId=10&contentId=2&userId=3"
        )
        try assertCompletionCalled(completionCalled)
    }
    
    @Test("푸시 payload deepLink가 누락되면 pokit://alert fallback 전달")
    func missingPayloadFallsBackToAlertRoute() async throws {
        let recorder = URLRecorder()
        var completionCalled = false
        
        let response = makeResponse(userInfo: [:])
        
        let store = TestStore(initialState: AppDelegateFeature.State()) {
            AppDelegateFeature()
        } withDependencies: {
            $0[DeeplinkRouteClient.self].routeTo = { url in
                await recorder.append(url)
            }
        }
        
        let task = await store.send(.userNotifications(.didReceiveResponse(
            response,
            completionHandler: { completionCalled = true }
        )))
        await task.finish()
        
        let urls = await recorder.values()
        try assertSingleURL(urls, expected: "pokit://alert")
        try assertCompletionCalled(completionCalled)
    }
    
    @Test("푸시 payload deepLink 문자열이 잘못되어도 pokit://alert fallback 전달")
    func invalidPayloadFallsBackToAlertRoute() async throws {
        let recorder = URLRecorder()
        var completionCalled = false
        
        let response = makeResponse(userInfo: ["deepLink": "not a url"])
        
        let store = TestStore(initialState: AppDelegateFeature.State()) {
            AppDelegateFeature()
        } withDependencies: {
            $0[DeeplinkRouteClient.self].routeTo = { url in
                await recorder.append(url)
            }
        }
        
        let task = await store.send(.userNotifications(.didReceiveResponse(
            response,
            completionHandler: { completionCalled = true }
        )))
        await task.finish()
        
        let urls = await recorder.values()
        try assertSingleURL(urls, expected: "pokit://alert")
        try assertCompletionCalled(completionCalled)
    }
}

private actor URLRecorder {
    private var urls: [URL] = []

    func append(_ url: URL?) {
        guard let url else { return }
        urls.append(url)
    }

    func values() -> [URL] {
        urls
    }
}

private func makeResponse(userInfo: [AnyHashable: Any]) -> UserNotificationClient.Notification.Response {
    let content = UNMutableNotificationContent()
    content.userInfo = userInfo
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
    return .init(
        notification: .init(date: Date(), request: request)
    )
}

private func assertSingleURL(_ urls: [URL], expected: String) throws {
    guard urls.count == 1 else {
        throw TestAssertionError("URL 개수가 1이 아닙니다. actual: \(urls.map(\.absoluteString))")
    }
    guard urls.first?.absoluteString == expected else {
        throw TestAssertionError("URL이 다릅니다. expected: \(expected), actual: \(urls.first?.absoluteString ?? "nil")")
    }
}

private func assertCompletionCalled(_ completionCalled: Bool) throws {
    guard completionCalled else {
        throw TestAssertionError("completionHandler가 호출되지 않았습니다.")
    }
}

private struct TestAssertionError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) {
        self.description = description
    }
}
