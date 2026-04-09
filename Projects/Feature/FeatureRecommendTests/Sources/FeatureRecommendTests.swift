import ComposableArchitecture
import CoreKit
import Domain
import Util
import Testing

@testable import FeatureRecommend

@MainActor
struct FeatureRecommendTests {
    @Test("추천목록과 관심사를 불러오면 선택된 관심사가 반영된다")
    func 추천목록과_관심사를_불러오면_선택된_관심사가_반영된다() async throws {
        let store = TestStore(initialState: RecommendFeature.State()) {
            RecommendFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureRecommendTestValue()
            $0[UserClient.self] = .featureRecommendTestValue()
        }

        await store.send(.async(.추천_조회_API))
        await store.receive(\.inner.추천_조회_API_반영) {
            $0.domain.contentList = ContentListInquiryResponse.featureRecommend_pageResponse.toDomain()
            $0.isLoading = false
        }
        await store.send(.async(.관심사_조회_API))
        await store.receive(\.inner.관심사_조회_API_반영) {
            $0.domain.interests = [BaseInterest].featureRecommend_availableInterests
        }
        await store.receive(\.async.유저_관심사_조회_API)
        await store.receive(\.inner.유저_관심사_조회_API_반영) {
            $0.domain.myInterests = [BaseInterest].featureRecommend_myInterests
            $0.selectedInterestList = [
                .featureRecommend_it,
                .featureRecommend_design
            ]
        }
    }

    @Test("신고하기 첫진입시 사유조회후 시트가 열린다")
    func 신고하기_첫진입시_사유조회후_시트가_열린다() async throws {
        let store = TestStore(initialState: RecommendFeature.State()) {
            RecommendFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureRecommendTestValue()
        }
        store.exhaustivity = .off

        await store.send(.inner(.추천_조회_API_반영(.init(
            data: [.featureRecommend_first, .featureRecommend_second],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )))) {
            $0.domain.contentList = BaseContentListInquiry(
                data: [
                    .featureRecommend_first,
                    .featureRecommend_second
                ],
                page: 0,
                size: 10,
                sort: [],
                hasNext: false
            )
            $0.isLoading = false
        }
        await store.send(.view(.신고하기_버튼_눌렀을때(.featureRecommend_first))) {
            $0.pendingReportContent = .featureRecommend_first
        }
        await store.receive(\.inner.컨텐츠_신고사유_조회_API_반영) {
            $0.reportReasons = [
                .featureRecommend_spam,
                .featureRecommend_violent
            ]
            $0.reportContent = .featureRecommend_first
            $0.pendingReportContent = nil
        }
    }

    @Test("신고하기 확인시 목록에서 제거되고 delegate를 보낸다")
    func 신고하기_확인시_목록에서_제거되고_delegate를_보낸다() async throws {
        var initialState = RecommendFeature.State()
        initialState.reportReasons = [
            .featureRecommend_spam,
            .featureRecommend_violent
        ]

        let store = TestStore(initialState: initialState) {
            RecommendFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureRecommendTestValue(
                onReport: { id, request in
                    guard id == 401, request.reportReason == "SPAM" else {
                        preconditionFailure("예상하지 못한 신고 요청입니다: \(id), \(request.reportReason)")
                    }
                }
            )
        }
        store.exhaustivity = .off

        await store.send(.inner(.추천_조회_API_반영(.init(
            data: [.featureRecommend_first, .featureRecommend_second],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )))) {
            $0.domain.contentList = BaseContentListInquiry(
                data: [
                    .featureRecommend_first,
                    .featureRecommend_second
                ],
                page: 0,
                size: 10,
                sort: [],
                hasNext: false
            )
            $0.isLoading = false
        }
        await store.send(.view(.신고하기_버튼_눌렀을때(.featureRecommend_first))) {
            $0.reportContent = .featureRecommend_first
        }
        await store.send(.view(.신고하기_확인_버튼_눌렀을때("SPAM"))) {
            $0.reportContent = nil
            $0.pendingReportContent = nil
        }
        await store.receive(\.inner.컨텐츠_신고_API_반영) {
            $0.domain.contentList.data = [
                .featureRecommend_second
            ]
        }
    }

