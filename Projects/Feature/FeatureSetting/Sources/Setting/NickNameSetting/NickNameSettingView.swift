//
//  NickNameSettingView.swift
//  Feature
//
//  Created by 김민호 on 7/22/24.

import SwiftUI

import ComposableArchitecture
import DSKit
import Util

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
                    profileSection
                    nickNameSection
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
    var profileSection: some View {
        Image(.image(.profile))
            .resizable()
            .frame(width: 70, height: 70)
            .overlay(alignment: .bottomTrailing) {
                Button(action: {}) {
                    Circle()
                        .strokeBorder(.pokit(.icon(.secondary)), lineWidth: 1)
                        .background(Circle().foregroundColor(.white))
                        .frame(width: 28, height: 28)
                        .overlay {
                            Image(.icon(.plus))
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundStyle(.pokit(.icon(.secondary)))
                        }
                        .offset(x: 7, y: -7)
                }
            }
            .padding(.vertical, 16)
    }
    var nickNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("닉네임 설정")
                .pokitFont(.b2(.m))
                .foregroundStyle(.pokit(.text(.secondary)))
            
            PokitTextInput(
                text: $store.text,
                type: store.text.isEmpty ? .text : .iconR(
                    icon: .icon(.x),
                    action: { send(.닉네임지우기_버튼_눌렀을때) }
                ),
                shape: .rectangle,
                state: $store.textfieldState,
                info: Constants.한글_영어_숫자_입력_문구,
                maxLetter: 10,
                focusState: $isFocused,
                equals: true
            )
        }
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


