//
//  PokitList.swift
//  DSKit
//
//  Created by 김도형 on 7/1/24.
//

import SwiftUI

import Util

public struct PokitList<Item: PokitSelectItem>: View {
    @Namespace
    private var heroEffect
    
    private let selectedItem: Item?
    private let list: [Item]
    private let action: (Item) -> Void
    
    public init(
        selectedItem: Item?,
        list: [Item],
        action: @escaping (Item) -> Void
    ) {
        self.selectedItem = selectedItem
        self.list = list
        self.action = action
    }
    
    public var body: some View {
        if list.isEmpty {
            VStack {
                PokitCaution(type: .카테고리없음)
                
                Spacer()
            }
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(self.list) { item in
                        listCell(item)
                            .pokitScrollTransition(.opacity)
                    }
                }
            }
            .background(Color.pokit(.bg(.base)))
        }
    }
    
    @ViewBuilder
    private func listCell(_ item: Item) -> some View {
        let isSelected = self.selectedItem?.id == item.id
        
        Button {
            action(item)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.categoryName)
                        .pokitFont(.b1(.b))
                        .foregroundStyle(.pokit(.text(.primary)))
                    
                    Text("링크 \(item.contentCount)개")
                        .pokitFont(.detail1)
                        .foregroundStyle(.pokit(.text(.tertiary)))
                }
                
                Spacer()
            }
            .padding(.leading, 28)
            .padding(.trailing, 20)
            .padding(.vertical, 13)
            .background {
                if isSelected {
                    Color.pokit(.bg(.primary))
                        .matchedGeometryEffect(id: "SELECT", in: heroEffect)
                }
            }
        }
        .animation(.pokitDissolve, value: isSelected)
    }
}
