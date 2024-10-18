//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by 김도형 on 10/16/24.
//

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
        hostingController.presentationController?.delegate = self
        hostingController.modalPresentationStyle = .automatic
        present(hostingController, animated: true)
        
        store.send(.controller(.viewDidLoad(self, extensionContext)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        store.send(.controller(.viewDidAppear))
    }
}

extension ShareViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        store.send(.controller(.presentationControllerDidDismiss))
    }
}
