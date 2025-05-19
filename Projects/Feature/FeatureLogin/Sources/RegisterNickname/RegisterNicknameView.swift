//
//  RegisterNicknameView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI
import DSKit
import Util

@ViewAction(for: RegisterNicknameFeature.self)
public struct RegisterNicknameView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<RegisterNicknameFeature>
    
    @FocusState private var isFocused: Bool
    /// - Initializer
    public init(store: StoreOf<RegisterNicknameFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension RegisterNicknameView {
    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    title
                        .padding(.top, 16)
                    
                    textField
                        .padding(.top, 28)
                }
                
                Spacer()
                
            }
            .overlay(alignment: .bottom) {
                PokitBottomButton(
                    "다음",
                    state: store.buttonActive 
                    ? .filled(.primary)
                    : .disable,
                    action: { send(.다음_버튼_눌렀을때) }
                )
                .padding(.bottom, store.isKeyboardVisible ? -26 : 0)
                .padding(.bottom, 36)
//                .setKeyboardHeight()
            }
            .pokitMaxWidth()
            .padding(.horizontal, 20)
            .pokitNavigationBar {
                PokitHeader {
                    PokitHeaderItems(placement: .leading) {
                        PokitToolbarButton(.icon(.arrowLeft)) {
                            send(.dismiss)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear { send(.onAppear) }
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
            shape: .rectangle,
            state: $store.textfieldState,
            info: Constants.한글_영어_숫자_입력_문구,
            maxLetter: 10,
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


