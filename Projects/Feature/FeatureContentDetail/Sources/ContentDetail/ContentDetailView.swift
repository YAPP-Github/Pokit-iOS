//
//  LinkDetailView.swift
//  Feature
//
//  Created by 김도형 on 7/19/24.

import SwiftUI

import ComposableArchitecture
import Domain
import DSKit

@ViewAction(for: ContentDetailFeature.self)
public struct ContentDetailView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<ContentDetailFeature>
    @FocusState
    private var isFocused: Bool
    /// - Initializer
    public init(store: StoreOf<ContentDetailFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension ContentDetailView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                if let content = store.content,
                   let favorites = content.favorites {
                    title(content: content)
                    ScrollView {
                        VStack(spacing: 0) {
                            contentMemo
                            
                            Divider()
                                .foregroundStyle(.pokit(.border(.tertiary)))
                            
                            bottomList(favorites: favorites)
                        }
                    }
                } else {
                    PokitLoading()
                }
            }
            .padding(.top, 28)
            .ignoresSafeArea(edges: .bottom)
            .background(.pokit(.bg(.base)))
            .pokitPresentationBackground()
            .pokitPresentationCornerRadius()
            .presentationDragIndicator(.visible)
            .presentationDetents([.height(588), .large])
            .overlay(alignment: .bottom) {
                if store.linkPopup != nil {
                    PokitLinkPopup(type: $store.linkPopup)
                }
            }
//            .dismissKeyboard(focused: $isFocused)
//            .onChange(of: isFocused) { send(.메모포커스_변경되었을때($0)) }
            .sheet(isPresented: $store.showAlert) {
                PokitAlert(
                    "링크를 정말 삭제하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며, \n복구하실 수 없습니다.",
                    confirmText: "삭제",
                    action: { send(.삭제확인_버튼_눌렀을때) },
                    cancelAction: { send(.경고시트_해제) }
                )
            }
            .sheet(isPresented: $store.showShareSheet) {
                if let content = store.content,
                   let shareURL = URL(string: content.data) {
                    PokitShareSheet(
                        items: [shareURL],
                        completion: { send(.링크_공유_완료되었을때) }
                    )
                    .presentationDetents([.medium, .large])
                }
            }
            .task {
                await send(.뷰가_나타났을때, animation: .pokitDissolve).finish()
            }
        }
    }
}
//MARK: - Configure View
private extension ContentDetailView {
    @ViewBuilder
    func remindAndBadge(content: BaseContentDetail) -> some View {
        HStack(spacing: 4) {
            if content.alertYn == .yes {
                Image(.icon(.bell))
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(.pokit(.icon(.inverseWh)))
                    .padding(2)
                    .background {
                        Circle()
                            .fill(.pokit(.bg(.brand)))
                    }
            }

            PokitBadge(state: .default(content.category.categoryName))

            Spacer()
        }
    }

    @ViewBuilder
    func title(content: BaseContentDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                remindAndBadge(content: content)

                Text(content.title)
                    .pokitFont(.title3)
                    .foregroundStyle(.pokit(.text(.primary)))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                HStack {
                    Spacer()

                    Text(content.createdAt)
                        .pokitFont(.detail2)
                        .foregroundStyle(.pokit(.text(.tertiary)))
                }
            }
            .padding(.horizontal, 20)

            Divider()
                .foregroundStyle(.pokit(.border(.tertiary)))
                .padding(.top, 4)
        }
    }

    var contentMemo: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom) {
                Text("메모")
                    .pokitFont(.b1(.m))
                    .foregroundStyle(.pokit(.text(.primary)))
                    .padding(.top, 16)
                
                Spacer()
                
                Image(.icon(.memo))
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.pokit(.border(.primary)))
            }
            
            PokitTextArea(
                text: $store.memo,
                state: $store.memoTextAreaState,
                baseState: .memo(isReadOnly: false),
                placeholder: "메모를 입력해주세요.",
                maxLetter: 100,
                focusState: $isFocused,
                equals: true
            )
            .toolbar { keyboardToolBar }
            .frame(minHeight: isFocused ? 164 : 132)
            .animation(.pokitDissolve, value: isFocused)
        }
        .padding(.bottom, 24)
        .padding(.horizontal, 20)
    }
    
    var keyboardToolBar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button("취소") {
                isFocused = false
                send(.키보드_취소_버튼_눌렀을때)
            }
            
            Spacer()
            
            Button("완료") {
                isFocused = false
                send(.키보드_완료_버튼_눌렀울때)
            }
        }
    }

    @ViewBuilder
    func bottomList(favorites: Bool) -> some View {
        VStack(spacing: 0) {
            PokitListButton(
                title: "즐겨찾기",
                type: .bottomSheet(
                    icon: favorites
                    ? .icon(.starFill)
                    : .icon(.star),
                    iconColor: favorites
                    ? .pokit(.icon(.brand))
                    : .pokit(.icon(.primary))
                ),
                action: { send(.즐겨찾기_버튼_눌렀을때) }
            )
            
            PokitListButton(
                title: "공유하기",
                type: .bottomSheet(
                    icon: .icon(.share),
                    iconColor: .pokit(.icon(.primary))
                ),
                action: { send(.공유_버튼_눌렀을때) }
            )
            
            PokitListButton(
                title: "수정하기",
                type: .bottomSheet(
                    icon: .icon(.edit),
                    iconColor: .pokit(.icon(.primary))
                ),
                action: { send(.수정_버튼_눌렀을때) }
            )
            
            PokitListButton(
                title: "삭제하기",
                type: .bottomSheet(
                    icon: .icon(.trash),
                    iconColor: .pokit(.icon(.primary))
                ),
                action: { send(.삭제_버튼_눌렀을때) }
            )
        }
    }
}
//MARK: - Preview
#Preview {
    ContentDetailView(
        store: Store(
            initialState: .init(
                contentId: 0
            ),
            reducer: { ContentDetailFeature()._printChanges() }
        )
    )
}


