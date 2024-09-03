//
//  PokitHeaderItems.swift
//  DSKit
//
//  Created by 김도형 on 8/20/24.
//

import SwiftUI

public struct PokitHeaderItems<Content: View>: View {
    private let placement: Self.Placement
    
    @ViewBuilder
    private var items: Content
    
    public init(
        placement: Placement,
        @ViewBuilder items: () -> Content
    ) {
        self.placement = placement
        self.items = items()
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            switch placement {
            case .leading:
                items
                
                Spacer()
            case .center:
                Spacer()
                
                items
                
                Spacer()
            case .trailing:
                Spacer()
                
                items
            }
        }
    }
}

public extension PokitHeaderItems {
    enum Placement {
        case leading
        case center
        case trailing
    }
}

#Preview {
    PokitHeaderItems(placement: .trailing) {
        
    }
}
