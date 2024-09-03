//
//  SheetBackgroundModifier.swift
//  DSKit
//
//  Created by 김도형 on 7/1/24.
//

import SwiftUI

struct PokitPresentationBackgroundModifier: ViewModifier {
    init() {}
    
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content
                .presentationBackground(.pokit(.bg(.base)))
        } else {
            content
        }
    }
}

public extension View {
    func pokitPresentationBackground() -> some View {
        modifier(PokitPresentationBackgroundModifier())
    }
}
