//
//  LinkListView.swift
//  Feature
//
//  Created by 김도형 on 8/2/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: LinkListFeature.self)
public struct LinkListView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<LinkListFeature>
    
    /// - Initializer
    public init(store: StoreOf<LinkListFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension LinkListView {
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
            .pokitNavigationBar(title: store.linkType.title)
            .toolbar { toolbar }
            .sheet(item: $store.bottomSheetItem) { link in
                PokitBottomSheet(
                    items: [.share, .edit, .delete],
                    height: 224
                ) { send(.bottomSheetButtonTapped(delegate: $0, link: link)) }
            }
            .sheet(item: $store.alertItem) { link in
                PokitAlert(
                    "링크를 정말 삭제하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며, \n복구하실 수 없습니다.",
                    confirmText: "삭제"
                ) { send(.deleteAlertConfirmTapped(link: link)) }
            }
        }
    }
}
//MARK: - Configure View
private extension LinkListView {
    var listHeader: some View {
        HStack {
            Text("링크 \(store.links.count)개")
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
        ScrollView {
            VStack(spacing: 0) {
                ForEach(store.links) { link in
                    let isFirst = link == store.links.first
                    let isLast = link == store.links.last
                    
                    PokitLinkCard(
                        link: link,
                        action: { send(.linkCardTapped(link: link)) },
                        kebabAction: { send(.kebabButtonTapped(link: link)) }
                    )
                    .divider(isFirst: isFirst, isLast: isLast)
                    .pokitScrollTransition(.opacity)
                }
            }
            .padding(.horizontal, 20)
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
        LinkListView(
            store: Store(
                initialState: .init(linkType: .favorite),
                reducer: { LinkListFeature() }
            )
        )
    }
}


