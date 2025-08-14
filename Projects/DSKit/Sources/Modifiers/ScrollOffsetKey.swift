//
//  ScrollOffsetKey.swift
//  DSKit
//
//  Created by 김민호 on 5/18/25.
//

import SwiftUI

public struct ScrollOffsetKey: PreferenceKey {
    public static var defaultValue: CGFloat = 0
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
