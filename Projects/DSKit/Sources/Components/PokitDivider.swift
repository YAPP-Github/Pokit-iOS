//
//  PokitDivider.swift
//  DSKit
//
//  Created by 김도형 on 7/1/24.
//

import SwiftUI

public struct PokitDivider: View {
    public init() {}
    
    public var body: some View {
        Rectangle()
            .fill(.pokit(.bg(.primary)))
            .frame(height: 6)
    }
}

#Preview {
    PokitDivider()
}
