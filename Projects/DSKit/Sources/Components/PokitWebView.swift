//
//  PokitWebView.swift
//  DSKit
//
//  Created by 김도형 on 8/27/24.
//

import SwiftUI
import SafariServices

import Util

public struct PokitWebView: UIViewControllerRepresentable {
    @Environment(\.dismiss)
    private var dismiss
    
    @Binding
    private var url: URL?
    
    public init(url: Binding<URL?>) {
        self._url = url
    }
    
    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<PokitWebView>
    ) -> some SFSafariViewController {
        let controller = SFSafariViewController(url: url ?? Constants.고객문의_주소)
        controller.dismissButtonStyle = .close
        controller.preferredControlTintColor = UIColor(Color.pokit(.icon(.brand)))
        controller.delegate = context.coordinator
        
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    public class Coordinator: NSObject, SFSafariViewControllerDelegate {
        @Binding
        private var url: URL?
        
        private let dismiss: DismissAction?
        
        init(dismiss: DismissAction?, url: Binding<URL?>) {
            self._url = url
            self.dismiss = dismiss
        }
        
        public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            url = nil
            dismiss?()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(dismiss: dismiss, url: $url)
        return coordinator
    }
}
