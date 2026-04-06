import Foundation

import ComposableArchitecture
import CoreKit
import Domain
import FeatureContentDetail
import Testing

@testable import App

@MainActor
struct MainTabFeatureDeeplinkTests {
    @Test("카카오 openURL 공유딥링크는 해당 카테고리 상세로 이동")
    func kakaoOpenURLRoutesToSharedCategory() async throws {
        let routeSpy = KakaoRouteSpy()
        var initialState = MainTabFeature.State()
        initialState.selectedTab = .recommend
        let store = makeStore(
            initialState: initialState,
            deeplinkRouteClient: routeSpy.client
        )

        await store.send(.view(.onAppear))

        let url = try #require(
            URL(string: "kakao7890f93caf1d9d5da976da4b4bc6e5e7://kakaolink?categoryId=2&shareType=share")
        )
        await store.send(.view(.onOpenURL(url: url)))

        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.async.공유받은_카테고리_조회)
        await store.receive(\.inner.공유받은_카테고리_이동) {
            $0.path = StackState([.카테고리상세(.init(
                type: .공유,
                category: makeSharedCategory(id: 2, name: "UITest-Category-2")
            ))])
        }

        let routedURLs = await routeSpy.routedURLs()
        #expect(routedURLs == [url])
        #expect(topCategoryID(in: store.state) == 2)

        await store.skipInFlightEffects()
    }

    @Test("포킷 alert 딥링크는 알림함으로 이동")
    func alertRouteMovesToAlertBox() async throws {
        let router = DeeplinkRouteClient.liveValue
        let store = makeStore(deeplinkRouteClient: router)

        await store.send(.view(.onAppear))
        await router.routeTo(URL(string: "pokit://alert"))

        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.delegate.알림함이동) {
            $0.path.append(.알림함(.init()))
        }

        #expect(isAlertPathTop(in: store.state))

        await store.skipInFlightEffects()
    }

    @Test("포킷 shared(contentId)는 카테고리 진입 후 contentDetail을 연다")
    func sharedRouteWithContentOpensContentDetail() async throws {
        let router = DeeplinkRouteClient.liveValue
        var initialState = MainTabFeature.State()
        initialState.selectedTab = .recommend
        let store = makeStore(
            initialState: initialState,
            deeplinkRouteClient: router
        )

        await store.send(.view(.onAppear))
        await router.routeTo(URL(string: "pokit://shared?categoryId=2&contentId=777"))

        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.async.포킷_딥링크_처리)
        await store.receive(\.inner.포킷_딥링크_이동) {
            $0.path.append(.카테고리상세(.init(
                type: .참여,
                category: makeCategory(id: 2, name: "UITest-Category-2")
            )))
            $0.contentDetail = .init(contentId: 777)
        }

        #expect(topCategoryID(in: store.state) == 2)
        #expect(store.state.contentDetail == .init(contentId: 777))

        await store.skipInFlightEffects()
    }

    @Test("포킷 shared(userId)는 카테고리 진입 후 참여인원 시트를 연다")
    func sharedRouteWithUserOpensParticipantsSheet() async throws {
        let router = DeeplinkRouteClient.liveValue
        var initialState = MainTabFeature.State()
        initialState.selectedTab = .recommend
        let store = makeStore(
            initialState: initialState,
            deeplinkRouteClient: router
        )

        await store.send(.view(.onAppear))
        await router.routeTo(URL(string: "pokit://shared?categoryId=2&userId=999"))

        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.async.포킷_딥링크_처리)
        await store.receive(\.inner.포킷_딥링크_이동) {
            $0.path.append(.카테고리상세(.init(
                type: .참여,
                category: makeCategory(id: 2, name: "UITest-Category-2")
            )))
        }

        let categoryPathID = try #require(store.state.path.ids.last)

        await store.receive(\.path[id: categoryPathID].카테고리상세.view.참여인원_버튼_눌렀을때)
        await store.receive(\.path[id: categoryPathID].카테고리상세.inner.참여인원_시트_활성화)

        await store.skipInFlightEffects()
    }

    @Test("앱 실행 직후 queued shared 딥링크도 정상 소비된다")
    func queuedSharedRouteBeforeOnAppearIsConsumed() async throws {
        let router = DeeplinkRouteClient.liveValue
        await router.routeTo(URL(string: "pokit://shared?categoryId=2&contentId=777"))

        let store = makeStore(deeplinkRouteClient: router)
        await store.send(.view(.onAppear))

        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.async.포킷_딥링크_처리)
        await store.receive(\.inner.포킷_딥링크_이동) {
            $0.path.append(.카테고리상세(.init(
                type: .참여,
                category: makeCategory(id: 2, name: "UITest-Category-2")
            )))
            $0.contentDetail = .init(contentId: 777)
        }

        #expect(topCategoryID(in: store.state) == 2)

        await store.skipInFlightEffects()
    }

    @Test("같은 카테고리로 재라우팅하면 스택이 중복 push되지 않는다")
    func rerouteToSameCategoryDoesNotDuplicatePush() async throws {
        let router = DeeplinkRouteClient.liveValue
        let store = makeStore(deeplinkRouteClient: router)

        await store.send(.view(.onAppear))
        await router.routeTo(URL(string: "pokit://shared?categoryId=2&contentId=777"))

        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.async.포킷_딥링크_처리)
        await store.receive(\.inner.포킷_딥링크_이동) {
            $0.path.append(.카테고리상세(.init(
                type: .참여,
                category: makeCategory(id: 2, name: "UITest-Category-2")
            )))
            $0.contentDetail = .init(contentId: 777)
        }

        let stackCountBeforeReroute = store.state.path.count
        let topPathID = try #require(store.state.path.ids.last)

        await router.routeTo(URL(string: "pokit://shared?categoryId=2&contentId=778"))

        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.async.포킷_딥링크_처리)
        await store.receive(\.inner.포킷_딥링크_이동) {
            $0.contentDetail = .init(contentId: 778)
        }
        await store.receive(\.path[id: topPathID].카테고리상세.inner.타입_변경)
        await store.receive(\.path[id: topPathID].카테고리상세.inner.pagenation_초기화)
        await store.receive(\.path[id: topPathID].카테고리상세.async.카테고리_내_컨텐츠_목록_조회_API)
        await store.receive(\.path[id: topPathID].카테고리상세.async.포킷_초대된_유저_목록_조회_API)

        #expect(store.state.path.count == stackCountBeforeReroute)
        #expect(topCategoryID(in: store.state) == 2)
        #expect(store.state.contentDetail == .init(contentId: 778))

        await store.skipInFlightEffects()
    }

    @Test("다른 카테고리로 재라우팅하면 스택에 추가 이동된다")
    func rerouteToDifferentCategoryAppendsStack() async throws {
        let router = DeeplinkRouteClient.liveValue
        let store = makeStore(deeplinkRouteClient: router)

        await store.send(.view(.onAppear))
        await router.routeTo(URL(string: "pokit://shared?categoryId=2&contentId=777"))

        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.async.포킷_딥링크_처리)
        await store.receive(\.inner.포킷_딥링크_이동) {
            $0.path.append(.카테고리상세(.init(
                type: .참여,
                category: makeCategory(id: 2, name: "UITest-Category-2")
            )))
            $0.contentDetail = .init(contentId: 777)
        }

        await router.routeTo(URL(string: "pokit://shared?categoryId=3&contentId=888"))

        await store.receive(\.inner.딥링크_수신)
        await store.receive(\.async.포킷_딥링크_처리)
        await store.receive(\.inner.포킷_딥링크_이동) {
            $0.path.append(.카테고리상세(.init(
                type: .참여,
                category: makeCategory(id: 3, name: "UITest-Category-3")
            )))
            $0.contentDetail = .init(contentId: 888)
        }

        #expect(categoryIDs(in: store.state) == [2, 3])
        #expect(store.state.contentDetail == .init(contentId: 888))

        await store.skipInFlightEffects()
    }
}

