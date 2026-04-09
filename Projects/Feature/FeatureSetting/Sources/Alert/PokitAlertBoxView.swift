//
//  PokitAlertBoxView.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import SwiftUI

import ComposableArchitecture
import DSKit
import Domain
import NukeUI

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
                if let alertContents = store.alertContents {
                    if alertContents.isEmpty {
                        VStack {
                            PokitCaution(type: .알림없음)
                                .padding(.top, 84)
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(alertContents, id: \.id) { item in
                                Button(action: { send(.알람_항목_선택했을때(item: item)) }) {
                                    AlertContent(item: item)
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .onDelete(deleteAction: { delete(item) })
                                .id(item.id)
                            }
                            .listRowBackground(Color.pokit(.bg(.base)))
                            .padding(.top, 16)
                        }
                        .listStyle(.plain)
                    }
                } else {
                    PokitLoading()
                }
            }
            .pokitNavigationBar { navigationBar }
            .ignoresSafeArea(edges: .bottom)
            .task { await send(.뷰가_나타났을때).finish() }
        }
    }
}
//MARK: - Configure View
private extension PokitAlertBoxView {
    var navigationBar: some View {
        PokitHeader(title: "알림함") {
            PokitHeaderItems(placement: .leading) {
                PokitToolbarButton(.icon(.arrowLeft)) {
                    send(.dismiss)
                }
            }
        }
        .padding(.top, 8)
    }
    
    func delete(_ item: NotificationItem) {
        send(.밀어서_삭제했을때(item: item),animation: .pokitSpring)
    }

    struct AlertContent: View {
        let item: NotificationItem

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    LazyImage(url: URL(string: item.categoryImageUrl ?? "")) { state in
                        if let image = state.image {
                            image.resizable()
                        } else {
                            placeholder
                        }
                    }
                    .frame(width: 94, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    VStack(alignment: .leading, spacing: 0) {
                        Text(item.title)
                            .pokitFont(.b2(.b))
                            .foregroundStyle(.pokit(.text(.primary)))
                            .lineLimit(1)
                            .padding(.bottom, 4)
                        Text(item.body)
                            .pokitFont(.detail2)
                            .foregroundStyle(.pokit(.text(.secondary)))
                            .padding(.bottom, 8)
                        Text(item.createdAt)
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
            .background(
                !item.isRead
                    ? .pokit(.color(.orange(._50)))
                    : .clear
            )
        }

        private var placeholder: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.pokit(.bg(.primary)))

                Image(.image(.profile))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
            }
        }
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        PokitAlertBoxView(
            store: Store(
                initialState: .init(),
                reducer: { PokitAlertBoxFeature() }
            )
        )
    }
}
