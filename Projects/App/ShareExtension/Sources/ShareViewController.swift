//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by 김도형 on 10/16/24.
//

import UIKit
import SwiftUI
import Social

import ComposableArchitecture
import FeatureContentSetting

class ShareViewController: SLComposeServiceViewController {
    let store = Store(initialState: ShareRootFeature.State()) {
        ShareRootFeature()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let hostingController = UIHostingController(
            rootView: ShareRootView(store: store)
        )
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true, completion: nil)
        
        store.send(.viewDidLoad(self, extensionContext))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.resignFirstResponder()
    }
}
