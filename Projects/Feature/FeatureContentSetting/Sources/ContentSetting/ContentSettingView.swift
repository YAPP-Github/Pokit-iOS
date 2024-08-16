//
//  AddLinkView.swift
//  Feature
//
//  Created by 김도형 on 7/17/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: ContentSettingFeature.self)
public struct ContentSettingView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<ContentSettingFeature>
    @FocusState
    private var focusedType: FocusedType?
    @Namespace
    private var heroEffect
    /// - Initializer
    public init(store: StoreOf<ContentSettingFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension ContentSettingView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                if store.contentLoading {
                    PokitLoading()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            linkTextField
                            
                            titleTextField
                            
                            HStack(alignment: .bottom, spacing: 8) {
                                pokitSelectButton
                                
                                addPokitButton
                            }
                            
                            memoTextArea
                            
                            remindSwitchRadio
                        }
                        .padding(.horizontal, 20)
                    }
                    .overlay(alignment: .bottom) {
                        if store.state.showPopup {
                            PokitLinkPopup(
                                "최대 30개의 포킷을 생성할 수 있습니다. \n포킷을 삭제한 뒤에 추가해주세요.",
                                isPresented: $store.showPopup,
                                type: .text
                            )
                        }
                    }
                }
                
                let isDisable = store.urlText.isEmpty || store.title.isEmpty
                
                PokitBottomButton(
                    "저장하기",
                    state: isDisable ? .disable : .filled(.primary),
                    isLoading: $store.saveIsLoading,
                    action: { send(.saveBottomButtonTapped) }
                )
                .padding(.horizontal, 20)
            }
            .padding(.top, 16)
            .background(.pokit(.bg(.base)))
            .ignoresSafeArea(edges: focusedType == nil ? .bottom : [])
            .pokitNavigationBar(title: store.content == nil ? "링크 추가" : "링크 수정")
            .toolbar { navigationBar }
            .onAppear { send(.contentSettingViewOnAppeared) }
        }
    }
}
//MARK: - Configure View
private extension ContentSettingView {
    var navigationBar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            PokitToolbarButton(.icon(.arrowLeft), action: { send(.dismiss) })
        }
    }
    var linkTextField: some View {
        VStack(spacing: 16) {
            if let title = store.linkTitle {
                PokitLinkPreview(
                    title: title,
                    url: store.urlText,
                    imageURL: store.linkImageURL ?? "https://pokit-storage.s3.ap-northeast-2.amazonaws.com/logo/pokit.png"
                )
                .pokitBlurReplaceTransition(.smooth)
            }
            
            PokitTextInput(
                text: $store.urlText,
                label: "링크", 
                state: $store.linkTextInputState,
                focusState: $focusedType,
                equals: .link
            )
        }
    }
    
    var titleTextField: some View {
        PokitTextInput(
            text: $store.title,
            label: "제목", 
            state: $store.titleTextInpuState,
            maxLetter: 20,
            focusState: $focusedType,
            equals: .title) { }
    }
    
    var pokitSelectButton: some View {
        PokitSelect(
            selectedItem: $store.selectedPokit,
            label: "포킷",
            list: store.pokitList,
            action: { send(.pokitSelectItemButtonTapped(pokit: $0)) }
        )
    }
    
    var addPokitButton: some View {
        PokitIconButton(
            .icon(.plusR),
            state: .filled(.primary),
            size: .large,
            shape: .rectangle
        ) { send(.addPokitButtonTapped, animation: .pokitSpring) }
    }
    
    var memoTextArea: some View {
        PokitTextArea(
            text: $store.memo,
            label: "메모",
            state: $store.memoTextAreaState,
            focusState: $focusedType,
            equals: .memo
        )
        .frame(height: 192)
    }
    
    var remindSwitchRadio: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("리마인드 알림을 보내드릴까요?")
                .pokitFont(.b2(.m))
                .foregroundStyle(.pokit(.text(.secondary)))
                .padding(.bottom, 12)
            
            PokitSwitchRadio {
                PokitPartSwitchRadio(
                    labelText: "안받을래요",
                    selection: $store.isRemind,
                    to: .no,
                    style: .stroke
                )
                .matchedGeometryEffectBackground(id: heroEffect)
                
                PokitPartSwitchRadio(
                    labelText: "받을래요",
                    selection: $store.isRemind,
                    to: .yes,
                    style: .stroke
                )
                .matchedGeometryEffectBackground(id: heroEffect)
            }
            .padding(.bottom, 8)
            
            Text("일주일 후에 알림을 전송해드립니다")
                .pokitFont(.detail1)
                .foregroundStyle(.pokit(.text(.tertiary)))
        }
    }
}
private extension ContentSettingView {
    enum FocusedType: Equatable {
        case link
        case title
        case memo
    }
}
//MARK: - Preview
#Preview {
    ContentSettingView(
        store: Store(
            initialState: .init(),
            reducer: { ContentSettingFeature()._printChanges() }
        )
    )
}


