//
//  RegisterNicknameView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI
import Perception
import DSKit

public struct RegisterNicknameView: View {
    /// - Properties
    @Perception.Bindable
    private var store: StoreOf<RegisterNicknameFeature>
    
    @FocusState private var isFocused: Bool
    /// - Initializer
    public init(store: StoreOf<RegisterNicknameFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension RegisterNicknameView {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                title
                    .padding(.top, 16)
                
                textField
                    .padding(.top, 28)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            PokitBottomButton(
                "다음",
                state: store.nicknameText == "" || store.nicknameText.count > 10 ? .disable : .filled(.primary)
            ) {
                store.send(.nextButtonTapped)
            }
        }
        .pokitNavigationBar(title: "")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PokitToolbarButton(.icon(.arrowLeft)) {
                    store.send(.backButtonTapped)
                }
            }
        }
    }
}
//MARK: - Configure View
extension RegisterNicknameView {
    private var title: some View {
        Text("Pokit에서 사용할 닉네임을\n입력해주세요")
            .pokitFont(.title1)
            .foregroundStyle(.pokit(.text(.primary)))
    }
    
    private var textField: some View {
        PokitTextInput(
            text: $store.nicknameText,
            info: "한글, 영어, 숫자로만 입력이 가능합니다.",
            focusState: $isFocused,
            equals: true
        )
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        RegisterNicknameView(
            store: Store(
                initialState: .init(),
                reducer: { RegisterNicknameFeature() }
            )
        )
    }
}


