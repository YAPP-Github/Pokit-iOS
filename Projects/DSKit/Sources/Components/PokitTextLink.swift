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
    
    public init(
        _ labelText: String,
        action: @escaping () -> Void
    ) {
        self.labelText = labelText
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(labelText)
                .foregroundStyle(.pokit(.text(.secondary)))
                .pokitFont(.b3(.m))
        }
    }
}

#Preview {
    PokitTextLink("전체 삭제") {
        
    }
}
