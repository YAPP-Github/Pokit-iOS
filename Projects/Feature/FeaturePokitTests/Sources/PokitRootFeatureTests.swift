import ComposableArchitecture
import CoreKit
import Domain
import Testing

@testable import FeaturePokit

@MainActor
struct PokitRootFeatureTests {
    @Test("뷰가 나타났을때 포킷탭이면 카테고리 목록을 초기 조회한다")
    func 뷰가_나타났을때_포킷탭이면_카테고리목록을_초기조회한다() async throws {
        let store = TestStore(initialState: PokitRootFeature.State()) {
            PokitRootFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featurePokitTestValue()
        }

        await store.send(.view(.뷰가_나타났을때))
        await store.receive(\.inner.페이지네이션_초기화) {
            $0.domain.pageable.page = 0
        }
        await store.receive(\.async.카테고리_조회_API)
        await store.receive(\.inner.카테고리_조회_API_반영) {
            $0.domain.categoryList = BaseCategoryListInquiry(
                data: [
                    .featurePokit_favoriteCategory,
                    .featurePokit_sharedCategory
                ],
                page: 0,
                size: 10,
                sort: CategoryListInquiryResponse.featurePokit_categoryListResponse.toDomain().sort,
                hasNext: false
            )
        }
    }

    @Test("케밥 삭제 선택시 삭제 시트로 전환된다")
    func 케밥_삭제선택시_삭제시트로_전환된다() async throws {
        var initialState = PokitRootFeature.State()
        initialState.selectedKebobItem = .featurePokit_sharedCategory
        initialState.isKebobSheetPresented = true

        let store = TestStore(initialState: initialState) {
            PokitRootFeature()
        }

        await store.send(.scope(.bottomSheet(.deleteCellButtonTapped)))
        await store.receive(\.inner.카테고리_시트_활성화) {
            $0.isKebobSheetPresented = false
        }
        await store.receive(\.inner.카테고리_삭제_시트_활성화) {
            $0.isPokitDeleteSheetPresented = true
        }
    }

    @Test("미분류 컨텐츠를 누르면 상세 delegate를 보낸다")
    func 미분류_컨텐츠를_누르면_상세_delegate를_보낸다() async throws {
        let store = TestStore(initialState: PokitRootFeature.State()) {
            PokitRootFeature()
        }

        await store.send(.view(.컨텐츠_항목_눌렀을때(.featurePokit_unclassifiedContent)))
        await store.receive(\.delegate.contentDetailTapped)
    }

    @Test("QA 포킷카드 조합을 조회결과에 그대로 보존한다")
    func QA포킷카드_조합을_조회결과에_그대로_보존한다() async throws {
        let store = TestStore(initialState: PokitRootFeature.State()) {
            PokitRootFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featurePokitTestValue(
                categoryListResponse: .featurePokit_qaCategoryListResponse
            )
        }

        await store.send(.async(.카테고리_조회_API)) {
            $0.domain.pageable.page = 0
        }
        await store.receive(\.inner.카테고리_조회_API_반영) {
            $0.domain.categoryList = CategoryListInquiryResponse.featurePokit_qaCategoryListResponse.toDomain()
            guard
                let favorite = $0.categories?[id: 900],
                let privateShared = $0.categories?[id: 903],
                let privateSolo = $0.categories?[id: 904],
                let publicShared = $0.categories?[id: 905],
                let publicSolo = $0.categories?[id: 906]
            else {
                preconditionFailure("QA 포킷 카드 fixture가 상태에 반영되지 않았습니다: \($0.categories?.elements ?? [])")
            }

            guard favorite.isFavorite, favorite.contentCount == 0 else {
                preconditionFailure("즐겨찾기 포킷 조건이 보존되지 않았습니다: \(favorite)")
            }
            guard privateShared.openType == .비공개, privateShared.userCount == 2 else {
                preconditionFailure("비공개 공유 포킷 조건이 보존되지 않았습니다: \(privateShared)")
            }
            guard privateSolo.openType == .비공개, privateSolo.userCount == 1 else {
                preconditionFailure("비공개 개인 포킷 조건이 보존되지 않았습니다: \(privateSolo)")
            }
            guard publicShared.openType == .공개, publicShared.userCount == 3 else {
                preconditionFailure("전체공개 공유 포킷 조건이 보존되지 않았습니다: \(publicShared)")
            }
            guard publicSolo.openType == .공개, publicSolo.userCount == 1 else {
                preconditionFailure("전체공개 개인 포킷 조건이 보존되지 않았습니다: \(publicSolo)")
            }
        }
    }

