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
import Util

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
                                .listRowInsets(EdgeInsets(.zero))
                                .onDelete(deleteAction: { delete(item) })
                                .id(item.id)
                            }
                            .listRowBackground(Color.pokit(.bg(.base)))
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
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 16) {
                    LazyImage(url: URL(string: item.categoryImageUrl ?? "")) { state in
                        if let image = state.image {
                            image.resizable().scaledToFill()
                        } else {
                            placeholder
                        }
                    }
                    .frame(width: 48, height: 48)
                    .background(
                        !item.isRead
                            ? .pokit(.bg(.base))
                            : .pokit(.bg(.primary))
                    )
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .pokitFont(.b2(.b))
                                .foregroundStyle(.pokit(.text(.primary)))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(item.body)
                                .pokitFont(.detail1)
                                .foregroundStyle(.pokit(.text(.tertiary)))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text(item.createdAt)
                            .pokitFont(.detail2)
                            .foregroundStyle(.pokit(.text(.tertiary)))
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(if: item.isRead) {
                    Color.pokit(.bg(.base))
                } else: {
                    Color.pokit(.color(.orange(._700))).opacity(0.05)
                }
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.pokit(.border(.tertiary)))
            }
        }

        private var placeholder: some View {
            ZStack {
                Circle()
                    .fill(.pokit(.bg(.primary)))

                Image(.image(.profile))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
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
