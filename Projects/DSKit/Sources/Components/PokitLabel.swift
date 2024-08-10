//
//  PokitLabel.swift
//  DSKit
//
//  Created by 김도형 on 6/23/24.
//

import SwiftUI

public struct PokitLabel: View {
    private let label: String
    private let size: Self.Size
    
    public init(
        text: String,
        size: Self.Size
    ) {
        self.label = text
        self.size = size
    }
    
    public var body: some View {
        Text(label)
            .pokitFont(size == .large ? .b2(.m) : .b3(.r))
            .foregroundStyle(.pokit(.text(.secondary)))
    }
}

public extension PokitLabel {
    enum Size {
        case large
        case small
    }
}
