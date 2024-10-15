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
                        .padding(.top, 16)
                    }
                    .overlay(alignment: .bottom) {
                        if store.state.showMaxCategoryPopup {
                            PokitLinkPopup(
                                "최대 30개의 포킷을 생성할 수 있습니다. \n포킷을 삭제한 뒤에 추가해주세요.",
                                isPresented: $store.showMaxCategoryPopup,
                                type: .text
                            )
                            .animation(.pokitSpring, value: store.showMaxCategoryPopup)
                        } else if store.state.showDetectedURLPopup {
                            PokitLinkPopup(
                                "복사한 링크 저장하기",
                                isPresented: $store.showDetectedURLPopup,
                                type: .link(url: store.link ?? ""),
                                action: { send(.링크복사_버튼_눌렀을때, animation: .pokitSpring) }
                            )
                        }
                    }
                    .pokitMaxWidth()
                }
                
                let isDisable = store.urlText.isEmpty || store.title.isEmpty || store.memoTextAreaState == .error(message: "최대 100자까지 입력가능합니다.")
                
                PokitBottomButton(
                    "저장하기",
                    state: isDisable ? .disable : .filled(.primary),
                    isLoading: $store.saveIsLoading,
                    action: { send(.저장_버튼_눌렀을때) }
                )
                .padding(.horizontal, 20)
                .pokitMaxWidth()
            }
            .pokitNavigationBar { navigationBar }
            .ignoresSafeArea(edges: focusedType == nil ? .bottom : [])
            .onAppear { send(.뷰가_나타났을때) }
        }
    }
}
//MARK: - Configure View
private extension ContentSettingView {
    var navigationBar: some View {
        PokitHeader(title: store.content == nil ? "링크 추가" : "링크 수정") {
            PokitHeaderItems(placement: .leading) {
                PokitToolbarButton(.icon(.arrowLeft)) {
                    send(.뒤로가기_버튼_눌렀을때)
                }
            }
        }
        .padding(.top, 8)
    }
    var linkTextField: some View {
        VStack(spacing: 16) {
            if store.showLinkPreview {
                PokitLinkPreview(
                    title: store.linkTitle ?? (
                        store.title.isEmpty ? "제목을 입력해주세요" : store.title
                    ),
                    url: store.urlText,
                    imageURL: store.linkImageURL ?? "https://pokit-storage.s3.ap-northeast-2.amazonaws.com/logo/pokit.png"
                )
                .pokitBlurReplaceTransition(.pokitDissolve)
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
            focusState: $focusedType,
            equals: .title) { }
    }
    
    var pokitSelectButton: some View {
        PokitSelect(
            selectedItem: $store.selectedPokit,
            label: "포킷",
            list: store.pokitList,
            action: { send(.포킷선택_항목_눌렀을때(pokit: $0), animation: .pokitDissolve) }
        )
    }
    
    var addPokitButton: some View {
        PokitIconButton(
            .icon(.plusR),
            state: .filled(.primary),
            size: .large,
            shape: .rectangle
        ) { send(.포킷추가_버튼_눌렀을때, animation: .pokitSpring) }
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
                .background()
                
                PokitPartSwitchRadio(
                    labelText: "받을래요",
                    selection: $store.isRemind,
                    to: .yes,
                    style: .stroke
                )
                .background()
            }
            .padding(.bottom, 8)
            
            Text("일주일 후에 알림을 전송해드립니다")
                .pokitFont(.detail1)
                .foregroundStyle(.pokit(.text(.tertiary)))
        }
        .padding(.bottom, 16)
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


