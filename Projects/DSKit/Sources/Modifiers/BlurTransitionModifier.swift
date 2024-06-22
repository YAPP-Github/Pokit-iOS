//
//  BlurTransitionModifier.swift
//  DSKit
//
//  Created by 김도형 on 6/23/24.
//

import SwiftUI

struct BlurTransitionModifier: ViewModifier {
    private let animation: Animation
    
    public init(animation: Animation) {
        self.animation = animation
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content
                .transition(.blurReplace.animation(animation))
        } else {
            content
                .transition(.opacity.animation(animation))
        }
    }
}

public extension View {
    func blurTransition(_ animation: Animation) -> some View {
        modifier(BlurTransitionModifier(animation: animation))
    }
}