private extension MainTabFeatureDeeplinkTests {
    func makeStore(
        initialState: MainTabFeature.State = .init(),
        deeplinkRouteClient: DeeplinkRouteClient = .liveValue
    ) -> TestStore<MainTabFeature.State, MainTabFeature.Action> {
        let store = TestStore(initialState: initialState) {
            MainTabFeature()
        } withDependencies: {
            $0.applyMainTabDeeplinkTestDependencies(
                deeplinkRouteClient: deeplinkRouteClient
            )
        }
        store.exhaustivity = .off
        return store
    }

    func topCategoryID(in state: MainTabFeature.State) -> Int? {
        guard case let .카테고리상세(categoryState) = state.path.last else {
            return nil
        }
        return categoryState.category.id
    }

    func categoryIDs(in state: MainTabFeature.State) -> [Int] {
        state.path.compactMap { path in
            guard case let .카테고리상세(categoryState) = path else { return nil }
            return categoryState.category.id
        }
    }

    func isAlertPathTop(in state: MainTabFeature.State) -> Bool {
        guard let topPath = state.path.last else { return false }
        if case .알림함 = topPath {
            return true
        }
        return false
    }
}

private func makeCategory(id: Int, name: String) -> BaseCategoryItem {
    .init(
        id: id,
        userId: 100,
        categoryName: name,
        categoryImage: .init(imageId: 2000 + id, imageURL: "https://example.com/category-\(id).png"),
        contentCount: 0,
        createdAt: "",
        openType: .공개,
        keywordType: .default,
        userCount: 2,
        isFavorite: false
    )
}

private func makeSharedCategory(id: Int, name: String) -> BaseCategoryItem {
    .init(
        id: id,
        userId: 0,
        categoryName: name,
        categoryImage: .init(imageId: 2000 + id, imageURL: "https://example.com/category-\(id).png"),
        contentCount: 1,
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

private actor KakaoRouteSpy {
    private var routedURLList: [URL] = []
    private var continuation: AsyncStream<DeeplinkRoute>.Continuation?

    nonisolated var client: DeeplinkRouteClient {
        DeeplinkRouteClient(
            routeTo: { url in
                await self.routeTo(url)
            },
            routeStream: {
                self.makeStream()
            }
        )
    }

    func routedURLs() -> [URL] {
        routedURLList
    }

    private func routeTo(_ url: URL?) {
        guard let url else { return }
        routedURLList.append(url)

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let categoryId = components?
            .queryItems?
            .first(where: { $0.name == "categoryId" })?
            .value
            .flatMap(Int.init) ?? 0
        let shareType = components?
            .queryItems?
            .first(where: { $0.name == "shareType" })?
            .value

        continuation?.yield(.kakaoSharedCategory(
            categoryId: categoryId,
            shareType: shareType
        ))
    }

    nonisolated private func makeStream() -> AsyncStream<DeeplinkRoute> {
        AsyncStream { continuation in
            Task {
                await self.setContinuation(continuation)
            }
        }
    }

    private func setContinuation(
        _ continuation: AsyncStream<DeeplinkRoute>.Continuation
    ) {
        self.continuation = continuation
    }
}
