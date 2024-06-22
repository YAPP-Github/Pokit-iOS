//
//  PokitFontModifier.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

struct PokitFontModifier: ViewModifier {
    private let pokitFont: PokitFont
    
    init(pokitFont: PokitFont) {
        self.pokitFont = pokitFont
    }
    
    func body(content: Content) -> some View {
        let uiFont = pokitFont.uiFont
        let lineSpacing = pokitFont.height - uiFont.lineHeight
        
        content
            .font(pokitFont.swiftUIFont)
            .lineSpacing(lineSpacing)
            .kerning(pokitFont.kerning)
            .padding(.vertical, lineSpacing / 2)
    }
}

public extension View {
    func pokitFont(_ font: PokitFont) -> some View {
        modifier(PokitFontModifier(pokitFont: font))
    }
}
