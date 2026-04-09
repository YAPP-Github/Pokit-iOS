import ComposableArchitecture
import CoreKit
import DSKit
import Domain
import FeatureContentCard
import Testing

@testable import FeatureCategoryDetail

@MainActor
struct FeatureCategoryDetailTests {
    @Test("케밥버튼을 누르면 카테고리시트를 노출한다")
    func 케밥버튼을_누르면_카테고리시트를_노출한다() async throws {
        let store = TestStore(initialState: CategoryDetailFeature.State(
            type: .참여,
            category: .featureCategoryDetail_sharedCategory
        )) {
            CategoryDetailFeature()
        }

        await store.send(.view(.카테고리_케밥_버튼_눌렀을때))
        await store.receive(\.inner.카테고리_시트_활성화) {
            $0.isCategorySheetPresented = true
        }
    }

    @Test("참여인원 버튼을 누르면 참여인원시트를 노출한다")
    func 참여인원_버튼을_누르면_참여인원시트를_노출한다() async throws {
        let store = TestStore(initialState: CategoryDetailFeature.State(
            type: .참여,
            category: .featureCategoryDetail_sharedCategory
        )) {
            CategoryDetailFeature()
        }

        await store.send(.view(.참여인원_버튼_눌렀을때))
        await store.receive(\.inner.참여인원_시트_활성화) {
            $0.isParticipantsSheetPresented = true
        }
    }

    @Test("참여자 내보내기 선택시 확인시트와 선택유저가 갱신된다")
    func 참여자_내보내기_선택시_확인시트와_선택유저가_갱신된다() async throws {
        var initialState = CategoryDetailFeature.State(
            type: .참여,
            category: .featureCategoryDetail_sharedCategory
        )
        initialState.isParticipantsSheetPresented = true

        let store = TestStore(initialState: initialState) {
            CategoryDetailFeature()
        }

        let member = InvitedUserResponse.featureCategoryDetail_member.toDomain()
        await store.send(.scope(.participantsBottomSheet(.removeParticipant(member))))
        await store.receive(\.inner.참여인원_시트_활성화) {
            $0.isParticipantsSheetPresented = false
        }
        await store.receive(\.inner.내보낼_유저_선택) {
            $0.selectedUserToRemove = member
        }
        await store.receive(\.inner.내보내기_확인_시트_활성화) {
            $0.isRemoveParticipantSheetPresented = true
        }
    }

    @Test("내보내기 확정시 API후 참여인원목록을 재조회한다")
    func 내보내기_확정시_API후_참여인원목록을_재조회한다() async throws {
        var initialState = CategoryDetailFeature.State(
            type: .참여,
            category: .featureCategoryDetail_sharedCategory
        )
        initialState.selectedUserToRemove = InvitedUserResponse.featureCategoryDetail_member.toDomain()
        initialState.isRemoveParticipantSheetPresented = true

        let store = TestStore(initialState: initialState) {
            CategoryDetailFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featureCategoryDetailTestValue(
                invitedUsers: [InvitedUserResponse].featureCategoryDetail_ownerOnly,
                onRemoveParticipant: { categoryId, userId in
                    guard categoryId == 55, userId == 201 else {
                        preconditionFailure("예상하지 못한 내보내기 요청입니다: \(categoryId), \(userId)")
                    }
                }
            )
        }

        await store.send(.scope(.removeParticipantBottomSheet(.deleteButtonTapped)))
        await store.receive(\.async.포킷_내보내기_API)
        await store.receive(\.inner.내보내기_확인_시트_활성화) {
            $0.isRemoveParticipantSheetPresented = false
        }
        await store.receive(\.async.포킷_초대된_유저_목록_조회_API)
        await store.receive(\.inner.포킷_초대된_유저_목록_조회_API_반영) {
            $0.domain.invitedUsers = [InvitedUserResponse].featureCategoryDetail_ownerOnly.map { $0.toDomain() }
        }
    }

    @Test("초대 수락하기는 타입을 참여로 바꾸고 delegate를 보낸다")
    func 초대_수락하기는_타입을_참여로_바꾸고_delegate를_보낸다() async throws {
        let store = TestStore(initialState: CategoryDetailFeature.State(
            type: .초대,
            category: .featureCategoryDetail_sharedCategory
        )) {
            CategoryDetailFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featureCategoryDetailTestValue(
                onAcceptInvite: { categoryId in
                    guard categoryId == 55 else {
                        preconditionFailure("예상하지 못한 초대 수락 포킷 ID입니다: \(categoryId)")
                    }
                }
            )
        }

        await store.send(.view(.초대_수락하기_버튼_눌렀을때))
        await store.receive(\.async.포킷_초대_수락_API)
        await store.receive(\.inner.타입_변경) {
            $0.type = .참여
        }
        await store.receive(\.delegate.초대_수락_완료)
    }

    @Test("공유받은 포킷 저장은 타입을 참여로 바꾸고 delegate를 보낸다")
    func 공유받은_포킷_저장은_타입을_참여로_바꾸고_delegate를_보낸다() async throws {
        let store = TestStore(initialState: CategoryDetailFeature.State(
            type: .공유,
            category: .featureCategoryDetail_sharedCategory
        )) {
            CategoryDetailFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featureCategoryDetailTestValue(
                onSaveShared: { request in
                    guard request.originCategoryId == 55 else {
                        preconditionFailure("예상하지 못한 공유 포킷 저장 요청입니다: \(request.originCategoryId)")
                    }
                }
            )
        }

        await store.send(.view(.저장하기_버튼_눌렀을때))
        await store.receive(\.async.공유받은_포킷_저장_API)
        await store.receive(\.inner.타입_변경) {
            $0.type = .참여
        }
        await store.receive(\.delegate.저장_완료)
    }

