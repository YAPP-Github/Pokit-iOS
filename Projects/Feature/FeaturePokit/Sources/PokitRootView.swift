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
    public var store: StoreOf<PokitRootFeature>
    
    /// - Initializer
    public init(store: StoreOf<PokitRootFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitRootView {
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack(spacing: 0) {
                    filterHeader
                    
                    ScrollView {
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .scrollIndicators(.hidden)
                .toolbar { self.navigationBar }
            }
        }
    }
}
//MARK: - Configure View
private extension PokitRootView {
    @ToolbarContentBuilder
    var navigationBar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text("Pokit")
                .font(.system(size: 36, weight: .heavy))
                .foregroundStyle(.pokit(.text(.brand)))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 12) {
                PokitToolbarButton(
                    .icon(.search),
                    action: { send(.searchButtonTapped) }
                )
                PokitToolbarButton(
                    .icon(.bell),
                    action: { send(.alertButtonTapped) }
                )
                PokitToolbarButton(
                    .icon(.setup), 
                    action: { send(.settingButtonTapped) }
                )
            }
        }
    }
    
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
}
//MARK: - Preview
#Preview {
    PokitRootView(
        store: Store(
            initialState: .init(),
            reducer: { PokitRootFeature() }
        )
    )
}


