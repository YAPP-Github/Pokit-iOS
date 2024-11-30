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
                            
                            pokitSelectButton
                            
                            memoTextArea
                            
                            remindSwitchRadio
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                    .overlay(alignment: .bottom) {
                        if store.linkPopup != nil {
                            PokitLinkPopup(
                                type: $store.linkPopup,
                                action: { send(.링크팝업_버튼_눌렀을때, animation: .pokitSpring) }
                            )
                        }
                    }
                    .pokitMaxWidth()
                }
                
                let isDisable = store.urlText.isEmpty ||
                                store.title.isEmpty ||
                                store.memoTextAreaState == .error(message: "최대 100자까지 입력가능합니다.")
                
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
                PokitToolbarButton(.icon(
                    store.isShareExtension
                    ? .x
                    : .arrowLeft
                )) {
                    send(.뒤로가기_버튼_눌렀을때)
                }
            }
        }
        .padding(.top, 8)
    }
    var linkTextField: some View {
        VStack(spacing: 16) {
            if !store.urlText.isEmpty {
                let isParsed = store.linkTitle != nil || store.linkImageURL != nil
                
                PokitLinkPreview(
                    title: store.linkTitle == "제목을 입력해주세요"
                    ? store.title.isEmpty ? "제목을 입력해주세요" : store.title
                    : store.linkTitle,
                    url: isParsed ? store.urlText : nil,
                    imageURL: store.linkImageURL
                )
                .pokitBlurReplaceTransition(.pokitDissolve)
            }
            
            PokitTextInput(
                text: $store.urlText,
                label: "링크",
                type: .iconR(
                    icon: .icon(.x),
                    action: { send(.링크지우기_버튼_눌렀을때) }
                ),
                shape: .rectangle,
                state: $store.linkTextInputState,
                focusState: $focusedType,
                equals: .link
            )
        }
        .animation(.pokitSpring, value: store.urlText)
    }
    
    var titleTextField: some View {
        PokitTextInput(
            text: $store.title,
            label: "제목",
            type: .iconR(
                icon: .icon(.x),
                action: { send(.제목지우기_버튼_눌렀을때) }
            ),
            shape: .rectangle,
            state: $store.titleTextInpuState,
            focusState: $focusedType,
            equals: .title
        )
    }
    
    var pokitSelectButton: some View {
        PokitSelect(
            selectedItem: $store.selectedPokit,
            label: "포킷",
            list: store.pokitList,
            action: { send(.포킷선택_항목_눌렀을때(pokit: $0), animation: .pokitDissolve) },
            addAction: { send(.포킷추가_버튼_눌렀을때, animation: .pokitSpring) }
        )
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


