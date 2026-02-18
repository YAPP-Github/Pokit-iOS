import Foundation

import ComposableArchitecture
import CoreKit
import Domain
import FeatureContentDetail
import Testing

@testable import App

@MainActor
struct MainTabFeatureDeeplinkTests {
    @Test("딥링크 1/3: MainTab 생성 이전 큐 소비 + 구독 중 실시간 방출(alert)")
    func alertRouteQueuedAndLiveEmittedByRouter() async throws {
        let router = DeeplinkRouteClient.liveValue
        await router.routeTo(URL(string: "pokit://alert"))

        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        } withDependencies: {
            $0[PasteboardClient.self] = .noop
            $0[DeeplinkRouteClient.self] = router
        }
        store.exhaustivity = .off

        await store.send(.view(.onAppear))
        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.delegate.알림함이동)

        await router.routeTo(URL(string: "pokit://alert"))
        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.delegate.알림함이동)

        await store.skipInFlightEffects()
    }

    @Test("딥링크 2/3: pokit shared(categoryId+contentId) -> 카테고리 진입 후 contentDetail 오픈 + 탭 유지")
    func sharedRouteWithContentOpensContentDetail() async throws {
        let router = DeeplinkRouteClient.liveValue

        var initialState = MainTabFeature.State()
        initialState.selectedTab = .recommend
        let store = TestStore(initialState: initialState) {
            MainTabFeature()
        } withDependencies: {
            $0[PasteboardClient.self] = .noop
            $0[CategoryClient.self] = .previewValue
            $0[ContentClient.self] = .previewValue
            $0[DeeplinkRouteClient.self] = router
        }
        store.exhaustivity = .off

        await store.send(.view(.onAppear))

        await router.routeTo(URL(string: "pokit://shared?categoryId=2&contentId=777"))

        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.async.포킷_딥링크_처리)
        await store.receive(\.inner.포킷_딥링크_이동) {
            if case let .카테고리상세(state) = $0.path.last, state.category.id == 2 {
                // same category: no push
            } else {
                $0.path.append(.카테고리상세(.init(type: .참여, category: makeCategory(id: 2, name: "카테고리1"))))
            }
            $0.contentDetail = .init(contentId: 777)
        }

        await store.skipInFlightEffects()
    }

    @Test("딥링크 3/3: pokit shared(categoryId+userId) -> 카테고리 진입 후 참여인원 시트 오픈 + 탭 유지")
    func sharedRouteWithUserOpensParticipantsSheet() async throws {
        let router = DeeplinkRouteClient.liveValue

        var initialState = MainTabFeature.State()
        initialState.selectedTab = .recommend
        let store = TestStore(initialState: initialState) {
            MainTabFeature()
        } withDependencies: {
            $0[PasteboardClient.self] = .noop
            $0[CategoryClient.self] = .previewValue
            $0[ContentClient.self] = .previewValue
            $0[DeeplinkRouteClient.self] = router
        }
        store.exhaustivity = .off

        await store.send(.view(.onAppear))

        await router.routeTo(URL(string: "pokit://shared?categoryId=2&userId=999"))

        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.async.포킷_딥링크_처리)
        await store.receive(\.inner.포킷_딥링크_이동) {
            if case let .카테고리상세(state) = $0.path.last, state.category.id == 2 {
                // same category: no push
            } else {
                $0.path.append(.카테고리상세(.init(type: .참여, category: makeCategory(id: 2, name: "카테고리1"))))
            }
        }

        guard let categoryPathID = store.state.path.ids.last else {
            throw TestAssertionError("카테고리 Path ID를 찾을 수 없습니다.")
        }

        await store.receive(\.path[id: categoryPathID].카테고리상세.view.참여인원_버튼_눌렀을때)
        await store.receive(\.path[id: categoryPathID].카테고리상세.inner.참여인원_시트_활성화)

        await store.skipInFlightEffects()
    }

    @Test("미분류 카테고리 이동은 탭 유지 + 미분류 활성화 delegate 전달")
    func unclassifiedCategoryMoveKeepsTabAndActivatesUnclassified() async throws {
        var initialState = MainTabFeature.State()
        initialState.selectedTab = .recommend
        initialState.path.append(.카테고리상세(.init(category: makeCategory(id: 99, name: "기존"))))

        let store = TestStore(initialState: initialState) {
            MainTabFeature()
        } withDependencies: {
            $0[PasteboardClient.self] = .noop
            $0[CategoryClient.self] = .previewValue
            $0[ContentClient.self] = .previewValue
        }
        store.exhaustivity = .off

        await store.send(.inner(.카테고리상세_이동(category: makeCategory(id: 0, name: "미분류")))) {
            $0.path.removeAll()
        }
        await store.receive(\.pokit.delegate.미분류_카테고리_활성화)
    }
}

private func makeCategory(id: Int, name: String) -> BaseCategoryItem {
    .init(
        id: id,
        userId: 0,
        categoryName: name,
        categoryImage: .init(imageId: id, imageURL: ""),
        contentCount: 0,
        createdAt: "",
        openType: .공개,
        keywordType: .default,
        userCount: 0,
        isFavorite: false
    )
}

private struct TestAssertionError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) {
        self.description = description
    }
}