    // MARK: - TC-01: 즐겨찾기 0개일 때도 상단에 고정 노출

    @Test("TC-01 즐겨찾기 포킷이 컨텐츠 0개여도 카테고리 목록에 포함된다")
    func TC01_즐겨찾기_포킷이_컨텐츠_0개여도_카테고리_목록에_포함된다() async throws {
        let store = TestStore(initialState: PokitRootFeature.State()) {
            PokitRootFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featurePokitTestValue(
                categoryListResponse: .featurePokit_favoriteOnlyResponse
            )
        }

        await store.send(.async(.카테고리_조회_API)) {
            $0.domain.pageable.page = 0
        }
        await store.receive(\.inner.카테고리_조회_API_반영) {
            $0.domain.categoryList = CategoryListInquiryResponse
                .featurePokit_favoriteOnlyResponse.toDomain()

            let categories = $0.categories
            #expect(categories != nil, "카테고리 목록이 nil이면 안 됩니다")
            #expect(categories?.count == 1, "즐겨찾기 포킷 1개만 존재해야 합니다")

            let favorite = categories?[id: 900]
            #expect(favorite != nil, "즐겨찾기 포킷이 목록에 존재해야 합니다")
            #expect(favorite?.isFavorite == true)
            #expect(favorite?.contentCount == 0, "컨텐츠 수가 0이어야 합니다")
        }
    }

    // MARK: - TC-02: 비공개 + 공동편집자 있음 → 자물쇠 노출, 편집자 수 노출

    @Test("TC-02 비공개이고 공동편집자가 있으면 자물쇠와 편집자수 조건을 만족한다")
    func TC02_비공개_공동편집자_있음() async throws {
        let store = TestStore(initialState: PokitRootFeature.State()) {
            PokitRootFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featurePokitTestValue(
                categoryListResponse: .featurePokit_tc02Response
            )
        }

        await store.send(.async(.카테고리_조회_API)) {
            $0.domain.pageable.page = 0
        }
        await store.receive(\.inner.카테고리_조회_API_반영) {
            $0.domain.categoryList = CategoryListInquiryResponse
                .featurePokit_tc02Response.toDomain()

            let item = $0.categories?[id: 903]
            #expect(item != nil)
            // 자물쇠 노출 조건: openType == .비공개
            #expect(item?.openType == .비공개, "비공개여야 자물쇠가 노출됩니다")
            // 편집자 수 노출 조건: userCount > 1
            #expect(item?.userCount == 2, "공동편집자가 있으므로 userCount > 1")
            #expect((item?.userCount ?? 0) > 1, "편집자 수가 노출되어야 합니다")
        }
    }

    // MARK: - TC-03: 비공개 + 공동편집자 없음 → 자물쇠 노출, 편집자 수 비노출

    @Test("TC-03 비공개이고 공동편집자가 없으면 자물쇠만 노출되고 편집자수는 비노출이다")
    func TC03_비공개_공동편집자_없음() async throws {
        let store = TestStore(initialState: PokitRootFeature.State()) {
            PokitRootFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featurePokitTestValue(
                categoryListResponse: .featurePokit_tc03Response
            )
        }

        await store.send(.async(.카테고리_조회_API)) {
            $0.domain.pageable.page = 0
        }
        await store.receive(\.inner.카테고리_조회_API_반영) {
            $0.domain.categoryList = CategoryListInquiryResponse
                .featurePokit_tc03Response.toDomain()

            let item = $0.categories?[id: 904]
            #expect(item != nil)
            // 자물쇠 노출 조건: openType == .비공개
            #expect(item?.openType == .비공개, "비공개여야 자물쇠가 노출됩니다")
            // 편집자 수 비노출 조건: userCount <= 1
            #expect(item?.userCount == 1, "공동편집자가 없으므로 userCount == 1")
            #expect((item?.userCount ?? 0) <= 1, "편집자 수가 비노출이어야 합니다")
        }
    }