    @Test("신고사유가 이미있으면 즉시 시트를 연다")
    func 신고사유가_이미있으면_즉시_시트를_연다() async throws {
        var initialState = RecommendFeature.State()
        initialState.reportReasons = [
            .featureRecommend_spam,
            .featureRecommend_violent
        ]

        let store = TestStore(initialState: initialState) {
            RecommendFeature()
        }

        await store.send(.view(.신고하기_버튼_눌렀을때(.featureRecommend_first))) {
            $0.reportContent = .featureRecommend_first
        }
    }

    @Test("추가하기 버튼을 누르면 미분류가 기본선택된 포킷시트를 준비한다")
    func 추가하기_버튼을_누르면_미분류가_기본선택된_포킷시트를_준비한다() async throws {
        let store = TestStore(initialState: RecommendFeature.State()) {
            RecommendFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featureRecommendTestValue()
        }
        store.exhaustivity = .off

        await store.send(.view(.추가하기_버튼_눌렀을때(.featureRecommend_first))) {
            $0.addContent = .featureRecommend_first
            $0.showSelectSheet = true
        }
        await store.receive(\.inner.카테고리_목록_조회_API_반영) {
            $0.domain.categoryListInQuiry = BaseCategoryListInquiry(
                data: [BaseCategoryItem].featureRecommend_sortedPokits,
                page: 0,
                size: 30,
                sort: CategoryListInquiryResponse.featureRecommend_categoryListResponse.toDomain().sort,
                hasNext: false
            )
            $0.selectedPokit = [BaseCategoryItem].featureRecommend_sortedPokits.first
        }
    }

    @Test("포킷선택후 저장완료 delegate를 보낸다")
    func 포킷선택후_저장완료_delegate를_보낸다() async throws {
        var initialState = RecommendFeature.State()
        initialState.selectedPokit = .featureRecommend_category
        initialState.addContent = .featureRecommend_first
        initialState.showSelectSheet = true

        let store = TestStore(initialState: initialState) {
            RecommendFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureRecommendTestValue(
                onAdd: { request in
                    let categoryId = request.featureRecommend_categoryId
                    guard categoryId == 21 else {
                        preconditionFailure("예상하지 못한 저장 요청 포킷 ID입니다: \(categoryId)")
                    }
                    return .featureRecommend_addResponse
                }
            )
        }

        await store.send(
            RecommendFeature.Action.view(
                .포킷선택_항목_눌렀을때(pokit: BaseCategoryItem.featureRecommend_category)
            )
        ) {
            $0.selectedPokit = BaseCategoryItem.featureRecommend_category
            $0.showSelectSheet = false
        }
        await store.receive(\.delegate.저장하기_완료) {
            $0.addContent = nil
        }
    }

    @Test("관심사 3개 선택 시 selectedInterestList에 3개가 반영된다")
    func 관심사_3개_선택_시_selectedInterestList에_3개가_반영된다() async throws {
        var initialState = RecommendFeature.State()
        initialState.showKeywordSheet = true

        let store = TestStore(initialState: initialState) {
            RecommendFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureRecommendTestValue()
            $0[UserClient.self] = .featureRecommendTestValue(
                onInterestUpdate: { request in
                    guard request.interests.count == 3 else {
                        preconditionFailure("관심사는 3개여야 합니다: \(request.interests.count)")
                    }
                }
            )
        }
        store.exhaustivity = .off

        let threeInterests: Set<BaseInterest> = [
            .featureRecommend_it,
            .featureRecommend_design,
            .featureRecommend_place
        ]
        await store.send(.view(.키워드_선택_버튼_눌렀을때(threeInterests))) {
            $0.showKeywordSheet = false
            $0.selectedInterest = nil
            $0.selectedInterestList = threeInterests
        }
    }

