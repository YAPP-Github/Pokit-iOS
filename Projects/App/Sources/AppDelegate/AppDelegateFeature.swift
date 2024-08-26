//
//  AppDelegateFeature.swift
//  App
//
//  Created by 김민호 on 7/4/24.
//

import Foundation

import FirebaseCore
import ComposableArchitecture
import CoreKit
import KakaoSDKCommon

@Reducer
public struct AppDelegateFeature {
    @Dependency(\.userNotifications) var userNotifications
    @Dependency(\.remoteNotifications.register) var registerForRemoteNotifications
    @Dependency(\.userDefaults) var userDefaults
    
    @ObservableState
    public struct State {
        public var root = RootFeature.State()
        
        public init() {}
    }
    
    public enum Action {
        case didFinishLaunching
        case didRegisterForRemoteNotifications(Result<Data, Error>)
        case userNotifications(UserNotificationClient.DelegateEvent)
        case root(RootFeature.Action)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.root, action: \.root) {
            RootFeature()
        }
        Reduce { state, action in
            switch action {
            case .didFinishLaunching:
                FirebaseApp.configure()
                let userNotificationsEventStream = self.userNotifications.delegate()
                if let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String {
                    print("카카오 네이티브 앱 키: \(kakaoAppKey)")
                    KakaoSDK.initSDK(appKey: kakaoAppKey)
                }
                return .run { send in
                    await withThrowingTaskGroup(of: Void.self) { group in
                        group.addTask {
                            for await event in userNotificationsEventStream {
                                await send(.userNotifications(event))
                            }
                        }
                        
                        group.addTask {
                            let setting = await self.userNotifications.getNotificationSettings()
                            switch setting.authorizationStatus {
                            case .authorized:
                                guard try await self.userNotifications.requestAuthorization([.alert, .sound])
                                else { return }
                            case .notDetermined, .provisional:
                                guard try await self.userNotifications.requestAuthorization(.provisional)
                                else { return }
                            default: return
                            }
                            await self.registerForRemoteNotifications()
                        }
                    }
                }
            case .didRegisterForRemoteNotifications(.failure):
                return .none
            case let .didRegisterForRemoteNotifications(.success(tokenData)):
                let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
                return .run { _ in await userDefaults.setString(token, .fcmToken) } 
                catch: { _, _ in }
            case let .userNotifications(.willPresentNotification(_, completionHandler)):
                return .run { _ in completionHandler(.banner) }
            case .userNotifications:
                return .none
                
            case .root:
                return .none
            }
        }
    }
}
