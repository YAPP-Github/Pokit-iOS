//
//  PokitNavigationBarModifier.swift
//  DSKit
//
//  Created by 김도형 on 7/7/24.
//

import SwiftUI

struct PokitNavigationBarModifier<Toolbar: ToolbarContent>: ViewModifier {
    private let title: String
    private let toolbarCotent: Toolbar
    
    init(
        title: String,
        @ToolbarContentBuilder toolbarCotent: () -> Toolbar
    ) {
        self.title = title
        self.toolbarCotent = toolbarCotent()
    }
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                toolbarCotent
            }
    }
}


public extension View {
    func pokitNavigationBar<Content: ToolbarContent>(
        title: String,
        @ToolbarContentBuilder toolbarContent: () -> Content
    ) -> some View {
        modifier(PokitNavigationBarModifier(
            title: title,
            toolbarCotent: toolbarContent
        ))
    }
}
