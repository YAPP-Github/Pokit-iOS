//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import ComposableArchitecture

@main
struct PokitApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var store: StoreOf<AppDelegateFeature> { appDelegate.store }
    
    var body: some Scene {
        WindowGroup {
            WithPerceptionTracking {
                RootView(store: store.scope(state: \.root, action: \.root))
            }
        }
    }
}

// - MARK: 네비게이션 뒤로가기 제스처
extension UINavigationController: UIGestureRecognizerDelegate {
    override public func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isEqual(self.interactivePopGestureRecognizer)
    }
}
