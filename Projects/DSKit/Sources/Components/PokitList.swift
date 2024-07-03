//
//  PokitList.swift
//  DSKit
//
//  Created by 김도형 on 7/1/24.
//

import SwiftUI

public struct PokitList<Content: View>: View {
    @ViewBuilder private var label: Content
    
    private let title: String
    private let action: () -> Void
    
    public init(
        title: String,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Content
    ) {
        self.title = title
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .pokitFont(.b1(.b))
                    .foregroundStyle(.pokit(.text(.primary)))
                
                Spacer()
                
                label
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
        }
    }
}

