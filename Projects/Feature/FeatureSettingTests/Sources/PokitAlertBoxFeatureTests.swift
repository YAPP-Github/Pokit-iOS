import ComposableArchitecture
import CoreKit
import Domain
import Foundation
import Testing
import Util

@testable import FeatureSetting

@MainActor
struct PokitAlertBoxFeatureTests {
    private actor RouteRecorder {
        private var routes: [String] = []

        func append(_ url: URL?) {
            routes.append(url?.absoluteString ?? "nil")
        }

        func values() -> [String] {
            routes
        }
    }

    // MARK: - TC-26: 알림함 진입 → 최신순 정렬 노출

    @Test("TC-26: 알림함 진입 시 createdAt desc 정렬로 조회하고 최신순 노출한다")
    func TC26_알림함_진입시_최신순으로_알림목록을_조회한다() async throws {
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue(
                firstPage: .featureSetting_firstPageResponse,
                nextPage: .featureSetting_nextPageResponse,
                onRead: { _ in },
                onDelete: { _ in }
            )
            $0[NotificationClient.self].알림_목록_조회 = { request in
                guard
                    request.page == 0,
                    request.size == 10,
                    request.sort == ["createdAt", "desc"]
                else {
                    preconditionFailure("예상하지 못한 알림 목록 조회 요청입니다: \(request)")
                }
                return .featureSetting_firstPageResponse
            }
            $0[PasteboardClient.self] = .noop
        }