    @Test("참여자인원이 최신참여순으로 반영된다")
    func 참여자인원이_최신참여순으로_반영된다() async throws {
        let store = TestStore(initialState: CategoryDetailFeature.State(
            type: .참여,
            category: .featureCategoryDetail_sharedCategory
        )) {
            CategoryDetailFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featureCategoryDetailTestValue(
                invitedUsers: [InvitedUserResponse].featureCategoryDetail_latestOrder
            )
        }

        await store.send(.async(.포킷_초대된_유저_목록_조회_API))
        await store.receive(\.inner.포킷_초대된_유저_목록_조회_API_반영) {
            $0.domain.invitedUsers = [InvitedUserResponse].featureCategoryDetail_latestOrder.map { $0.toDomain() }
            guard $0.invitedUsers.map(\.id) == [202, 100, 201] else {
                preconditionFailure("참여 인원 정렬이 예상과 다릅니다: \($0.invitedUsers.map(\.id))")
            }
        }
    }

    @Test("공유포킷 컨텐츠조회시 author정보를 보존한다")
    func 공유포킷_컨텐츠조회시_author정보를_보존한다() async throws {
        let store = TestStore(initialState: CategoryDetailFeature.State(
            type: .공유,
            category: .featureCategoryDetail_sharedCategory
        )) {
            CategoryDetailFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featureCategoryDetailTestValue()
        }
        store.exhaustivity = .off

        await store.send(.async(.카테고리_내_컨텐츠_목록_조회_API))
        await store.receive(\.inner.카테고리_내_컨텐츠_목록_조회_API_반영) {
            $0.isLoading = false
            guard let firstContent = $0.contents.first?.content else {
                preconditionFailure("컨텐츠가 비어 있습니다")
            }
            guard
                firstContent.authorNickname == "참여멤버",
                firstContent.authorUserId == 201,
                firstContent.authorProfileImageURL == "https://example.com/category-detail-author.png"
            else {
                preconditionFailure("author 정보가 보존되지 않았습니다: \(firstContent)")
            }
        }
    }

    @Test("참여중인 공유포킷은 개인별 안읽음과 즐겨찾기를 보존한다")
    func 참여중인_공유포킷은_개인별_안읽음과_즐겨찾기를_보존한다() async throws {
        let response = ContentListInquiryResponse.featureCategoryDetail_participantListResponse

        let store = TestStore(initialState: CategoryDetailFeature.State(
            type: .참여,
            category: .featureCategoryDetail_sharedCategory
        )) {
            CategoryDetailFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureCategoryDetailTestValue(
                participantListResponse: response
            )
        }
        store.exhaustivity = .off

        await store.send(.async(.카테고리_내_컨텐츠_목록_조회_API))
        await store.receive(\.inner.카테고리_내_컨텐츠_목록_조회_API_반영) {
            $0.isLoading = false
            guard let firstContent = $0.contents.first?.content else {
                preconditionFailure("컨텐츠가 비어 있습니다")
            }
            guard
                firstContent.isRead == true,
                firstContent.isFavorite == true
            else {
                preconditionFailure("공유 포킷의 개인별 안읽음/즐겨찾기 상태가 보존되지 않았습니다: \(firstContent)")
            }
        }
    }

    @Test("나가기 선택시 확인시트가 노출된다")
    func 나가기_선택시_확인시트가_노출된다() async throws {
        var initialState = CategoryDetailFeature.State(
            type: .참여,
            category: .featureCategoryDetail_sharedCategory
        )
        initialState.isCategorySheetPresented = true

        let store = TestStore(initialState: initialState) {
            CategoryDetailFeature()
        }

        await store.send(.scope(.categoryBottomSheet(.leaveCellButtonTapped)))
        await store.receive(\.inner.카테고리_시트_활성화) {
            $0.isCategorySheetPresented = false
        }
        await store.receive(\.inner.나가기_확인_시트_활성화) {
            $0.isLeaveSheetPresented = true
        }
    }

    @Test("나가기 확정시 API후 delegate를 보낸다")
    func 나가기_확정시_API후_delegate를_보낸다() async throws {
        var initialState = CategoryDetailFeature.State(
            type: .참여,
            category: .featureCategoryDetail_sharedCategory
        )
        initialState.isLeaveSheetPresented = true

        let store = TestStore(initialState: initialState) {
            CategoryDetailFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featureCategoryDetailTestValue(
                onLeave: { categoryId in
                    guard categoryId == 55 else {
                        preconditionFailure("예상하지 못한 포킷 나가기 요청입니다: \(categoryId)")
                    }
                }
            )
        }

        await store.send(.scope(.leaveBottomSheet(.deleteButtonTapped)))
        await store.receive(\.async.포킷_나가기_API)
        await store.receive(\.inner.나가기_확인_시트_활성화) {
            $0.isLeaveSheetPresented = false
        }
        await store.receive(\.delegate.포킷나가기)
    }
}
