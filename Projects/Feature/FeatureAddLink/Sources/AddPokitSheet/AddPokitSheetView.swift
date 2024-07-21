//
//  AddPokitSheetView.swift
//  Feature
//
//  Created by 김도형 on 7/18/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: AddPokitSheetFeature.self)
public struct AddPokitSheetView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<AddPokitSheetFeature>
    @FocusState
    private var focused: Bool
    
    /// - Initializer
    public init(store: StoreOf<AddPokitSheetFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension AddPokitSheetView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 12) {
                PokitTextInput(
                    text: $store.pokit.categoryType,
                    focusState: $focused,
                    equals: true
                )
                .padding(.horizontal, 20)
                
                PokitBottomButton(
                    "추가하기",
                    state: store.pokit.categoryType == "" ? .disable : .filled(.primary),
                    action: { send(.addButtonTapped) }
                )
            }
            .pokitPresentationBackground()
            .pokitPresentationCornerRadius()
            .presentationDetents([.height(230)])
        }
    }
}
//MARK: - Configure View
private extension AddPokitSheetView {
    
}
//MARK: - Preview
#Preview {
    AddPokitSheetView(
        store: Store(
            initialState: .init(),
            reducer: { AddPokitSheetFeature() }
        )
    )
}


