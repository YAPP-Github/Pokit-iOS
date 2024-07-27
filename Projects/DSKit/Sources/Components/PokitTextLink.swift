//
//  PokitTextLink.swift
//  DSKit
//
//  Created by 김도형 on 7/9/24.
//

import SwiftUI

public struct PokitTextLink: View {
    private let labelText: String
    private let action: () -> Void
    private let color: PokitColor
    
    public init(
        _ labelText: String,
        color: PokitColor = .text(.secondary),
        action: @escaping () -> Void
    ) {
        self.labelText = labelText
        self.color = color
        self.action = action
        
    }
    
    public var body: some View {
        Button(action: action) {
            Text(labelText)
                .foregroundStyle(.pokit(color))
                .pokitFont(.b3(.m))
        }
    }
}

#Preview {
    PokitTextLink("전체 삭제") {
        
    }
}
