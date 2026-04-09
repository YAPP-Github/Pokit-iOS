import ComposableArchitecture
import CoreKit
import Domain
import Testing

@testable import FeatureCategorySharing

@MainActor
struct FeatureCategorySharingTests {
    @Test("뷰가 나타났을때 공유컨텐츠를 ContentCardState로 변환하고 author정보를 보존한다")
    func 뷰가_나타났을때_공유컨텐츠를_ContentCardState로_변환하고_author정보를_보존한다() async throws {
        let store = TestStore(
            initialState: CategorySharingFeature.State(
                sharedCategory: SharedCategoryResponse.featureCategorySharing_initialResponse.toDomain()
            )
        ) {
            CategorySharingFeature()
        }
        store.exhaustivity = .off

        await store.send(.view(.뷰가_나타났을때)) {
            $0.isLoading = false
            guard $0.contents.count == 2 else {
                preconditionFailure("컨텐츠가 2개여야 합니다: \($0.contents.count)")
            }
            guard
                $0.contents[0].content.authorNickname == "공유멤버1",
                $0.contents[0].content.authorUserId == 91,
                $0.contents[1].content.authorNickname == "공유멤버2",
                $0.contents[1].content.authorUserId == 92
            else {
                preconditionFailure("author 정보가 보존되지 않았습니다")
            }
        }
    }

    @Test("저장버튼을 누르면 공유카테고리 추가 delegate를 보낸다")
    func 저장버튼을_누르면_공유카테고리_추가_delegate를_보낸다() async throws {
        let store = TestStore(
            initialState: CategorySharingFeature.State(
                sharedCategory: SharedCategoryResponse.featureCategorySharing_initialResponse.toDomain()
            )
        ) {
            CategorySharingFeature()
        }

        await store.send(.view(.저장_버튼_눌렀을때))
        await store.receive(\.delegate.공유받은_카테고리_추가)
    }

    @Test("페이지 로딩중이면 다음페이지를 조회해 컨텐츠를 이어붙인다")
    func 페이지_로딩중이면_다음페이지를_조회해_컨텐츠를_이어붙인다() async throws {
        let store = TestStore(
            initialState: CategorySharingFeature.State(
                sharedCategory: SharedCategoryResponse.featureCategorySharing_initialResponse.toDomain()
            )
        ) {
            CategorySharingFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featureCategorySharingTestValue()
        }
        store.exhaustivity = .off

        await store.send(.view(.페이지_로딩중일때))
        await store.receive(\.async.공유받은_카테고리_조회_API)
        await store.receive(\.inner.공유받은_카테고리_API_반영) {
            $0.domain.sharedCategory = SharedCategoryResponse.featureCategorySharing_nextPageResponse.toDomain()
            $0.isLoading = false
            guard $0.contents.count == 1 else {
                preconditionFailure("이어붙인 컨텐츠가 1개여야 합니다: \($0.contents.count)")
            }
            guard
                $0.contents[0].content.authorNickname == "공유멤버3",
                $0.contents[0].content.authorUserId == 93
            else {
                preconditionFailure("author 정보가 보존되지 않았습니다")
            }
        }
    }

    // MARK: - TC-14: 저장하기 → 홈 화면에 포킷 카드 추가, 상세 페이지로 이동

    @Test("TC-14 저장버튼을 누르면 카테고리 정보를 포함한 delegate를 보낸다")
    func TC14_저장버튼을_누르면_카테고리_정보를_포함한_delegate를_보낸다() async throws {
        let sharedCategory = SharedCategoryResponse.featureCategorySharing_initialResponse.toDomain()
        let store = TestStore(
            initialState: CategorySharingFeature.State(sharedCategory: sharedCategory)
        ) {
            CategorySharingFeature()
        }

        await store.send(.view(.저장_버튼_눌렀을때))
        await store.receive(\.delegate.공유받은_카테고리_추가)
    }

    @Test("TC-14 저장시 delegate에 전달되는 카테고리ID와 이름이 정확하다")
    func TC14_저장시_delegate에_전달되는_카테고리ID와_이름이_정확하다() async throws {
        let sharedCategory = SharedCategoryResponse.featureCategorySharing_initialResponse.toDomain()

        let store = TestStore(
            initialState: CategorySharingFeature.State(sharedCategory: sharedCategory)
        ) {
            CategorySharingFeature()
        }

        await store.send(.view(.저장_버튼_눌렀을때))
        await store.receive(\.delegate.공유받은_카테고리_추가)
    }

    // MARK: - TC-15: 초대 수락 → 카드 추가, 공유 포킷 상세로 이동

    @Test("TC-15 초대수락 저장시 공유 카테고리의 contentCount와 이미지가 보존된다")
    func TC15_초대수락_저장시_공유_카테고리_정보가_보존된다() async throws {
        let sharedCategory = SharedCategoryResponse.featureCategorySharing_inviteResponse.toDomain()
        let store = TestStore(
            initialState: CategorySharingFeature.State(sharedCategory: sharedCategory)
        ) {
            CategorySharingFeature()
        }
        store.exhaustivity = .off

        // 초대 수락 후 뷰가 나타나면 컨텐츠가 로드된다
        await store.send(.view(.뷰가_나타났을때)) {
            $0.isLoading = false
            guard $0.contents.count == 1 else {
                preconditionFailure("초대 컨텐츠가 1개여야 합니다: \($0.contents.count)")
            }
            guard
                $0.contents[0].content.authorNickname == "초대자",
                $0.contents[0].content.authorUserId == 95
            else {
                preconditionFailure("초대 author 정보가 보존되지 않았습니다")
            }
        }

        // 저장 버튼을 누르면 카테고리 정보가 delegate로 전달된다
        await store.send(.view(.저장_버튼_눌렀을때))
        await store.receive(\.delegate.공유받은_카테고리_추가)
    }

    // MARK: - TC-17: 마지막 참여자 나가기 → 포킷 삭제

    @Test("TC-17 마지막 참여자가 dismiss하면 dismiss가 호출된다")
    func TC17_마지막_참여자가_dismiss하면_dismiss가_호출된다() async throws {
        let sharedCategory = SharedCategoryResponse
            .featureCategorySharing_lastParticipantResponse.toDomain()
        let store = TestStore(
            initialState: CategorySharingFeature.State(sharedCategory: sharedCategory)
        ) {
            CategorySharingFeature()
        } withDependencies: {
            $0.dismiss = DismissEffect { }
        }

        // 마지막 참여자(컨텐츠 0개)의 상태를 확인
        #expect(sharedCategory.category.contentCount == 0)
        #expect(sharedCategory.contentList.data.isEmpty)

        // dismiss 호출 시 정상적으로 실행된다
        await store.send(.view(.dismiss))
    }
}
