//
//  LinkListView.swift
//  Feature
//
//  Created by 김도형 on 8/2/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: ContentListFeature.self)
public struct ContentListView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<ContentListFeature>
    
    /// - Initializer
    public init(store: StoreOf<ContentListFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension ContentListView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 16) {
                listHeader
                    .padding(.horizontal, 20)
                
                list
            }
            .padding(.top, 12)
            .background(.pokit(.bg(.base)))
            .ignoresSafeArea(edges: .bottom)
            .pokitNavigationBar(title: store.contentType.title)
            .toolbar { toolbar }
            .sheet(item: $store.bottomSheetItem) { content in
                PokitBottomSheet(
                    items: [.share, .edit, .delete],
                    height: 224
                ) { send(.bottomSheetButtonTapped(delegate: $0, content: content)) }
            }
            .sheet(item: $store.alertItem) { content in
                PokitAlert(
                    "링크를 정말 삭제하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며, \n복구하실 수 없습니다.",
                    confirmText: "삭제"
                ) { send(.deleteAlertConfirmTapped(content: content)) }
            }
            .task { await send(.contentListViewOnAppeared, animation: .smooth).finish() }
        }
    }
}
//MARK: - Configure View
private extension ContentListView {
    var listHeader: some View {
        HStack {
            Text("링크 \(store.contents?.count ?? 0)개")
                .pokitFont(.detail1)
                .foregroundStyle(.pokit(.text(.secondary)))
            
            Spacer()
            
            PokitIconLTextLink(
                store.isListAscending ? "최신순" : "오래된순",
                icon: .icon(.align),
                action: { }
            )
            .contentTransition(.numericText())
        }
    }
    
    var list: some View {
        Group {
            if let contents = store.contents {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(contents) { content in
                            let isFirst = content == contents.first
                            let isLast = content == contents.last
                            
                            PokitLinkCard(
                                link: content,
                                action: { send(.linkCardTapped(content: content)) },
                                kebabAction: { send(.kebabButtonTapped(content: content)) }
                            )
                            .divider(isFirst: isFirst, isLast: isLast)
                            .pokitScrollTransition(.opacity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            } else {
                PokitLoading()
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            PokitToolbarButton(.icon(.arrowLeft)) {
                send(.backButtonTapped)
            }
        }
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        ContentListView(
            store: Store(
                initialState: .init(contentType: .favorite),
                reducer: { ContentListFeature() }
            )
        )
    }
}