    @Test("관심사 3개 초과 선택은 허용되지 않는다")
    func 관심사_3개_초과_선택은_허용되지_않는다() async throws {
        var initialState = RecommendFeature.State()
        initialState.showKeywordSheet = true

        let store = TestStore(initialState: initialState) {
            RecommendFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureRecommendTestValue()
            $0[UserClient.self] = .featureRecommendTestValue(
                onInterestUpdate: { request in
                    guard request.interests.count == 4 else {
                        preconditionFailure("예상하지 못한 관심사 개수: \(request.interests.count)")
                    }
                }
            )
        }
        store.exhaustivity = .off

        /// 뷰에서 3개 제한을 하므로 리듀서에는 최대 3개만 전달되어야 하지만,
        /// 만약 4개가 전달되었을 때 selectedInterestList에 그대로 반영됨을 확인
        let fourInterests: Set<BaseInterest> = [
            .featureRecommend_it,
            .featureRecommend_design,
            .featureRecommend_place,
            .featureRecommend_travel
        ]
        await store.send(.view(.키워드_선택_버튼_눌렀을때(fourInterests))) {
            $0.showKeywordSheet = false
            $0.selectedInterest = nil
            $0.selectedInterestList = fourInterests
        }
    }

    @Test("신고 확인시 컨텐츠가 목록에서 제거되고 delegate를 수신한다")
    func 신고_확인시_컨텐츠가_목록에서_제거되고_delegate를_수신한다() async throws {
        var initialState = RecommendFeature.State()
        initialState.reportReasons = [
            .featureRecommend_spam,
            .featureRecommend_violent
        ]

        let store = TestStore(initialState: initialState) {
            RecommendFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureRecommendTestValue(
                onReport: { id, request in
                    guard id == 401, request.reportReason == "VIOLENT" else {
                        preconditionFailure("예상하지 못한 신고 요청입니다: \(id), \(request.reportReason)")
                    }
                }
            )
        }
        store.exhaustivity = .off

        await store.send(.inner(.추천_조회_API_반영(.init(
            data: [.featureRecommend_first, .featureRecommend_second],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )))) {
            $0.domain.contentList = BaseContentListInquiry(
                data: [
                    .featureRecommend_first,
                    .featureRecommend_second
                ],
                page: 0,
                size: 10,
                sort: [],
                hasNext: false
            )
            $0.isLoading = false
        }
        await store.send(.view(.신고하기_버튼_눌렀을때(.featureRecommend_first))) {
            $0.reportContent = .featureRecommend_first
        }
        await store.send(.view(.신고하기_확인_버튼_눌렀을때("VIOLENT"))) {
            $0.reportContent = nil
            $0.pendingReportContent = nil
        }
        await store.receive(\.inner.컨텐츠_신고_API_반영) {
            $0.domain.contentList.data = [
                .featureRecommend_second
            ]
        }
        await store.receive(\.delegate.컨텐츠_신고_API_반영)
    }

    @Test("키워드 선택을 반영하면 시트를 닫고 재조회한다")
    func 키워드_선택을_반영하면_시트를_닫고_재조회한다() async throws {
        var initialState = RecommendFeature.State()
        initialState.showKeywordSheet = true

        let store = TestStore(initialState: initialState) {
            RecommendFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureRecommendTestValue()
            $0[UserClient.self] = .featureRecommendTestValue(
                onInterestUpdate: { request in
                    guard request.interests.count == 3 else {
                        preconditionFailure("예상과 다른 관심사 요청 개수입니다: \(request.interests.count)")
                    }
                }
            )
        }

        let selectedInterests: Set<BaseInterest> = [
            .featureRecommend_it,
            .featureRecommend_design,
            .featureRecommend_place
        ]
        await store.send(.view(.키워드_선택_버튼_눌렀을때(selectedInterests))) {
            $0.showKeywordSheet = false
            $0.selectedInterest = nil
            $0.selectedInterestList = selectedInterests
        }
        await store.receive(\.async.유저_관심사_조회_API)
        await store.receive(\.async.추천_조회_API)
        await store.receive(\.inner.유저_관심사_조회_API_반영)
        await store.receive(\.inner.추천_조회_API_반영) {
            $0.domain.contentList = ContentListInquiryResponse.featureRecommend_pageResponse.toDomain()
            $0.isLoading = false
        }
    }
}
