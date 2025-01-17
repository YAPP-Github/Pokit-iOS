import ComposableArchitecture
import XCTest
import Domain
import CoreKit
import DSKit
import Util

@testable import FeatureContentCard

final class SendTests: XCTestCase {
    
    func test_primeTest() async {
        let count = 10
        var sharedAverage: CFAbsoluteTime = 0.0
        for _ in 0..<count {
            await test_shared_메서드_적용(&sharedAverage)
        }
        
        var noSharedAverage: CFAbsoluteTime = 0.0
        for _ in 0..<count {
            await test_shared_메서드_미적용(&noSharedAverage)
        }
        
        print(
            "shared_메서드_적용 \(count)번 테스트 평균 소요시간",
            sharedAverage / CFAbsoluteTime(count)
        )
        print(
            "shared_메서드_미적용 \(count)번 테스트 평균 소요시간",
            noSharedAverage / CFAbsoluteTime(count)
        )
    }
    
    @MainActor
    func test_shared_메서드_적용(_ average: inout CFAbsoluteTime) async {
        let store = TestStore(initialState: ContentCardFeature.State(
            content: ContentBaseResponse.mock(id: 0).toDomain()
        )) {
            ContentCardFeature()
        } withDependencies: {
            $0[ContentClient.self] = .testValue
            let parseOGImageURL: @Sendable (
                _ url: URL
            ) async throws -> String? = { _ in
                "https://i.ytimg.com/vi/wtSwdGJzQCQ/maxresdefault.jpg"
            }
            
            $0[SwiftSoupClient.self].parseOGImageURL = parseOGImageURL
        }
        
        let start = CFAbsoluteTimeGetCurrent()
        await store.send(.view(.메타데이터_조회))
        await store.receive(\.inner.메타데이터_조회_수행_반영) {
            $0.content.thumbNail =  "https://i.ytimg.com/vi/wtSwdGJzQCQ/maxresdefault.jpg"
        }
        let end = CFAbsoluteTimeGetCurrent()
        average += end - start
    }
    
    @MainActor
    func test_shared_메서드_미적용(_ average: inout CFAbsoluteTime) async {
        let store = TestStore(initialState: LegacyContentCardFeature.State(
            content: ContentBaseResponse.mock(id: 0).toDomain()
        )) {
            LegacyContentCardFeature()
        } withDependencies: {
            $0[ContentClient.self] = .testValue
            let parseOGImageURL: @Sendable (
                _ url: URL
            ) async throws -> String? = { _ in
                "https://i.ytimg.com/vi/wtSwdGJzQCQ/maxresdefault.jpg"
            }
            
            $0[SwiftSoupClient.self].parseOGImageURL = parseOGImageURL
        }
        
        let start = CFAbsoluteTimeGetCurrent()
        await store.send(.view(.메타데이터_조회))
        await store.receive(\.async.메타데이터_조회_수행)
        await store.receive(\.inner.메타데이터_조회_수행_반영) {
            $0.content.thumbNail =  "https://i.ytimg.com/vi/wtSwdGJzQCQ/maxresdefault.jpg"
        }
        await store.receive(\.async.썸네일_수정_API)
        let end = CFAbsoluteTimeGetCurrent()
        average += end - start
    }
}


