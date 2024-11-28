//
//  PokitList.swift
//  DSKit
//
//  Created by 김도형 on 7/1/24.
//

import SwiftUI

import Util
import NukeUI

public struct PokitList<Item: PokitSelectItem>: View {
    @Namespace
    private var heroEffect
    
    private let selectedItem: Item?
    private let list: [Item]
    private let isDisabled: Bool
    private let action: (Item) -> Void
    
    public init(
        selectedItem: Item?,
        list: [Item],
        isDisabled: Bool = false,
        action: @escaping (Item) -> Void
    ) {
        self.selectedItem = selectedItem
        self.list = list
        self.isDisabled = isDisabled
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
            HStack(spacing: 12) {
                thumbNail(url: item.categoryImage.imageURL)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.categoryName)
                        .pokitFont(.b1(.b))
                        .foregroundStyle(
                            isDisabled
                            ? .pokit(.text(.disable))
                            : .pokit(.text(.primary))
                        )
                    
                    Text("링크 \(item.contentCount)개")
                        .pokitFont(.detail1)
                        .foregroundStyle(
                            isDisabled
                            ? .pokit(.text(.disable))
                            : .pokit(.text(.tertiary))
                        )
                }
                
                Spacer()
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .background {
                if isSelected {
                    Color.pokit(.bg(.primary))
                        .matchedGeometryEffect(id: "SELECT", in: heroEffect)
                } else {
                    isDisabled
                    ? Color.pokit(.bg(.disable))
                    : Color.pokit(.bg(.base))
                }
            }
        }
        .animation(.pokitDissolve, value: isSelected)
        .disabled(isDisabled)
    }
    
    @MainActor
    private func thumbNail(url: String) -> some View {
        LazyImage(url: URL(string: url)) { state in
            Group {
                if let image = state.image {
                    image
                        .resizable()
                } else {
                    PokitSpinner()
                        .foregroundStyle(.pokit(.icon(.brand)))
                        .frame(width: 48, height: 48)
                }
            }
            .animation(.pokitDissolve, value: state.image)
        }
        .frame(width: 60, height: 60)
    }
}
