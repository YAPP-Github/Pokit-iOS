//
//  PokitLinkEditView.swift
//  Feature
//
//  Created by 김민호 on 12/24/24.

import SwiftUI

import ComposableArchitecture
import DSKit
import Domain
import CoreKit

@ViewAction(for: PokitLinkEditFeature.self)
public struct PokitLinkEditView: View {
    /// - Properties
    public var store: StoreOf<PokitLinkEditFeature>
    
    /// - Initializer
    public init(store: StoreOf<PokitLinkEditFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitLinkEditView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                ScrollView {
                    ForEach(store.list, id: \.id) { item in
                        let isFirst = item.id == self.store.list.first?.id
                        let isLast = item.id == self.store.list.last?.id
                        PokitLinkCard(
                            link: item,
                            state: isFirst
                            ? .top
                            : isLast ? .bottom : .middle,
                            type: .unCatgorized(isSelected: store.selectedItems.contains(item)),
                            action: nil,
                            kebabAction: nil,
                            fetchMetaData: {},
                            favoriteAction: nil,
                            selectAction: { send(.체크박스_선택했을때(item)) }
                        )
                    }
                }
            }
            .padding(.top, 16)
            .pokitNavigationBar(navigationBar)
            .overlay(alignment: .bottom) {
                actionFloatButtonView
            }
            .padding(.horizontal, 20)
            .ignoresSafeArea(edges: .bottom)
            .padding(.bottom, 24)
        }
    }
}
//MARK: - Configure View
private extension PokitLinkEditView {
    var navigationBar: some View {
        PokitHeader(title: "링크 분류하기") {
            PokitHeaderItems(placement: .leading) {
                PokitToolbarButton(.icon(.x)) {
                    send(.dismiss)
                }
            }
        }
        .padding(.top, 8)
    }
    
    var actionFloatButtonView: some View {
        EmptyView()
    }
}
//MARK: - Preview
#Preview {
    PokitLinkEditView(
        store: Store(
            initialState: .init(linkList: BaseContentListInquiry(data: nil, page: 0, size: 0, sort: [], hasNext: false)),
            reducer: { PokitLinkEditFeature() }
        )
    )
}


