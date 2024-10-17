//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by 김도형 on 10/16/24.
//

import UIKit
import SwiftUI
import Social
import UniformTypeIdentifiers

import ComposableArchitecture
import FeatureContentSetting

class ShareViewController: SLComposeServiceViewController {
    let store = Store(initialState: ShareRootFeature.State()) {
        ShareRootFeature()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.send(.viewDidLoad(extensionContext))
        
        let hostingController = UIHostingController(
            rootView: ShareRootView(store: store)
        )
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.didMove(toParent: self)
        
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = item.attachments?.first,
              itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) else {
            return
        }
        
        Task { @MainActor in
            let urlItem = try await itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier)
            guard let url = urlItem as? URL else { return }
            store.send(.parseURL(url))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.resignFirstResponder()
    }
}
