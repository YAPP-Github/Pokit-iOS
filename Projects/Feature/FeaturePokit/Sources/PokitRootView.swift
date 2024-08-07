//
//  PokitRootView.swift
//  Feature
//
//  Created by 김민호 on 7/16/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: PokitRootFeature.self)
public struct PokitRootView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<PokitRootFeature>
    private let column = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    /// - Initializer
    public init(store: StoreOf<PokitRootFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitRootView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                self.filterHeader
                self.cardScrollView
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.pokit(.bg(.base)))
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $store.isKebobSheetPresented) {
                PokitBottomSheet(
                    items: [.share, .edit, .delete],
                    height: 224,
                    delegateSend: { store.send(.scope(.bottomSheet($0))) }
                )
            }
            .sheet(isPresented: $store.isPokitDeleteSheetPresented) {
                PokitDeleteBottomSheet(
                    type: store.folderType == .folder(.포킷)
                    ? .포킷삭제
                    : .링크삭제,
                    delegateSend: { store.send(.scope(.deleteBottomSheet($0))) }
                )
            }
            .onAppear { send(.pokitRootViewOnAppeared) }
        }
    }
}
//MARK: - Configure View
private extension PokitRootView {    
    var filterHeader: some View {
        HStack(spacing: 8) {
            PokitIconLButton(
                "포킷",
                .icon(.folderLine),
                state: store.folderType == .folder(.포킷)
                ? .filled(.primary)
                : .default(.secondary),
                size: .small,
                shape: .round,
                action: { send(.filterButtonTapped(.포킷)) }
            )
            
            PokitIconLButton(
                "미분류",
                .icon(.info),
                state: store.folderType == .folder(.미분류)
                ? .filled(.primary)
                : .default(.secondary),
                size: .small,
                shape: .round,
                action: { send(.filterButtonTapped(.미분류)) }
            )
            
            Spacer()
            
            Button(action: { send(.sortButtonTapped) }) {
                HStack(spacing: 2) {
                    Image(.icon(.align))
                        .resizable()
                        .frame(width: 18, height: 18)
                    Text(store.sortType == .sort(.최신순) ? "최신순" : "이름순")
                        .pokitFont(.b3(.m))
                        .foregroundStyle(.pokit(.text(.secondary)))
                }
            }
            .buttonStyle(.plain)
        }
        .animation(.snappy(duration: 0.7), value: store.folderType)
    }
    
    var cardScrollView: some View {
        ScrollView {
            if store.folderType == .folder(.포킷) {
                pokitView
                    .pokitBlurReplaceTransition(.smooth)
            } else {
                unclassifiedView
                    .pokitBlurReplaceTransition(.smooth)
            }
        }
        .padding(.top, 20)
        .scrollIndicators(.hidden)
        .animation(.smooth, value: store.categories.elements)
        .animation(.smooth, value: store.unclassifiedContents.elements)
        .animation(.spring, value: store.folderType)
    }
    
    var pokitView: some View {
        LazyVGrid(columns: column, spacing: 12) {
            ForEach(store.categories, id: \.id) { item in
                PokitCard(
                    category: item,
                    action: { send(.categoryTapped(item)) },
                    kebabAction: { send(.kebobButtonTapped(item)) }
                )
            }
        }
        .padding(.bottom, 150)
    }
    var unclassifiedView: some View {
        VStack(spacing: 0) {
            ForEach(store.unclassifiedContents) { content in
                let isFirst = content == store.unclassifiedContents.first
                let isLast = content == store.unclassifiedContents.last
                
                PokitLinkCard(
                    link: content,
                    action: { send(.contentItemTapped(content)) },
                    kebabAction: { send(.unclassifiedKebobButtonTapped(content)) }
                )
                .divider(isFirst: isFirst, isLast: isLast)
            }
        }
        .padding(.bottom, 150)
    }
}

//MARK: - Preview
#Preview {
    Group {
        PokitRootView(
            store: Store(
                initialState: .init(),
                reducer: { PokitRootFeature() }
            )
        )
    }
}


