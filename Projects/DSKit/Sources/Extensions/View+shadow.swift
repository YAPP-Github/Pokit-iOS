//
//  View+shadow.swift
//  DSKit
//
//  Created by 김민호 on 7/12/24.
//

import CoreGraphics
import SwiftUI

private struct PokitShadowModifier: ViewModifier {
    let x: CGFloat
    let y: CGFloat
    let blur: CGFloat
    let spread: CGFloat
    let color: Color
    let colorPercent: Int
    
    func body(content: Content) -> some View {
        content
            .background(
                color
                    .opacity(Double(colorPercent) / 100)
                    .padding(-spread / 2)
                    .offset(x: x, y: y)
                    .blur(radius: blur)
            )
    }
}

public extension View {
    ///  Pokit Shadow
    /// - colorPercent에는 피그마에 적힌 값 정수값 입력하기 ex) 10% -> 10
    func pokitShadow(
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat,
        spread: CGFloat,
        color: Color,
        colorPercent: Int
    ) -> some View {
        modifier(
            PokitShadowModifier(
                x: x,
                y: y,
                blur: blur,
                spread: spread,
                color: color,
                colorPercent: colorPercent
            )
        )
    }
}