        await store.send(.view(.뷰가_나타났을때))
        await store.receive(\.async.뷰가_나타났을때_알람_목록_조회_API)
        await store.receive(\.async.클립보드_감지)
        await store.receive(\.inner.뷰가_나타났을때_알람_목록_조회_API_반영) {
            $0.notifications = .init(
                data: [.featureSetting_unread, .featureSetting_read],
                page: 0,
                size: 10,
                sort: featureSetting_defaultSort,
                hasNext: true
            )
            $0.isLoading = false
            guard
                $0.alertContents?[id: 1]?.notificationType == "LINK_ADDED",
                $0.alertContents?[id: 1]?.title == "'공유 포킷'에 링크가 추가되었어요",
                $0.alertContents?[id: 2]?.notificationType == "MEMBER_JOINED",
                $0.alertContents?[id: 2]?.title == "새로운 멤버가 참여했어요"
            else {
                preconditionFailure("알림 유형별 문구가 예상과 다릅니다: \($0.alertContents?.elements ?? [])")
            }
        }
    }

    // MARK: - TC-27: 알림 0개 → empty state

    @Test("TC-27: 알림이 없으면 empty 상태를 노출한다")
    func TC27_알림이_없으면_empty상태를_노출한다() async throws {
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue(
                firstPage: .featureSetting_emptyResponse
            )
            $0[PasteboardClient.self] = .noop
        }

        await store.send(.view(.뷰가_나타났을때))
        await store.receive(\.async.뷰가_나타났을때_알람_목록_조회_API)
        await store.receive(\.async.클립보드_감지)
        await store.receive(\.inner.뷰가_나타났을때_알람_목록_조회_API_반영) {
            $0.notifications = .init(
                data: [],
                page: 0,
                size: 10,
                sort: featureSetting_defaultSort,
                hasNext: false
            )
            $0.isLoading = false
            /// alertContents가 빈 배열이면 PokitCaution(type: .알림없음)이 노출됨
            guard let alertContents = $0.alertContents, alertContents.isEmpty else {
                preconditionFailure("알림이 0개일 때 alertContents가 빈 배열이어야 합니다")
            }
        }
    }

    // MARK: - TC-28: 무한스크롤 10개 단위 (pagination)

    @Test("TC-28: 첫 페이지 10개 로드 후 스크롤하면 다음 페이지가 이어붙는다")
    func TC28_무한스크롤_10개단위_페이지네이션() async throws {
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue(
                firstPage: .featureSetting_fullFirstPageResponse,
                nextPage: .featureSetting_secondPageResponse
            )
        }

        /// 첫 페이지 10개 로드
        await store.send(.inner(.뷰가_나타났을때_알람_목록_조회_API_반영(
            .featureSetting_fullFirstPage
        ))) {
            $0.notifications = .featureSetting_fullFirstPage
            $0.isLoading = false
            guard $0.alertContents?.count == 10 else {
                preconditionFailure("첫 페이지 항목 수가 10이 아닙니다: \($0.alertContents?.count ?? -1)")
            }
        }

        /// hasNext == true 이므로 pagination 트리거
        await store.send(.view(.pagenation))
        await store.receive(\.async.pagenation_알람_목록_조회_API)
        await store.receive(\.inner.pagenation_알람_목록_조회_API_반영) {
            $0.notifications = .init(
                data: (1...10).map { .featureSetting_item(id: $0) }
                    + (11...15).map { .featureSetting_item(id: $0) },
                page: 1,
                size: 10,
                sort: featureSetting_defaultSort,
                hasNext: false
            )
            guard $0.alertContents?.count == 15 else {
                preconditionFailure("페이지네이션 후 항목 수가 15가 아닙니다: \($0.alertContents?.count ?? -1)")
            }
        }

        /// hasNext == false 이므로 추가 pagination은 무동작
        await store.send(.view(.pagenation))
    }

    @Test("TC-28: hasNext가 false이면 pagination 요청이 무시된다")
    func TC28_hasNext가_false이면_pagination이_무시된다() async throws {
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue()
        }

        await store.send(.inner(.뷰가_나타났을때_알람_목록_조회_API_반영(.init(
            data: [.featureSetting_unread],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )))) {
            $0.notifications = .init(
                data: [.featureSetting_unread],
                page: 0,
                size: 10,
                sort: [],
                hasNext: false
            )
            $0.isLoading = false
        }

        /// hasNext == false → pagenation 액션 전송해도 async 액션 발생하지 않음
        await store.send(.view(.pagenation))
    }

    // MARK: - TC-30: 알림함 재진입 → 목록 새로고침 (읽음 API는 미호출)

    @Test("TC-30: 알림함 재진입 시 목록을 다시 조회하되 읽음 API는 호출하지 않는다")
    func TC30_재진입시_목록_새로고침_읽음API_미호출() async throws {
        var fetchCount = 0
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue(
                onRead: { id in
                    preconditionFailure("재진입만으로 읽음 처리되면 안 됩니다: \(id)")
                }
            )
            $0[NotificationClient.self].알림_목록_조회 = { _ in
                fetchCount += 1
                return .featureSetting_firstPageResponse
            }
            $0[PasteboardClient.self] = .noop
        }

        /// 첫 번째 진입
        await store.send(.view(.뷰가_나타났을때))
        await store.receive(\.async.뷰가_나타났을때_알람_목록_조회_API)
        await store.receive(\.async.클립보드_감지)
        await store.receive(\.inner.뷰가_나타났을때_알람_목록_조회_API_반영) {
            $0.notifications = .init(
                data: [.featureSetting_unread, .featureSetting_read],
                page: 0,
                size: 10,
                sort: featureSetting_defaultSort,
                hasNext: true
            )
            $0.isLoading = false
        }

        /// 두 번째 진입 (재진입) — 상태가 동일하므로 trailing closure 생략
        await store.send(.view(.뷰가_나타났을때))
        await store.receive(\.async.뷰가_나타났을때_알람_목록_조회_API)
        await store.receive(\.async.클립보드_감지)
        await store.receive(\.inner.뷰가_나타났을때_알람_목록_조회_API_반영)

        /// 알림_목록_조회가 두 번 호출되었는지 확인
        guard fetchCount == 2 else {
            preconditionFailure("재진입 시 목록 조회가 2번 호출되어야 합니다. 실제: \(fetchCount)")
        }
    }

    // MARK: - TC-32: 특정 알림 클릭 → 읽음 처리 API

    @Test("TC-32: 안읽은 알림을 클릭하면 읽음 처리 API가 호출되고 isRead가 true로 변경된다")
    func TC32_안읽음_알림_클릭시_읽음처리_API_호출() async throws {
        var readCalledWithId: Int?
        let routeRecorder = RouteRecorder()
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue(
                onRead: { id in
                    readCalledWithId = id
                }
            )
            $0[DeeplinkRouteClient.self].routeTo = { url in
                await routeRecorder.append(url)
            }
        }

        /// 데이터 세팅
        await store.send(.inner(.뷰가_나타났을때_알람_목록_조회_API_반영(.init(
            data: [.featureSetting_unread, .featureSetting_read],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )))) {
            $0.notifications = .init(
                data: [.featureSetting_unread, .featureSetting_read],
                page: 0,
                size: 10,
                sort: [],
                hasNext: false
            )
            $0.isLoading = false
        }

        /// 안읽은 알림(id=1) 클릭
        let task = await store.send(.view(.알람_항목_선택했을때(item: .featureSetting_unread)))
        await store.receive(\.async.알람_읽음_API)
        await store.receive(\.inner.알람_읽음_API_반영) {
            $0.notifications.data[0].isRead = true
        }
        await task.finish()

        /// 읽음 API가 정확한 ID로 호출되었는지 확인
        guard readCalledWithId == 1 else {
            preconditionFailure("읽음 API가 id=1로 호출되어야 합니다. 실제: \(String(describing: readCalledWithId))")
        }
    }

    @Test("TC-32: 이미 읽은 알림을 클릭하면 읽음 API를 호출하지 않는다")
    func TC32_이미_읽은_알림_클릭시_읽음API_미호출() async throws {
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue(
                onRead: { id in
                    preconditionFailure("이미 읽은 알림에서 읽음 API가 호출되면 안 됩니다: \(id)")
                }
            )
            $0[DeeplinkRouteClient.self].routeTo = { url in
                guard url?.absoluteString == "pokit://shared?categoryId=10&userId=3" else {
                    preconditionFailure("예상하지 못한 deeplink 입니다: \(url?.absoluteString ?? "nil")")
                }
            }
        }

        await store.send(.inner(.뷰가_나타났을때_알람_목록_조회_API_반영(.init(
            data: [.featureSetting_unread, .featureSetting_read],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )))) {
            $0.notifications = .init(
                data: [.featureSetting_unread, .featureSetting_read],
                page: 0,
                size: 10,
                sort: [],
                hasNext: false
            )
            $0.isLoading = false
        }
        let task = await store.send(.view(.알람_항목_선택했을때(item: .featureSetting_read)))
        await task.finish()
    }

    // MARK: - TC-35: 알림 클릭 → 딥링크별 페이지 이동

    @Test("TC-35: CONTENT_DETAIL 딥링크 알림 클릭 시 해당 URL로 라우팅된다")
    func TC35_CONTENT_DETAIL_딥링크_라우팅() async throws {
        let routeRecorder = RouteRecorder()
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue(
                onRead: { _ in }
            )
            $0[DeeplinkRouteClient.self].routeTo = { url in
                await routeRecorder.append(url)
            }
        }

        await store.send(.inner(.뷰가_나타났을때_알람_목록_조회_API_반영(.init(
            data: [.featureSetting_contentDetailDeeplink],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )))) {
            $0.notifications = .init(
                data: [.featureSetting_contentDetailDeeplink],
                page: 0,
                size: 10,
                sort: [],
                hasNext: false
            )
            $0.isLoading = false
        }

        let task = await store.send(.view(.알람_항목_선택했을때(item: .featureSetting_contentDetailDeeplink)))
        await store.receive(\.async.알람_읽음_API)
        await store.receive(\.inner.알람_읽음_API_반영) {
            $0.notifications.data[0].isRead = true
        }
        await task.finish()

        let routes = await routeRecorder.values()
        guard routes == ["pokit://content-detail?contentId=99"] else {
            preconditionFailure("CONTENT_DETAIL 라우팅 결과가 예상과 다릅니다: \(routes)")
        }
    }

    @Test("TC-35: USER_LIST 딥링크 알림 클릭 시 해당 URL로 라우팅된다")
    func TC35_USER_LIST_딥링크_라우팅() async throws {
        let routeRecorder = RouteRecorder()
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue(
                onRead: { _ in }
            )
            $0[DeeplinkRouteClient.self].routeTo = { url in
                await routeRecorder.append(url)
            }
        }

        await store.send(.inner(.뷰가_나타났을때_알람_목록_조회_API_반영(.init(
            data: [.featureSetting_userListDeeplink],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )))) {
            $0.notifications = .init(
                data: [.featureSetting_userListDeeplink],
                page: 0,
                size: 10,
                sort: [],
                hasNext: false
            )
            $0.isLoading = false
        }

        let task = await store.send(.view(.알람_항목_선택했을때(item: .featureSetting_userListDeeplink)))
        await store.receive(\.async.알람_읽음_API)
        await store.receive(\.inner.알람_읽음_API_반영) {
            $0.notifications.data[0].isRead = true
        }
        await task.finish()

        let routes = await routeRecorder.values()
        guard routes == ["pokit://shared?categoryId=20&userId=5"] else {
            preconditionFailure("USER_LIST 라우팅 결과가 예상과 다릅니다: \(routes)")
        }
    }

    @Test("TC-35: deepLink가 nil인 알림 클릭 시 라우팅하지 않는다")
    func TC35_deepLink가_nil이면_라우팅하지않는다() async throws {
        let routeRecorder = RouteRecorder()
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue(
                onRead: { _ in }
            )
            $0[DeeplinkRouteClient.self].routeTo = { url in
                await routeRecorder.append(url)
            }
        }

        await store.send(.inner(.뷰가_나타났을때_알람_목록_조회_API_반영(.init(
            data: [.featureSetting_noDeeplink],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )))) {
            $0.notifications = .init(
                data: [.featureSetting_noDeeplink],
                page: 0,
                size: 10,
                sort: [],
                hasNext: false
            )
            $0.isLoading = false
        }

        let task = await store.send(.view(.알람_항목_선택했을때(item: .featureSetting_noDeeplink)))
        await store.receive(\.async.알람_읽음_API)
        await store.receive(\.inner.알람_읽음_API_반영) {
            $0.notifications.data[0].isRead = true
        }
        await task.finish()

        let routes = await routeRecorder.values()
        guard routes.isEmpty else {
            preconditionFailure("deepLink가 nil일 때 라우팅이 발생하면 안 됩니다: \(routes)")
        }
    }

    // MARK: - TC-29, TC-33, TC-34, TC-36~40: Manual QA Required

    // TC-29: 안 읽은 알림 배경색 (orange._50) → UI 렌더링 테스트로 TestStore로 검증 불가, 수동 QA 필요
    // TC-33: 앱이 foreground일 때 push 수신 무시 → 시스템 레벨 푸시 테스트로 TestStore 범위 밖
    // TC-34: 앱이 background → foreground 전환 시 알림 갱신 → 앱 생명주기 테스트, 수동 QA 필요
    // TC-36: 알림 설정 on/off → 시스템 설정 연동, 수동 QA 필요
    // TC-37: 알림 권한 미허용 시 알림 미수신 → 시스템 권한 테스트, 수동 QA 필요
    // TC-38: 로그아웃 후 알림 미수신 → 인증 상태 연동, 수동 QA 필요
    // TC-39: 알림 탭 후 앱 미설치 시 스토어 이동 → 딥링크 fallback, 수동 QA 필요
    // TC-40: 알림 수신 시 뱃지 표시 → 시스템 뱃지 연동, 수동 QA 필요

    // MARK: - 기존 보조 테스트

    @Test("알림함 진입만으로는 읽음 API를 호출하지 않는다")
    func 알림함_진입만으로는_읽음API를_호출하지않는다() async throws {
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue(
                onRead: { id in
                    preconditionFailure("알림함 진입만으로 읽음 처리되면 안 됩니다: \(id)")
                }
            )
            $0[PasteboardClient.self] = .noop
        }

        await store.send(.view(.뷰가_나타났을때))
        await store.receive(\.async.뷰가_나타났을때_알람_목록_조회_API)
        await store.receive(\.async.클립보드_감지)
        await store.receive(\.inner.뷰가_나타났을때_알람_목록_조회_API_반영) {
            $0.notifications = .init(
                data: [.featureSetting_unread, .featureSetting_read],
                page: 0,
                size: 10,
                sort: featureSetting_defaultSort,
                hasNext: true
            )
            $0.isLoading = false
        }
    }

    @Test("pagination은 추가 페이지를 이어붙인다")
    func pagination은_추가페이지를_이어붙인다() async throws {
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue()
        }

        await store.send(.inner(.뷰가_나타났을때_알람_목록_조회_API_반영(.init(
            data: [.featureSetting_unread, .featureSetting_read],
            page: 0,
            size: 10,
            sort: [],
            hasNext: true
        )))) {
            $0.notifications = .init(
                data: [.featureSetting_unread, .featureSetting_read],
                page: 0,
                size: 10,
                sort: [],
                hasNext: true
            )
            $0.isLoading = false
        }
        await store.send(.view(.pagenation))
        await store.receive(\.async.pagenation_알람_목록_조회_API)
        await store.receive(\.inner.pagenation_알람_목록_조회_API_반영) {
            $0.notifications = .init(
                data: [
                    .featureSetting_unread,
                    .featureSetting_read,
                    .featureSetting_pagination
                ],
                page: 1,
                size: 10,
                sort: featureSetting_defaultSort,
                hasNext: false
            )
            guard $0.alertContents?[id: 3]?.title == "'공유 포킷' 포킷 사용이 제한되었어요" else {
                preconditionFailure("페이지네이션된 알림 문구가 예상과 다릅니다: \($0.alertContents?.elements ?? [])")
            }
        }
    }

    @Test("pagination만으로는 읽음 API를 호출하지 않는다")
    func pagination만으로는_읽음API를_호출하지않는다() async throws {
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue(
                onRead: { id in
                    preconditionFailure("페이지네이션만으로 읽음 처리되면 안 됩니다: \(id)")
                }
            )
        }

        await store.send(.inner(.뷰가_나타났을때_알람_목록_조회_API_반영(.init(
            data: [.featureSetting_unread, .featureSetting_read],
            page: 0,
            size: 10,
            sort: [],
            hasNext: true
        )))) {
            $0.notifications = .init(
                data: [.featureSetting_unread, .featureSetting_read],
                page: 0,
                size: 10,
                sort: [],
                hasNext: true
            )
            $0.isLoading = false
        }
        await store.send(.view(.pagenation))
        await store.receive(\.async.pagenation_알람_목록_조회_API)
        await store.receive(\.inner.pagenation_알람_목록_조회_API_반영) {
            $0.notifications = .init(
                data: [
                    .featureSetting_unread,
                    .featureSetting_read,
                    .featureSetting_pagination
                ],
                page: 1,
                size: 10,
                sort: featureSetting_defaultSort,
                hasNext: false
            )
        }
    }

    @Test("밀어서 삭제하면 목록에서 제거된다")
    func 밀어서_삭제하면_목록에서_제거된다() async throws {
        let store = TestStore(initialState: PokitAlertBoxFeature.State()) {
            PokitAlertBoxFeature()
        } withDependencies: {
            $0[NotificationClient.self] = .featureSettingTestValue(
                onDelete: { id in
                    guard id == 1 else {
                        preconditionFailure("예상하지 못한 삭제 알림 ID입니다: \(id)")
                    }
                }
            )
        }

        await store.send(.inner(.뷰가_나타났을때_알람_목록_조회_API_반영(.init(
            data: [.featureSetting_unread, .featureSetting_read],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )))) {
            $0.notifications = .init(
                data: [.featureSetting_unread, .featureSetting_read],
                page: 0,
                size: 10,
                sort: [],
                hasNext: false
            )
            $0.isLoading = false
        }
        await store.send(.view(.밀어서_삭제했을때(item: .featureSetting_unread)))
        await store.receive(\.async.알람_삭제_API)
        await store.receive(\.inner.알람_삭제_API_반영) {
            $0.notifications.data = [.featureSetting_read]
        }
    }
}
