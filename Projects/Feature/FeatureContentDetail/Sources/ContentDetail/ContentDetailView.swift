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
                if let content = store.content {
                    title(content: content)
                    ScrollView {
                        VStack {
                            contentLinkPreview(content: content)
                                .padding(.vertical, 24)
                        }
                    }
                    .overlay(alignment: .bottom) {
                        bottomToolbar(content: content)
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
            .presentationDetents([.medium, .large])
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

    @ViewBuilder
    func contentLinkPreview(content: BaseContentDetail) -> some View {
        VStack(spacing: 16) {
            if store.showLinkPreview {
                PokitLinkPreview(
                    title: store.linkTitle ?? content.title,
                    url: content.data,
                    imageURL: store.linkImageURL ?? "https://pokit-storage.s3.ap-northeast-2.amazonaws.com/logo/pokit.png"
                )
                .pokitBlurReplaceTransition(.pokitDissolve)
            }

            contentMemo(content: content)
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    func contentMemo(content: BaseContentDetail) -> some View {
        let isEmpty = content.memo.isEmpty

        HStack {
            VStack {
                Group {
                    if isEmpty {
                        Text("메모를 작성해보세요.")
                            .foregroundStyle(.pokit(.text(.tertiary)))
                    } else {
                        Text(content.memo)
                            .foregroundStyle(.pokit(.text(.primary)))
                    }
                }
                .pokitFont(.b3(.r))
                .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(16)

            Spacer()
        }
        .frame(minHeight: 132)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 1, green: 0.96, blue: 0.89))
        }
    }

    @ViewBuilder
    func favorite(favorites: Bool) -> some View {
        Button(action: { send(.즐겨찾기_버튼_눌렀을때, animation: .pokitDissolve) }) {
            Image(favorites ? .icon(.starFill) : .icon(.starFill))
                .resizable()
                .scaledToFit()
                .foregroundStyle(.pokit(.icon(favorites ? .brand : .tertiary)))
                .frame(width: 24, height: 24)
        }
    }

    @ViewBuilder
    func bottomToolbar(content: BaseContentDetail) -> some View {
        HStack(spacing: 14) {
            if let favorites = content.favorites {
                favorite(favorites: favorites)
            }

            Spacer()

            Group {
                toolbarButton(
                    .icon(.share),
                    action: { send(.공유_버튼_눌렀을때) }
                )

                toolbarButton(
                    .icon(.edit),
                    action: { send(.수정_버튼_눌렀을때) }
                )

                toolbarButton(
                    .icon(.trash),
                    action: { send(.삭제_버튼_눌렀을때) }
                )
            }
            .disabled(store.contentId == nil)
            .opacity(store.contentId == nil ? 0 : 1)
        }
        .padding(.top, 12)
        .padding(.bottom, 40)
        .padding(.horizontal, 16)
        .background(.pokit(.bg(.base)))
        .overlay(alignment: .top) {
            Divider()
                .foregroundStyle(.pokit(.border(.tertiary)))
        }
    }

    @ViewBuilder
    func toolbarButton(
        _ icon: PokitImage,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.pokit(.icon(.secondary)))
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


