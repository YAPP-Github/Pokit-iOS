//
//  AddLinkView.swift
//  Feature
//
//  Created by 김도형 on 7/17/24.

import SwiftUI

import ComposableArchitecture
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
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .overlay(alignment: .bottom) {
                let isDisable = store.state.urlText.isEmpty || store.state.title.isEmpty
                
                PokitBottomButton(
                    "저장하기",
                    state: isDisable ? .disable : .filled(.primary),
                    action: { }
                )
                .background()
            }
            .pokitNavigationBar(title: store.link == nil ? "링크 추가" : "링크 수정")
            .onAppear { send(.addLinkViewOnAppeared) }
            .sheet(
                item: $store.scope(
                    state: \.addPokitSheet,
                    action: \.addPokitSheet
                )
            ) { addPokitSheetFeature in
                AddPokitSheetView(store: addPokitSheetFeature)
            }
        }
    }
}
//MARK: - Configure View
private extension AddLinkView {
    var linkTextField: some View {
        VStack(spacing: 16) {
            if let title = store.linkTitle,
               let image = store.linkImage {
                PokitLinkPreview(
                    title: title,
                    url: store.urlText,
                    image: image
                )
                .pokitBlurReplaceTransition(.smooth)
            }
            
            PokitTextInput(
                text: $store.urlText,
                label: "링크",
                focusState: $focusedType,
                equals: .link
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
            list: store.pokitList,
            action: { send(.pokitSelectItemButtonTapped(pokit: $0)) }
        )
    }
    
    var addPokitButton: some View {
        PokitIconButton(
            .icon(.plusR),
            state: .filled(.primary),
            size: .large,
            shape: .rectangle) { send(.addPokitButtonTapped) }
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
        VStack(alignment: .leading, spacing: 0) {
            Text("리마인드 알림을 보내드릴까요?")
                .pokitFont(.b2(.m))
                .foregroundStyle(.pokit(.text(.secondary)))
                .padding(.bottom, 12)
            
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
            .padding(.bottom, 8)
            
            Text("일주일 후에 알림을 전송해드립니다")
                .pokitFont(.detail1)
                .foregroundStyle(.pokit(.text(.tertiary)))
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


