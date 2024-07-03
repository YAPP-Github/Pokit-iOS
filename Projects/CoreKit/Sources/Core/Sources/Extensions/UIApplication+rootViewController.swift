//
//  UIApplication+rootViewController.swift
//  CoreKit
//
//  Created by 김민호 on 6/27/24.
//

import UIKit
/// 루트뷰가 있다면 구성
extension UIApplication {
    var rootViewController: UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let keyWindow = windowScene?.windows.first(where: { $0.isKeyWindow } )
        return keyWindow?.rootViewController
    }
}
