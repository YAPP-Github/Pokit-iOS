import ComposableArchitecture
import CoreKit
import Domain
import Testing

@testable import FeatureContentCard

@MainActor
struct FeatureContentCardTests {
    @Test("메타데이터 조회시 작성자정보를 보존한채 썸네일을 업데이트한다")
    func 메타데이터_조회시_작성자정보를_보존한채_썸네일을_업데이트한다() async throws {
        let updatedThumbnail = "https://example.com/updated-thumbnail.png"

        let store = TestStore(initialState: ContentCardFeature.State(
            content: .featureContentCard_authorVisible
        )) {
            ContentCardFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureContentCardTestValue()
            $0[SwiftSoupClient.self] = .featureContentCardTestValue(imageURL: updatedThumbnail)
        }

        await store.send(.view(.메타데이터_조회))
        await store.receive(\.inner.메타데이터_조회_수행_반영) {
            $0.content.thumbNail = updatedThumbnail
            guard
                $0.content.authorUserId == 202,
                $0.content.authorNickname == "공유멤버",
                $0.content.authorProfileImageURL == "https://example.com/author-profile.png"
            else {
                preconditionFailure("작성자 정보가 보존되지 않았습니다: \($0.content)")
            }
        }
    }

    @Test("컨텐츠 항목을 누르면 상세조회후 안읽음이 읽음으로 변한다")
    func 컨텐츠_항목을_누르면_상세조회후_안읽음이_읽음으로_변한다() async throws {
        let store = TestStore(initialState: ContentCardFeature.State(
            content: .featureContentCard_authorVisible
        )) {
            ContentCardFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureContentCardTestValue()
            $0[SwiftSoupClient.self] = .featureContentCardTestValue()
            $0.openURL = .init { _ in true }
        }

        await store.send(.view(.컨텐츠_항목_눌렀을때))
        await store.receive(\.async.컨텐츠_상세_조회_API)
        await store.receive(\.inner.컨텐츠_상세_조회_API_반영) {
            $0.content.isRead = true
            guard $0.content.authorProfileImageURL == "https://example.com/author-profile.png" else {
                preconditionFailure("작성자 프로필 이미지가 유지되지 않았습니다: \($0.content)")
            }
        }
    }

    @Test("즐겨찾기상태면 즐겨찾기취소 API를 호출한다")
    func 즐겨찾기상태면_즐겨찾기취소_API를_호출한다() async throws {
        let store = TestStore(initialState: ContentCardFeature.State(
            content: .featureContentCard_favorite
        )) {
            ContentCardFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureContentCardTestValue(
                onUnfavorite: { contentId in
                    guard contentId == "102" else {
                        preconditionFailure("예상하지 못한 즐겨찾기 취소 요청입니다: \(contentId)")
                    }
                }
            )
        }

        await store.send(.view(.즐겨찾기_버튼_눌렀을때))
        await store.receive(\.inner.즐겨찾기_API_반영) {
            $0.content.isFavorite = false
        }
    }

    @Test("작성자정보가 없으면 메타데이터조회후에도 nil을 유지한다")
    func 작성자정보가_없으면_메타데이터조회후에도_nil을_유지한다() async throws {
        let updatedThumbnail = "https://example.com/updated-thumbnail-hidden.png"

        let store = TestStore(initialState: ContentCardFeature.State(
            content: .featureContentCard_authorHidden
        )) {
            ContentCardFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureContentCardTestValue(
                detailResponse: .featureContentCard_detailWithoutAuthor
            )
            $0[SwiftSoupClient.self] = .featureContentCardTestValue(imageURL: updatedThumbnail)
        }

        await store.send(.view(.메타데이터_조회))
        await store.receive(\.inner.메타데이터_조회_수행_반영) {
            $0.content.thumbNail = updatedThumbnail
            guard
                $0.content.authorUserId == nil,
                $0.content.authorNickname == nil,
                $0.content.authorProfileImageURL == nil
            else {
                preconditionFailure("작성자 정보가 없는 링크의 author 값이 변경되었습니다: \($0.content)")
            }
        }
    }

    @Test("공유포킷 개인별 안읽음과 즐겨찾기상태를 유지한다")
    func 공유포킷_개인별_안읽음과_즐겨찾기상태를_유지한다() async throws {
        let updatedThumbnail = "https://example.com/personalized-thumbnail.png"

        let store = TestStore(initialState: ContentCardFeature.State(
            content: .featureContentCard_personalized
        )) {
            ContentCardFeature()
        } withDependencies: {
            $0[ContentClient.self] = .featureContentCardTestValue()
            $0[SwiftSoupClient.self] = .featureContentCardTestValue(imageURL: updatedThumbnail)
        }

        await store.send(.view(.메타데이터_조회))
        await store.receive(\.inner.메타데이터_조회_수행_반영) {
            $0.content.thumbNail = updatedThumbnail
            guard
                $0.content.isRead == true,
                $0.content.isFavorite == true
            else {
                preconditionFailure("개인별 안읽음/즐겨찾기 상태가 유지되지 않았습니다: \($0.content)")
            }
        }
    }
}
