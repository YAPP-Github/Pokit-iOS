//
//  PokitHeader.swift
//  DSKit
//
//  Created by 김도형 on 8/20/24.
//

import SwiftUI

import Util

public struct PokitHeader<Content: View>: View {
    private let title: String?
    
    @ViewBuilder
    private var toolBarItems: Content
    
    public init(
        title: String? = nil,
        @ViewBuilder toolBarItems: () -> Content
    ) {
        self.title = title
        self.toolBarItems = toolBarItems()
    }
    
    public var body: some View {
        HStack {
            toolBarItems
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.pokit(.bg(.base)))
        .overlay(ifLet: title) { title in
            Text(title)
                .pokitFont(.title3)
                .foregroundStyle(.pokit(.text(.primary)))
        }
    }
}

public extension PokitHeader {
    enum HeaderType {
        case pokit
        case remind
    }
}

#Preview {
    PokitHeader {
        PokitHeaderItems(placement: .leading) {
            Image(.logo(.pokit))
                .resizable()
                .frame(width: 104, height: 32)
                .foregroundStyle(.pokit(.icon(.brand)))
        }
        
        PokitHeaderItems(placement: .trailing) {
            PokitToolbarButton(.icon(.search), action: {})
            PokitToolbarButton(.icon(.bell), action: {})
            PokitToolbarButton(.icon(.setup), action: {})
        }
    }
}
