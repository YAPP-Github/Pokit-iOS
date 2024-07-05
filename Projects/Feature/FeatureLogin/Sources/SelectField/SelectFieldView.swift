//
//  SelectFieldView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI

public struct SelectFieldView: View {
    /// - Properties
    private let store: StoreOf<SelectFieldFeature>
    /// - Initializer
    public init(store: StoreOf<SelectFieldFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SelectFieldView {
    var body: some View {
        VStack {
            Text("Hello World!")
        }
    }
}
//MARK: - Configure View
extension SelectFieldView {
    
}
//MARK: - Preview
#Preview {
    SelectFieldView(
        store: Store(
            initialState: .init(),
            reducer: { SelectFieldFeature() }
        )
    )
}


