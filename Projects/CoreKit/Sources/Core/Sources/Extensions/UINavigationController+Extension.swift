//
//  UINavigationController+Extension.swift
//  CoreKit
//
//  Created by 김도형 on 7/7/24.
//

import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
     override public func viewDidLoad() {
         super.viewDidLoad()
         interactivePopGestureRecognizer?.delegate = self
     }

     public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
         return viewControllers.count > 1
     }
}
