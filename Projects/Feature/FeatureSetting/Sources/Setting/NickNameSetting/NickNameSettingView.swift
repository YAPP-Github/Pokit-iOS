//
//  NickNameSettingView.swift
//  Feature
//
//  Created by 김민호 on 7/22/24.

import SwiftUI

import ComposableArchitecture
import CoreKit
import Domain
import DSKit
import Util
import NukeUI

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
                .padding(.bottom, store.isKeyboardVisible ? -26 : 0)
                .padding(.bottom, 36)
//                .setKeyboardHeight()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .pokitNavigationBar { navigationBar }
            .dismissKeyboard(focused: $isFocused)
            .sheet(isPresented: $store.isProfileSheetPresented) {
                PokitProfileBottomSheet(
                    selectedImage: store.selectedProfile,
                    images: store.profileImages,
                    delegateSend: { store.send(.scope(.profile($0))) }
                )
            }
            .ignoresSafeArea(.container, edges: .bottom)
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
    @MainActor
    var profileSection: some View {
        LazyImage(url: URL(string: store.selectedProfile?.imageURL ?? "")) { state in
            Group {
                if let image = state.image {
                    image
                        .resizable()
                        .clipShape(.circle)
                } else if state.isLoading {
                    PokitSpinner()
                        .foregroundStyle(.pokit(.icon(.brand)))
                } else {
                    Image(.image(.profile))
                        .resizable()
                }

            }
            .animation(.pokitDissolve, value: state.image)
        }
        .frame(width: 70, height: 70)
        .overlay(alignment: .bottomTrailing) {
            Button(action: { send(.프로필_설정_버튼_눌렀을때) }) {
                Circle()
                    .strokeBorder(.pokit(.border(.secondary)), lineWidth: 1)
                    .background(Circle().foregroundColor(.white))
                    .frame(width: 24, height: 24)
                    .overlay {
                        Image(.icon(.plus))
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(.pokit(.icon(.secondary)))
                    }
                    .offset(x: 3.5, y: -3)
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
                placeholder: "닉네임을 입력해주세요.",
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
                initialState: .init(user: BaseUserResponse.mock.toDomain()),
                reducer: { NickNameSettingFeature() }
            )
        )
    }
}


