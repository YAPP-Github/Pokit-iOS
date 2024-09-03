//
//  View+Extension.swift
//  DSKit
//
//  Created by 김도형 on 8/27/24.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func pokitMaxWidth() -> some View {
        self
            .frame(maxWidth: 430)
    }
}