    // MARK: - TC-04: 전체공개 + 공동편집자 있음 → 자물쇠 비노출, 편집자 수 노출

    @Test("TC-04 전체공개이고 공동편집자가 있으면 자물쇠는 비노출이고 편집자수가 노출된다")
    func TC04_전체공개_공동편집자_있음() async throws {
        let store = TestStore(initialState: PokitRootFeature.State()) {
            PokitRootFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featurePokitTestValue(
                categoryListResponse: .featurePokit_tc04Response
            )
        }

        await store.send(.async(.카테고리_조회_API)) {
            $0.domain.pageable.page = 0
        }
        await store.receive(\.inner.카테고리_조회_API_반영) {
            $0.domain.categoryList = CategoryListInquiryResponse
                .featurePokit_tc04Response.toDomain()

            let item = $0.categories?[id: 905]
            #expect(item != nil)
            // 자물쇠 비노출 조건: openType == .공개
            #expect(item?.openType == .공개, "전체공개이면 자물쇠가 비노출입니다")
            // 편집자 수 노출 조건: userCount > 1
            #expect(item?.userCount == 3, "공동편집자가 있으므로 userCount > 1")
            #expect((item?.userCount ?? 0) > 1, "편집자 수가 노출되어야 합니다")
        }
    }

    // MARK: - TC-05: 전체공개 + 공동편집자 없음 → 자물쇠 비노출, 편집자 수 비노출

    @Test("TC-05 전체공개이고 공동편집자가 없으면 자물쇠와 편집자수 모두 비노출이다")
    func TC05_전체공개_공동편집자_없음() async throws {
        let store = TestStore(initialState: PokitRootFeature.State()) {
            PokitRootFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featurePokitTestValue(
                categoryListResponse: .featurePokit_tc05Response
            )
        }

        await store.send(.async(.카테고리_조회_API)) {
            $0.domain.pageable.page = 0
        }
        await store.receive(\.inner.카테고리_조회_API_반영) {
            $0.domain.categoryList = CategoryListInquiryResponse
                .featurePokit_tc05Response.toDomain()

            let item = $0.categories?[id: 906]
            #expect(item != nil)
            // 자물쇠 비노출 조건: openType == .공개
            #expect(item?.openType == .공개, "전체공개이면 자물쇠가 비노출입니다")
            // 편집자 수 비노출 조건: userCount <= 1
            #expect(item?.userCount == 1, "공동편집자가 없으므로 userCount == 1")
            #expect((item?.userCount ?? 0) <= 1, "편집자 수가 비노출이어야 합니다")
        }
    }

    // MARK: - TC-17: 마지막 참여자 나가기 → 포킷 삭제

    @Test("TC-17 마지막 참여자가 포킷을 삭제하면 카테고리 목록에서 제거된다")
    func TC17_마지막_참여자가_포킷을_삭제하면_목록에서_제거된다() async throws {
        var initialState = PokitRootFeature.State()
        // userCount == 1인 카테고리를 미리 로드된 상태로 설정
        initialState.domain.categoryList = BaseCategoryListInquiry(
            data: [.featurePokit_publicSolo],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )
        initialState.selectedKebobItem = .featurePokit_publicSolo

        let store = TestStore(initialState: initialState) {
            PokitRootFeature()
        } withDependencies: {
            $0[CategoryClient.self].카테고리_삭제 = { _ in }
        }

        // 삭제 확인 버튼을 누르면 목록에서 제거되고 삭제 API가 호출된다
        await store.send(.scope(.deleteBottomSheet(.deleteButtonTapped))) {
            $0.domain.categoryList.data = []
            $0.isPokitDeleteSheetPresented = false
        }
        await store.receive(\.async.카테고리_삭제_API)
    }
}
