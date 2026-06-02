import Foundation

import ComposableArchitecture
import CoreKit
import Domain
import Util
import Testing

@testable import FeatureContentDetail

@MainActor
struct FeatureContentDetailTests {
    @Test("뷰가 나타났을 때 내 링크면 수정 가능 상태가 된다")
    func 뷰가_나타났을때_내링크면_수정가능상태가된다() async throws {
        let store = TestStore(initialState: ContentDetailFeature.State(
            content: .featureContentDetail_owned
        )) {
            ContentDetailFeature()
        } withDependencies: {
            $0[UserDefaultsClient.self] = .featureContentDetailTestValue(currentUserId: 100)
        }

        await store.send(.view(.뷰가_나타났을때)) {
            $0.memo = "내 메모"
            $0.currentUserId = 100
            $0.memoTextAreaState = .memo(isReadOnly: false)
        }
    }

    @Test("뷰가 나타났을 때 타인 링크면 읽기 전용 상태가 된다")
    func 뷰가_나타났을때_타인링크면_읽기전용상태가된다() async throws {
        let store = TestStore(initialState: ContentDetailFeature.State(
            content: .featureContentDetail_shared
        )) {
            ContentDetailFeature()
        } withDependencies: {
            $0[UserDefaultsClient.self] = .featureContentDetailTestValue(currentUserId: 100)
        }

        await store.send(.view(.뷰가_나타났을때)) {
            $0.memo = "공유 메모"
            $0.currentUserId = 100
            $0.memoTextAreaState = .memo(isReadOnly: true)
        }
    }

    @Test("신고하기 첫 진입시 신고 사유를 조회한 뒤 시트를 노출한다")
    func 신고하기_첫진입시_신고사유를_조회한뒤_시트를_노출한다() async throws {
        let store = TestStore(initialState: ContentDetailFeature.State(
            content: .featureContentDetail_shared
        )) {
            ContentDetailFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureContentDetailTestValue()
            $0[UserDefaultsClient.self] = .featureContentDetailTestValue(currentUserId: 100)
        }

        await store.send(.view(.뷰가_나타났을때)) {
            $0.memo = "공유 메모"
            $0.currentUserId = 100
            $0.memoTextAreaState = .memo(isReadOnly: true)
        }
        await store.send(.view(.신고하기_버튼_눌렀을때)) {
            $0.shouldPresentReportSheetAfterReasonFetch = true
        }
        await store.receive(\.async.컨텐츠_신고사유_조회_API)
        await store.receive(\.inner.컨텐츠_신고사유_조회_API_반영) {
            $0.reportReasons = [
                .featureContentDetail_spam,
                .featureContentDetail_harmful
            ]
            $0.showReportSheet = true
            $0.shouldPresentReportSheetAfterReasonFetch = false
        }
    }

    @Test("신고하기 확인시 신고 API를 호출하고 완료 팝업을 띄운다")
    func 신고하기_확인시_신고API를_호출하고_완료팝업을_띄운다() async throws {
        var initialState = ContentDetailFeature.State(content: .featureContentDetail_shared)
        initialState.showReportSheet = true

        let store = TestStore(initialState: initialState) {
            ContentDetailFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureContentDetailTestValue(
                onReport: { id, request in
                    guard id == 302, request.reportReason == "SPAM" else {
                        preconditionFailure("예상하지 못한 신고 요청입니다: \(id), \(request.reportReason)")
                    }
                }
            )
        }

        await store.send(.view(.신고하기_확인_버튼_눌렀을때("SPAM"))) {
            $0.showReportSheet = false
            $0.shouldPresentReportSheetAfterReasonFetch = false
        }
        await store.receive(\.async.컨텐츠_신고_API)
        await store.receive(\.inner.링크팝업_활성화) {
            $0.linkPopup = .report(title: "신고가 완료되었습니다")
        }
    }

    @Test("신고 사유가 이미 있으면 즉시 시트를 연다")
    func 신고사유가_이미있으면_즉시_시트를_연다() async throws {
        var initialState = ContentDetailFeature.State(content: .featureContentDetail_shared)
        initialState.reportReasons = [
            .featureContentDetail_spam,
            .featureContentDetail_harmful
        ]

        let store = TestStore(initialState: initialState) {
            ContentDetailFeature()
        }

        await store.send(.view(.신고하기_버튼_눌렀을때)) {
            $0.showReportSheet = true
        }
    }

