//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI
import FeatureLogin

@main
struct FeatureLoginDemoApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: 루트 뷰 추가
            SignUpRootView(store: .init(initialState: .init(), reducer: {
                SignUpRootFeature()
            }))
        }
    }
}

#Preview {
    SignUpRootView(store: .init(initialState: .init(), reducer: {
        SignUpRootFeature()
    }))
}

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
