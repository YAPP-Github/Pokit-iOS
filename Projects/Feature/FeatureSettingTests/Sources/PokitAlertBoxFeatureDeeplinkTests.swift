import Foundation

import ComposableArchitecture
import CoreKit
import Domain
import Testing

@testable import FeatureSetting

@MainActor
struct PokitAlertBoxFeatureDeeplinkTests {
    @Test("deeplink가 유효하면 라우터로 전달")
    func validDeeplinkRoutesToRouter() async throws {
        let recorder = RouteRecorder()
        let router = DeeplinkRouteClient.liveValue
        let streamTask = Task {
            for await route in router.routeStream() {
                await recorder.append(route)
            }
        }
        defer { streamTask.cancel() }
        await Task.yield()

        let item = makeAlertItem(deeplink: "pokit://shared?categoryId=10")

        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[DeeplinkRouteClient.self] = router
        }

        let task = await store.send(.view(.알람_항목_선택했을때(item: item)))
        await task.finish()
        await Task.yield()

        let routes = await recorder.values()
        try assertSingleRoute(
            routes,
            expected: .pokitShared(categoryId: 10, contentId: nil, userId: nil)
        )
    }

    @Test("deeplink가 nil이면 무동작")
    func nilDeeplinkDoesNothing() async throws {
        let recorder = RouteRecorder()
        let router = DeeplinkRouteClient.liveValue
        let streamTask = Task {
            for await route in router.routeStream() {
                await recorder.append(route)
            }
        }
        defer { streamTask.cancel() }
        await Task.yield()

        let item = makeAlertItem(deeplink: nil)

        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[DeeplinkRouteClient.self] = router
        }

        await store.send(.view(.알람_항목_선택했을때(item: item)))
        await Task.yield()

        let routes = await recorder.values()
        try assertNoRoute(routes)
    }

    @Test("deeplink가 빈 문자열/잘못된 URL이면 무동작")
    func invalidDeeplinkDoesNothing() async throws {
        let recorder = RouteRecorder()
        let router = DeeplinkRouteClient.liveValue
        let streamTask = Task {
            for await route in router.routeStream() {
                await recorder.append(route)
            }
        }
        defer { streamTask.cancel() }
        await Task.yield()

        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[DeeplinkRouteClient.self] = router
        }

        await store.send(.view(.알람_항목_선택했을때(item: makeAlertItem(deeplink: ""))))
        await store.send(.view(.알람_항목_선택했을때(item: makeAlertItem(deeplink: "___invalid___"))))
        await Task.yield()

        let routes = await recorder.values()
        try assertNoRoute(routes)
    }
}

private actor RouteRecorder {
    private var routes: [DeeplinkRoute] = []

    func append(_ route: DeeplinkRoute) {
        routes.append(route)
    }

    func values() -> [DeeplinkRoute] {
        routes
    }
}

private func makeAlertItem(deeplink: String?) -> AlertItem {
    .init(
        id: 1,
        userId: 1,
        contentId: 1,
        deeplink: deeplink,
        thumbNail: "",
        title: "title",
        body: "body",
        createdAt: ""
    )
}

private func assertSingleRoute(_ routes: [DeeplinkRoute], expected: DeeplinkRoute) throws {
    guard routes.count == 1 else {
        throw TestAssertionError("route 개수가 1이 아닙니다. actual: \(routes)")
    }
    guard routes.first == expected else {
        throw TestAssertionError("route가 다릅니다. expected: \(expected), actual: \(String(describing: routes.first))")
    }
}

private func assertNoRoute(_ routes: [DeeplinkRoute]) throws {
    guard routes.isEmpty else {
        throw TestAssertionError("route가 없어야 합니다. actual: \(routes)")
    }
}

private struct TestAssertionError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) {
        self.description = description
    }
}
