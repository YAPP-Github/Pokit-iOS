//
//  ReadHeightModifier.swift
//  DSKit
//
//  Created by 김민호 on 7/19/24.
//

import SwiftUI
/// sheet 높이를 dynamic하게 설정
private struct ReadHeightModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: HeightPreferenceKey.self,
                value: geometry.size.height
            )
        }
    }
    
    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

public struct HeightPreferenceKey: PreferenceKey {
    public static var defaultValue: CGFloat?
    public static func reduce(
        value: inout CGFloat?,
        nextValue: () -> CGFloat?
    ) {
        guard let nextValue = nextValue() else { return }
        value = nextValue
    }
}

public extension View {
    func readHeight() -> some View {
        self.modifier(ReadHeightModifier())
    }
}
