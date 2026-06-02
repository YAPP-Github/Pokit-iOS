//
//  DeeplinkRouteClient+LiveKey.swift
//  CoreKit
//
//  Created by 김도형 on 2/17/26.
//

import Foundation

import Dependencies

extension DeeplinkRouteClient: DependencyKey {
    public static let liveValue: Self = {
        return Self(
            routeTo: { url in
                await DeeplinkRouter.shared.routeTo(url: url)
            },
            routeStream: {
                AsyncStream { continuation in
                    let id = UUID()
                    Task {
                        await DeeplinkRouter.shared.addSubscriber(
                            id: id,
                            continuation: continuation
                        )
                    }

                    continuation.onTermination = { _ in
                        Task {
                            await DeeplinkRouter.shared.removeSubscriber(id: id)
                        }
                    }
                }
            }
        )
    }()
}

@DeeplinkActor
private final class DeeplinkRouter {
    static let shared = DeeplinkRouter()

    private var subscribers: [UUID: AsyncStream<DeeplinkRoute>.Continuation] = [:]
    private var queuedRoutes: [DeeplinkRoute] = []

    private init() {}

    func routeTo(url: URL?) {
        guard
            let url,
            let route = parse(url: url)
        else { return }

        guard !subscribers.isEmpty else {
            queuedRoutes.append(route)
            return
        }

        broadcast(route)
    }

    func addSubscriber(
        id: UUID,
        continuation: AsyncStream<DeeplinkRoute>.Continuation
    ) {
        subscribers[id] = continuation
        drainQueueIfNeeded()
    }

    func removeSubscriber(id: UUID) {
        subscribers[id] = nil
    }

    private func drainQueueIfNeeded() {
        guard !queuedRoutes.isEmpty else { return }

        let routes = queuedRoutes
        queuedRoutes.removeAll()

        for route in routes {
            broadcast(route)
        }
    }

    private func broadcast(_ route: DeeplinkRoute) {
        subscribers.values.forEach { continuation in
            continuation.yield(route)
        }
    }

    private func parse(url: URL) -> DeeplinkRoute? {
        if let route = KakaoDeeplink(url: url) {
            switch route {
            case let .sharedCategory(categoryId, shareType):
                return .kakaoSharedCategory(categoryId: categoryId, shareType: shareType)
            }
        }

        if let route = PokitDeeplink(url: url) {
            switch route {
            case let .shared(categoryId, contentId, userId):
                return .pokitShared(categoryId: categoryId, contentId: contentId, userId: userId)
            case .alert:
                return .pokitAlert
            }
        }

        return nil
    }
}