    @Test("신고 시트를 닫으면 관련 상태를 정리한다")
    func 신고시트를_닫으면_관련상태를_정리한다() async throws {
        var initialState = ContentDetailFeature.State(content: .featureContentDetail_shared)
        initialState.showReportSheet = true
        initialState.shouldPresentReportSheetAfterReasonFetch = true

        let store = TestStore(initialState: initialState) {
            ContentDetailFeature()
        }

        await store.send(.view(.신고시트_해제)) {
            $0.showReportSheet = false
            $0.shouldPresentReportSheetAfterReasonFetch = false
        }
    }

    @Test("내 포킷에 저장하기를 누르면 미분류가 맨 앞으로 재배치된다")
    func 내포킷에_저장하기를_누르면_미분류가_맨앞으로_재배치된다() async throws {
        let store = TestStore(initialState: ContentDetailFeature.State(
            content: .featureContentDetail_shared
        )) {
            ContentDetailFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featureContentDetailTestValue()
        }

        await store.send(.view(.내포킷에_저장하기_버튼_눌렀을때)) {
            $0.showSelectSheet = true
        }
        await store.receive(\.async.카테고리_목록_조회_API)
        await store.receive(\.inner.카테고리_목록_조회_API_반영) {
            $0.pokitList = [BaseCategoryItem].featureContentDetail_sortedPokits
            $0.selectedPokit = [BaseCategoryItem].featureContentDetail_sortedPokits.first
        }
    }

    @Test("TC-18: 내 링크일 때 수정 버튼을 누르면 delegate를 보낸다")
    func 내링크일때_수정버튼을_누르면_delegate를_보낸다() async throws {
        var initialState = ContentDetailFeature.State(
            content: .featureContentDetail_owned
        )
        initialState.currentUserId = 100

        let store = TestStore(initialState: initialState) {
            ContentDetailFeature()
        }

        await store.send(.view(.수정_버튼_눌렀을때))
        await store.receive(\.delegate.editButtonTapped)
    }

    @Test("TC-18: 내 링크일 때 삭제 버튼을 누르면 경고시트를 노출한다")
    func 내링크일때_삭제버튼을_누르면_경고시트를_노출한다() async throws {
        var initialState = ContentDetailFeature.State(
            content: .featureContentDetail_owned
        )
        initialState.currentUserId = 100

        let store = TestStore(initialState: initialState) {
            ContentDetailFeature()
        }

        await store.send(.view(.삭제_버튼_눌렀을때)) {
            $0.showAlert = true
        }
    }

    @Test("TC-19: 타유저 링크일 때 수정 버튼은 무시된다")
    func 타유저링크일때_수정버튼은_무시된다() async throws {
        var initialState = ContentDetailFeature.State(
            content: .featureContentDetail_shared
        )
        initialState.currentUserId = 100

        let store = TestStore(initialState: initialState) {
            ContentDetailFeature()
        }

        await store.send(.view(.수정_버튼_눌렀을때))
        // isMine == false이므로 아무 effect도 발생하지 않는다
    }

    @Test("TC-19: 타유저 링크일 때 삭제 버튼은 무시된다")
    func 타유저링크일때_삭제버튼은_무시된다() async throws {
        var initialState = ContentDetailFeature.State(
            content: .featureContentDetail_shared
        )
        initialState.currentUserId = 100

        let store = TestStore(initialState: initialState) {
            ContentDetailFeature()
        }

        await store.send(.view(.삭제_버튼_눌렀을때))
        // isMine == false이므로 아무 effect도 발생하지 않는다
    }

    @Test("TC-19: 타유저 링크일 때 내포킷에 저장하기가 가능하다")
    func 타유저링크일때_내포킷에_저장하기가_가능하다() async throws {
        var initialState = ContentDetailFeature.State(
            content: .featureContentDetail_shared
        )
        initialState.currentUserId = 100

        let store = TestStore(initialState: initialState) {
            ContentDetailFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featureContentDetailTestValue()
        }

        await store.send(.view(.내포킷에_저장하기_버튼_눌렀을때)) {
            $0.showSelectSheet = true
        }
        await store.receive(\.async.카테고리_목록_조회_API)
        await store.receive(\.inner.카테고리_목록_조회_API_반영) {
            $0.pokitList = [BaseCategoryItem].featureContentDetail_sortedPokits
            $0.selectedPokit = [BaseCategoryItem].featureContentDetail_sortedPokits.first
        }
    }

