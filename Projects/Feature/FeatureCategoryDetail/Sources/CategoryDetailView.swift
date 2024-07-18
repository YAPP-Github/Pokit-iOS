//
//  CategoryDetailView.swift
//  Feature
//
//  Created by 김민호 on 7/17/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: CategoryDetailFeature.self)
public struct CategoryDetailView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<CategoryDetailFeature>
    
    /// - Initializer
    public init(store: StoreOf<CategoryDetailFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension CategoryDetailView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 16) {
                header
                linkScrollView
            }
            .padding(.top, 12)
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    PokitToolbarButton(.icon(.arrowLeft), action: {})
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    PokitToolbarButton(.icon(.kebab), action: { send(.categoryKebobButtonTapped) })
                }
            }
            .sheet(isPresented: $store.isCategorySheetPresented) {
                PokitBottomSheet(
                    items: [.share, .edit, .delete],
                    height: 224,
                    delegateSend: { store.send(.scope(.categoryBottomSheet($0))) }
                )
            }
            .sheet(isPresented: $store.isPokitDeleteSheetPresented) {
                PokitDeleteBottomSheet(
                    type: .포킷삭제,
                    delegateSend: { store.send(.scope(.categoryDeleteBottomSheet($0))) }
                )
            }
        }
    }
}
//MARK: - Configure View
private extension CategoryDetailView {
    var header: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                /// cateogry title
                Button(action: { }) {
                    Text("포킷")
                        .foregroundStyle(.pokit(.text(.primary)))
                        .pokitFont(.title1)
                    Image(.icon(.arrowDown))
                        .resizable()
                        .frame(width: 24, height: 24)
                    Spacer()
                }
                .buttonStyle(.plain)
            }
            HStack {
                Text("링크 14개")
                Spacer()
                PokitIconLButton(
                    "필터",
                    .icon(.filter),
                    state: .filled(.primary),
                    size: .small,
                    shape: .round,
                    action: {}
                )
            }
        }
    }
    var linkScrollView: some View {
        ScrollView(showsIndicators: false) {
            ForEach(store.mock) { link in
                let isFirst = link == store.mock.first
                let isLast = link == store.mock.last
                
                PokitLinkCard(link: link, action: {}, kebabAction: {})
                    .divider(isFirst: isFirst, isLast: isLast)
            }
        }
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        CategoryDetailView(
            store: Store(
                initialState: .init(mock: DetailItemMock.recommendedMock),
                reducer: { CategoryDetailFeature() }
            )
        )
    }
}


