//
//  PokitSelectSheet.swift
//  DSKit
//
//  Created by 김민호 on 12/27/24.
//

import SwiftUI
import Util


public struct PokitSelectSheet<Item: PokitSelectItem>: View {
    @Binding
    private var selectedItem: Item?
    
    private let list: [Item]?
    private let itemSelected: (Item) -> Void
    private let pokitAddAction: (() -> Void)?
    
    public init(
        list: [Item]?,
        selectedItem: Binding<Item?> = .constant(nil),
        itemSelected: @escaping (Item) -> Void,
        pokitAddAction: (() -> Void)?
    ) {
        self.list = list
        self._selectedItem = selectedItem
        self.itemSelected = itemSelected
        self.pokitAddAction = pokitAddAction
    }
    
    
    public var body: some View {
        Group {
            if let list {
                VStack(spacing: 0) {
                    if let pokitAddAction {
                        addButton {
                            pokitAddAction()
                        }
                    }
                    PokitList(
                        selectedItem: selectedItem,
                        list: list
                    ) { item in
                        itemSelected(item)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 20)
            } else {
                PokitLoading()
            }
        }
    }
}
extension PokitSelectSheet {
    @ViewBuilder
    private func addButton(
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                PokitIconButton(
                    .icon(.plusR),
                    state: .default(.secondary),
                    size: .medium,
                    shape: .round,
                    action: action
                )
                
                Text("포킷 추가하기")
                    .pokitFont(.b1(.b))
                    .foregroundStyle(.pokit(.text(.primary)))
                
                Spacer()
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 30)
            .background(alignment: .bottom) {
                Rectangle()
                    .fill(.pokit(.border(.tertiary)))
                    .frame(height: 1)
            }
        }
    }
}