    @Test("TC-19: 타유저 링크일 때 신고하기가 가능하다")
    func 타유저링크일때_신고하기가_가능하다() async throws {
        var initialState = ContentDetailFeature.State(
            content: .featureContentDetail_shared
        )
        initialState.currentUserId = 100

        let store = TestStore(initialState: initialState) {
            ContentDetailFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureContentDetailTestValue()
        }

        await store.send(.view(.신고하기_버튼_눌렀을때)) {
            $0.shouldPresentReportSheetAfterReasonFetch = true
        }
        await store.receive(\.async.컨텐츠_신고사유_조회_API)
        await store.receive(\.inner.컨텐츠_신고사유_조회_API_반영) {
            $0.reportReasons = [
                .featureContentDetail_spam,
                .featureContentDetail_harmful
            ]
            $0.showReportSheet = true
            $0.shouldPresentReportSheetAfterReasonFetch = false
        }
    }

    @Test("TC-18: 내 링크일 때 메모 키보드 완료시 수정 API를 호출한다")
    func 내링크일때_메모키보드완료시_수정API를_호출한다() async throws {
        var initialState = ContentDetailFeature.State(
            content: .featureContentDetail_owned
        )
        initialState.currentUserId = 100
        initialState.memo = "수정된 메모"

        let store = TestStore(initialState: initialState) {
            ContentDetailFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureContentDetailTestValue(
                onEdit: { contentId, request in
                    guard contentId == "301" else {
                        preconditionFailure("예상하지 못한 수정 요청입니다: \(contentId)")
                    }
                    return .featureContentDetail_ownedResponse
                }
            )
            $0[SwiftSoupClient.self] = .featureContentDetailTestValue()
        }

        store.exhaustivity = .off
        await store.send(.view(.키보드_완료_버튼_눌렀울때))
        await store.receive(\.async.컨텐츠_수정_API)
        await store.receive(\.inner.링크팝업_활성화) {
            $0.linkPopup = .success(title: Constants.메모_수정_완료_문구)
        }
    }

    @Test("TC-19: 타유저 링크일 때 메모 키보드 완료는 무시된다")
    func 타유저링크일때_메모키보드완료는_무시된다() async throws {
        var initialState = ContentDetailFeature.State(
            content: .featureContentDetail_shared
        )
        initialState.currentUserId = 100
        initialState.memo = "타인이 수정 시도"

        let store = TestStore(initialState: initialState) {
            ContentDetailFeature()
        }

        await store.send(.view(.키보드_완료_버튼_눌렀울때))
        // isMine == false이므로 아무 effect도 발생하지 않는다
    }

    @Test("포킷 선택시 컨텐츠를 추가하고 성공 팝업을 띄운다")
    func 포킷선택시_컨텐츠를_추가하고_성공팝업을_띄운다() async throws {
        let store = TestStore(initialState: ContentDetailFeature.State(
            content: .featureContentDetail_shared
        )) {
            ContentDetailFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureContentDetailTestValue(
                onAdd: { request in
                    guard request.categoryId == 12 else {
                        preconditionFailure("예상하지 못한 포킷 추가 요청입니다: \(request.categoryId)")
                    }
                    return .featureContentDetail_sharedResponse
                }
            )
            $0[SwiftSoupClient.self] = .featureContentDetailTestValue()
        }

        await store.send(.view(.포킷선택_항목_눌렀을때(.featureContentDetail_pokit))) {
            $0.selectedPokit = .featureContentDetail_pokit
            $0.showSelectSheet = false
        }
        await store.receive(\.async.컨텐츠_추가_API)
        await store.receive(\.inner.링크팝업_활성화) {
            $0.linkPopup = .success(title: Constants.링크_저장_완료_문구, until: 4)
        }
    }
}
