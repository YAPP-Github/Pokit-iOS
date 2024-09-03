//
//  PokitToolbarButton.swift
//  DSKit
//
//  Created by 김도형 on 7/7/24.
//

import SwiftUI

public struct PokitToolbarButton: View {
    private let icon: PokitImage
    private let action: () -> Void
    
    public init(_ icon: PokitImage, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.pokit(.icon(.primary)))
        }
    }
}
