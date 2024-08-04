//
//  PokitAlertBoxView.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: PokitAlertBoxFeature.self)
public struct PokitAlertBoxView: View {
    /// - Properties
    public var store: StoreOf<PokitAlertBoxFeature>
    
    /// - Initializer
    public init(store: StoreOf<PokitAlertBoxFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitAlertBoxView {
    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                List {
                    ForEach(store.mock, id: \.id) { item in
                        Button(action: { send(.itemSelected(item: item)) }) {
                            AlertItem(item: item)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .onDelete(deleteAction: { delete(item) })
                    }
                    .listRowBackground(Color.pokit(.bg(.base)))
                }
                .listStyle(.plain)
            }
            .padding(.top, 16)
            .background(.pokit(.bg(.base)))
            .ignoresSafeArea(edges: .bottom)
            .pokitNavigationBar(title: "알림함")
            .toolbar { navigationBar }
            .onAppear { send(.onAppear) }
        }
    }
}
//MARK: - Configure View
private extension PokitAlertBoxView {
    @ToolbarContentBuilder
    var navigationBar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            PokitToolbarButton(
                .icon(.arrowLeft),
                action: { send(.dismiss) }
            )
        }
    }
    
    func delete(_ item: AlertMock) {
        send(.deleteSwiped(item: item),animation: .spring)
    }

    struct AlertItem: View {
        var item: AlertMock
        
        init(item: AlertMock) {
            self.item = item
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 94, height: 70)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(item.title)
                            .pokitFont(.b2(.b))
                            .foregroundStyle(.pokit(.text(.primary)))
                            .lineLimit(1)
                            .padding(.bottom, 4)
                        Text(item.contents)
                            .pokitFont(.detail2)
                            .foregroundStyle(.pokit(.text(.secondary)))
                            .padding(.bottom, 8)
                        Text(item.ago)
                            .pokitFont(.detail2)
                            .foregroundStyle(.pokit(.text(.tertiary)))
                    }
                }
                .padding(.horizontal, 20)
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.pokit(.border(.tertiary)))
            }
            .padding(.top, 20)
        }
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        PokitAlertBoxView(
            store: Store(
                initialState: .init(alertItems: AlertMock.mock),
                reducer: { PokitAlertBoxFeature() }
            )
        )
    }
}


