//
//  PokitIconLTextLink.swift
//  DSKit
//
//  Created by 김도형 on 7/9/24.
//

import SwiftUI

public struct PokitIconLTextLink: View {
    private let labelText: String
    private let icon: PokitImage
    private let action: () -> Void
    
    public init(
        _ labelText: String,
        icon: PokitImage,
        action: @escaping () -> Void
    ) {
        self.labelText = labelText
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            buttonLabel
        }
    }
    
    private var buttonLabel: some View {
        HStack(spacing: 2) {
            Image(icon)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(.pokit(.icon(.primary)))
            
            Text(labelText)
                .pokitFont(.b3(.m))
                .foregroundStyle(.pokit(.text(.secondary)))
        }
    }
}

#Preview {
    PokitIconLTextLink("전체 삭제", icon: .icon(.x)) {
        
    }
}
