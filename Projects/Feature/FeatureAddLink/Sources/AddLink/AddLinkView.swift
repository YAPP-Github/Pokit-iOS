//
//  AddLinkView.swift
//  Feature
//
//  Created by 김도형 on 7/17/24.

import ComposableArchitecture
import SwiftUI

import DSKit

@ViewAction(for: AddLinkFeature.self)
public struct AddLinkView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<AddLinkFeature>
    @FocusState
    private var focusedType: FocusedType?
    @Namespace
    private var heroEffect
    /// - Initializer
    public init(store: StoreOf<AddLinkFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension AddLinkView {
    var body: some View {
        WithPerceptionTracking {
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
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .overlay(alignment: .bottom) {
                PokitBottomButton(
                    "저장하기",
                    state: .filled(.primary),
                    action: {}
                )
            }
        }
    }
}
//MARK: - Configure View
private extension AddLinkView {
    var linkTextField: some View {
        VStack(spacing: 16) {
            if let store = store.scope(state: \.previewLink, action: \.previewLink) {
                PreviewLinkView(store: store)
                    .pokitBlurReplaceTransition(.smooth)
            }
            
            PokitTextInput(
                text: $store.urlText,
                label: "링크",
                maxLetter: 50,
                focusState: $focusedType,
                equals: .link,
                onSubmit: { send(.linkTextFieldOnSubmitted, animation: .smooth) }
            )
        }
    }
    
    var titleTextField: some View {
        PokitTextInput(
            text: $store.title,
            label: "제목",
            maxLetter: 20,
            focusState: $focusedType,
            equals: .title) { }
    }
    
    var pokitSelectButton: some View {
        PokitSelect(
            selectedItem: store.selectedPokit,
            label: "포킷",
            list: store.pokitList) { send(.pokitSelectItemButtonTapped(pokit: $0)) }
    }
    
    var addPokitButton: some View {
        PokitIconButton(
            .icon(.plusR),
            state: .filled(.primary),
            size: .large,
            shape: .rectangle) { }
    }
    
    var memoTextArea: some View {
        PokitTextArea(
            text: $store.memo,
            label: "메모",
            focusState: $focusedType,
            equals: .memo
        )
        .frame(height: 192)
    }
    
    var remindSwitchRadio: some View {
        PokitSwitchRadio {
            PokitPartSwitchRadio(
                labelText: "안받을래요",
                selection: $store.isRemind,
                to: false,
                style: .stroke
            )
            .matchedGeometryEffectBackground(id: heroEffect)
            
            PokitPartSwitchRadio(
                labelText: "받을래요",
                selection: $store.isRemind,
                to: true,
                style: .stroke
            )
            .matchedGeometryEffectBackground(id: heroEffect)
        }
    }
}
private extension AddLinkView {
    enum FocusedType: Equatable {
        case link
        case title
        case memo
    }
}
//MARK: - Preview
#Preview {
    AddLinkView(
        store: Store(
            initialState: .init(),
            reducer: { AddLinkFeature()._printChanges() }
        )
    )
}


