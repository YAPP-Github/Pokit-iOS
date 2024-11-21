//
//  NickNameSettingView.swift
//  Feature
//
//  Created by 김민호 on 7/22/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: NickNameSettingFeature.self)
public struct NickNameSettingView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<NickNameSettingFeature>
    @FocusState private var isFocused: Bool
    
    /// - Initializer
    public init(store: StoreOf<NickNameSettingFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension NickNameSettingView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                if store.user == nil {
                    PokitLoading()
                } else {
                    PokitTextInput(
                        text: $store.text,
                        state: $store.textfieldState,
                        info: "한글, 영어, 숫자로만 입력이 가능합니다.",
                        maxLetter: 10,
                        focusState: $isFocused,
                        equals: true
                    )
                    Spacer()
                }
            }
            .overlay(alignment: .bottom) {
                PokitBottomButton(
                    "저장",
                    state: store.buttonState,
                    action: { send(.저장_버튼_눌렀을때) }
                )
                .setKeyboardHeight()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .pokitNavigationBar { navigationBar }
            .ignoresSafeArea(edges: .bottom)
            .task { await send(.뷰가_나타났을때).finish() }
        }
    }
}
//MARK: - Configure View
private extension NickNameSettingView {
    var navigationBar: some View {
        PokitHeader(title: "닉네임 설정") {
            PokitHeaderItems(placement: .leading) {
                PokitToolbarButton(.icon(.arrowLeft)) {
                    send(.dismiss)
                }
            }
        }
        .padding(.top, 8)
    }
    
}
//MARK: - Preview
#Preview {
    NavigationStack {
        NickNameSettingView(
            store: Store(
                initialState: .init(),
                reducer: { NickNameSettingFeature() }
            )
        )
    }
}


