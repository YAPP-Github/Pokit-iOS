//
//  PokitSpinner.swift
//  DSKit
//
//  Created by 김도형 on 8/9/24.
//

import SwiftUI

public struct PokitSpinner: View {
    @State private var isAnimating = false
    
    public var body: some View {
        if #available(iOS 17.0, *) {
            Image(.icon(.spinner))
                .keyframeAnimator(
                    initialValue: Angle.zero,
                    repeating: true
                ) { content, value in
                    content
                        .rotationEffect(value)
                } keyframes: { _ in
                    KeyframeTrack(\.degrees) {
                        SpringKeyframe(360, duration: 1, spring: .snappy(duration: 1))
                    }
                }
            
        } else {
            Image(.icon(.spinner))
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation
                        .linear(duration: 1.0)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .onAppear {
                    self.isAnimating = true
                }
        }
    }
}

#Preview {
    PokitSpinner()
}
