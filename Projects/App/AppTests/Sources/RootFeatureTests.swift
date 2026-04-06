import ComposableArchitecture
import CoreKit
import Foundation
import Testing

@testable import App

@MainActor
struct RootFeatureTests {
    @Test("fcmToken이 없으면 userClient 호출 없이 즉시 mainTab으로 이동")
    func moveToTabWithoutFCMTokenRoutesImmediately() async throws {
        let tokenRecorder = TokenRecorder()
        let writeRecorder = StringWriteRecorder()

        let store = TestStore(initialState: RootFeature.State()) {
            RootFeature()
        } withDependencies: {
            $0[UserDefaultsClient.self].stringKey = { key in
                switch key {
                case .fcmToken:
                    return nil
                default:
                    return nil
                }
            }
            $0[UserDefaultsClient.self].setString = { value, key in
                await writeRecorder.append(value: value, key: key)
            }
            $0[UserClient.self].fcm_토큰_저장 = { request in
                await tokenRecorder.append(request.token)
                return makeFCMResponse(userId: 1, token: "unused-token")
            }
        }

        await store.send(.intro(.delegate(.moveToTab)))
        await store.receive(\._sceneChange) {
            $0 = .mainTab()
        }

        let requestedTokens = await tokenRecorder.values()
        #expect(requestedTokens.isEmpty)

        let writes = await writeRecorder.values()
        #expect(writes.isEmpty)
    }

    @Test("fcmToken이 있으면 저장 API 성공 후 mainTab으로 이동하고 토큰/유저ID를 저장")
    func moveToTabWithFCMTokenStoresUserInfo() async throws {
        let tokenRecorder = TokenRecorder()
        let writeRecorder = StringWriteRecorder()

        let store = TestStore(initialState: RootFeature.State()) {
            RootFeature()
        } withDependencies: {
            $0[UserDefaultsClient.self].stringKey = { key in
                switch key {
                case .fcmToken:
                    return "device-fcm-token"
                default:
                    return nil
                }
            }
            $0[UserDefaultsClient.self].setString = { value, key in
                await writeRecorder.append(value: value, key: key)
            }
            $0[UserClient.self].fcm_토큰_저장 = { request in
                await tokenRecorder.append(request.token)
                return makeFCMResponse(userId: 42, token: "server-fcm-token")
            }
        }

        await store.send(.intro(.delegate(.moveToTab)))
        await store.receive(\._sceneChange) {
            $0 = .mainTab()
        }

        let requestedTokens = await tokenRecorder.values()
        #expect(requestedTokens == ["device-fcm-token"])

        let writes = await writeRecorder.values()
        #expect(
            writes == [
                .init(value: "server-fcm-token", key: .fcmToken),
                .init(value: "42", key: .userId)
            ]
        )
    }
}

private struct StringWrite: Equatable {
    let value: String
    let key: UserDefaultsKey.StringKey
}

private actor StringWriteRecorder {
    private var writes: [StringWrite] = []

    func append(value: String, key: UserDefaultsKey.StringKey) {
        writes.append(.init(value: value, key: key))
    }

    func values() -> [StringWrite] {
        writes
    }
}

private actor TokenRecorder {
    private var tokens: [String] = []

    func append(_ token: String) {
        tokens.append(token)
    }

    func values() -> [String] {
        tokens
    }
}

private func makeFCMResponse(userId: Int, token: String) -> FCMResponse {
    let payload = """
    {
      "userId": \(userId),
      "token": "\(token)"
    }
    """

    let data = payload.data(using: .utf8)!

    return try! JSONDecoder().decode(FCMResponse.self, from: data)
}
