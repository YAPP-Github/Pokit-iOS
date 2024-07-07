//
//  PokitNavigationBarModifier.swift
//  DSKit
//
//  Created by 김도형 on 7/7/24.
//

import SwiftUI

struct PokitNavigationBarModifier: ViewModifier {
    private let title: String
    
    init(title: String) {
        self.title = title
    }
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
    }
}


public extension View {
    func pokitNavigationBar(title: String) -> some View {
        modifier(PokitNavigationBarModifier(title: title))
    }
}
