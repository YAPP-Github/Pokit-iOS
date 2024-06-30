//
//  SheetCornerRadiusModifier.swift
//  DSKit
//
//  Created by 김도형 on 7/1/24.
//

import SwiftUI

struct PokitPresentationCornerRadiusModifier: ViewModifier {
    init() { }
    
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content
                .presentationCornerRadius(20)
        } else {
            content
        }
    }
}

public extension View {
    func pokitPresentationCornerRadius() -> some View {
        modifier(PokitPresentationCornerRadiusModifier())
    }
}
