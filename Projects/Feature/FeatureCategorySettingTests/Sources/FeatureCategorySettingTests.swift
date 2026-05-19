import ComposableArchitecture
import CoreKit
import Domain
import Util
import XCTest

@testable import FeatureCategorySetting

@MainActor
final class FeatureCategorySettingTests: XCTestCase {
    func test_화면_진입시_시스템_알림_권한을_조회한다() async {
        let store = TestStore(
            initialState: PokitCategorySettingFeature.State(
                type: .수정,
                category: .featureCategorySetting_editTarget
            )
        ) {
            PokitCategorySettingFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featureCategorySettingTestValue(
                onProfileList: { [] }
            )
            $0[UserNotificationClient.self] = .featureCategorySettingTestValue(
                authorizationStatus: .authorized
            )
            $0[UserDefaultsClient.self] = .featureCategorySettingTestValue
            $0[PasteboardClient.self] = .noop
            $0[KeyboardClient.self] = .noop
        }
        store.exhaustivity = .off

        await store.send(.view(.뷰가_나타났을때)) {
            $0.keywordSelectType = .select(keywordName: BaseInterestType.IT.title)
        }
        await store.receive(\.async.프로필_목록_조회_API)
        await store.receive(\.async.클립보드_감지)
        await store.receive(\.async.키보드_감지)
        await store.receive(\.async.알림_권한_감지)
        await store.receive(\.inner.알림_권한_감지_반영) {
            $0.isNotificationAuthorization = true
        }
    }

    func test_카테고리_수정시_alertEnabled를_요청에_포함한다() async {
        let store = TestStore(
            initialState: PokitCategorySettingFeature.State(
                type: .수정,
                category: .featureCategorySetting_editTarget
            )
        ) {
            PokitCategorySettingFeature()
        } withDependencies: {
            $0[CategoryClient.self] = .featureCategorySettingTestValue(
                onUpdate: { categoryId, request in
                    guard categoryId == 42 else {
                        preconditionFailure("예상하지 못한 카테고리 ID입니다: \(categoryId)")
                    }
                    guard request.alertEnabled == false else {
                        preconditionFailure("alertEnabled가 false로 전달되어야 합니다: \(String(describing: request.alertEnabled))")
                    }
                    guard request.categoryName == "공유 포킷",
                          request.categoryImageId == 7,
                          request.openType == "PUBLIC",
                          request.keywordType == "IT" else {
                        preconditionFailure("카테고리 수정 요청 값이 예상과 다릅니다: \(request)")
                    }
                    return .mock
                }
            )
        }
        store.exhaustivity = .off

        await store.send(.view(.알림_권한_바인딩(false))) {
            $0.isAlert = false
        }
        await store.send(.view(.저장_버튼_눌렀을때))
        await store.receive(\.delegate.settingSuccess) {
            guard $0.isAlert == false else {
                preconditionFailure("알림 토글 상태가 저장 요청 이후에도 유지되어야 합니다.")
            }
        }
    }
}
