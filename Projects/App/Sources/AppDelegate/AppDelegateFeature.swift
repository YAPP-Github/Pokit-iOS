//
//  AppDelegateFeature.swift
//  App
//
//  Created by 김민호 on 7/4/24.
//

import Foundation

import ComposableArchitecture
import CoreKit

@Reducer
public struct AppDelegateFeature {
    @Dependency(\.userNotifications) var userNotifications
    @Dependency(\.remoteNotifications.register) var registerForRemoteNotifications
    
    @ObservableState
    public struct State {
        public var root = RootFeature.State.intro(.splash(.init()))
        
        public init() {}
    }
    
    public enum Action {
        case didFinishLaunching
        case didRegisterForRemoteNotifications(Result<String, Error>)
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
                let userNotificationsEventStream = self.userNotifications.delegate()
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
                                else {
                                    return
                                }
                            default: return
                            }
                            await self.registerForRemoteNotifications()
                        }
                    }
                }
            case .didRegisterForRemoteNotifications(.failure):
                return .none
            case let .didRegisterForRemoteNotifications(.success(token)):
                return .run { _ in
                    let settings = await self.userNotifications.getNotificationSettings()
                    /// Network
                } catch: { _, _ in
                }
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
