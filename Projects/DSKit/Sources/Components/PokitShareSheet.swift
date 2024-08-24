//
//  PokitShareSheet.swift
//  DSKit
//
//  Created by 김도형 on 8/23/24.
//

import SwiftUI

public struct PokitShareSheet: UIViewControllerRepresentable {
    private var items: [Any]
    private var completion: ((_ completed: Bool) -> Void)?
    
    public init(
        items: [Any],
        completion: ((_: Bool) -> Void)?
    ) {
        self.items = items
        self.completion = completion
    }
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        controller.completionWithItemsHandler = { _, completed, _, _ in
            completion?(completed)
        }
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 업데이트가 필요 없으므로 아무것도 하지 않습니다.
    }
}
