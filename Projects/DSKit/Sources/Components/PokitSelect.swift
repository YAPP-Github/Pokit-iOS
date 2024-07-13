//
//  PokitSelect.swift
//  DSKit
//
//  Created by 김도형 on 6/29/24.
//

import SwiftUI

import Util

public struct PokitSelect<Item: PokitSelectItem>: View {
    @State private var selectedItem: Item?
    @State private var state: PokitSelect.SelectState
    @State private var showSheet: Bool = false
    
    private let label: String
    private let list: [Item]
    private let action: (Item) -> Void
    
    public init(
        selectedItem: Item? = nil,
        state: PokitSelect.SelectState = .default,
        label: String,
        list: [Item],
        action: @escaping (Item) -> Void
    ) {
        self._selectedItem = State(initialValue: selectedItem)
        self._state = State(initialValue: state)
        self.label = label
        self.list = list
        self.action = action
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            PokitLabel(text: label, size: .large)
            
            partSelectButton
        }
        .onChange(of: selectedItem) { onChangedSeletedItem($0) }
        .sheet(isPresented: $showSheet) {
            listSheet
                .pokitPresentationCornerRadius()
                .presentationDetents([.medium, .large])
                .pokitPresentationBackground()
        }
    }
    
    private var partSelectButton: some View {
        Button {
            partSelectButtonTapped()
        } label: {
            partSelectLabel
        }
        .disabled(self.state == .disable || self.state == .readOnly)
    }
    
    private var partSelectLabel: some View {
        HStack {
            Text(self.selectedItem?.categoryType ?? "선택해주세요.")
                .pokitFont(.b3(.m))
                .foregroundStyle(self.state.textColor)
                .contentTransition(.numericText())
            
            Spacer()
            
            Image(.icon(.arrowDown))
                .resizable()
                .foregroundStyle(self.state.iconColor)
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 13)
        .background(background)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(self.state.backgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(self.state.backgroundStrokeColor, lineWidth: 1)
            }
            .animation(.smooth, value: self.state)
    }
    
    @ViewBuilder
    private func listCell(_ item: Item) -> some View {
        let isSelected = self.selectedItem == item
        
        Button {
            action(item)
            listCellTapped(item)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.categoryType)
                        .pokitFont(.b1(.b))
                        .foregroundStyle(.pokit(.text(.primary)))
                    
                    Text("링크 \(item.contentSize)개")
                        .pokitFont(.detail1)
                        .foregroundStyle(.pokit(.text(.tertiary)))
                }
                
                Spacer()
            }
            .padding(.leading, 28)
            .padding(.trailing, 20)
            .padding(.vertical, 18)
            .background(isSelected ? .pokit(.bg(.primary)) : .clear)
        }
        .animation(.smooth, value: isSelected)
    }
    
    private var listSheet: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(self.list) { item in
                    listCell(item)
                }
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 20)
    }
    
    private func partSelectButtonTapped() {
        showSheet = true
    }
    
    private func listCellTapped(_ item: Item) {
        withAnimation(.smooth) {
            self.selectedItem = item
        }
        showSheet = false
    }
    
    private func onChangedSeletedItem(_ newValue: Item?) {
        state = newValue != nil ? .input : .default
    }
}

public extension PokitSelect {
    enum SelectState {
        case `default`
        case input
        case disable
        case readOnly
        
        var backgroundColor: Color {
            switch self {
            case .default, .input:
                return .pokit(.bg(.base))
            case .disable:
                return .pokit(.bg(.disable))
            case .readOnly:
                return .pokit(.bg(.secondary))
            }
        }
        
        var backgroundStrokeColor: Color {
            switch self {
            case .default, .input, .readOnly:
                return .pokit(.border(.secondary))
            case .disable:
                return .pokit(.border(.disable))
            }
        }
        
        var iconColor: Color {
            switch self {
            case .default, .readOnly, .input:
                return .pokit(.icon(.secondary))
            case .disable:
                return .pokit(.icon(.disable))
            }
        }
        
        var textColor: Color {
            switch self {
            case .default, .readOnly: return .pokit(.text(.tertiary))
            case .input: return .pokit(.text(.secondary))
            case .disable: return .pokit(.text(.disable))
            }
        }
    }
}

