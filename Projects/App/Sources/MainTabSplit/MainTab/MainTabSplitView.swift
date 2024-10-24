//
//  MainTabSplitView.swift
//  App
//
//  Created by 김도형 on 10/24/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: MainTabSplitFeature.self)
public struct MainTabSplitView: View {
    /// - Properties
    public var store: StoreOf<MainTabSplitFeature>
    
    /// - Initializer
    public init(store: StoreOf<MainTabSplitFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension MainTabSplitView {
    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.state {
                case .pokit:
                    if let store = store.scope(state: \.pokit, action: \.pokit) {
                        PokitSplitView(store: store)
                    }
                case .remind:
                    if let store = store.scope(state: \.remind, action: \.remind) {
                        RemindSplitView(store: store)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                mainTab
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
//MARK: - Configure View
private extension MainTabSplitView {
    var mainTab: some View {
        tab
            .pokitShadow(
                x: 0,
                y: -2,
                blur: 20,
                spread: 0,
                color: Color.black,
                colorPercent: 10
            )
            .overlay(alignment: .top) {
                plusButton
                    .offset(y: -30)
            }
            .frame(width: 320)
            .padding(.bottom, 36)
    }
    
    var tab: some View {
        HStack {
            tabButton(
                title: "포킷",
                titleColor: pokitButtonTextColor,
                icon: .icon(.folderFill),
                iconColor: pokitButtonIconColor,
                action: { send(.포킷_버튼_눌렀을때) }
            )
            
            Spacer()
            
            tabButton(
                title: "리마인드",
                titleColor: remindButtonTextColor,
                icon: .icon(.remind),
                iconColor: remindButtonIconColor,
                action: { send(.리마인드_버튼_눌렀을때) }
            )
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
        .padding(.horizontal, 48)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.pokit(.bg(.base)))
        }
    }
    
    var plusButton: some View {
        Button {
            send(.추가_버튼_눌렀을때)
        } label: {
            Image(.icon(.plus))
                .resizable()
                .frame(width: 36, height: 36)
                .foregroundStyle(.pokit(.icon(.inverseWh)))
                .padding(12)
                .background {
                    GeometryReader { _ in
                        Circle()
                            .fill(.pokit(.bg(.brand)))
                    }
                    .coordinateSpace(name: "plusButton")
                }
        }
    }
    
    @ViewBuilder
    func tabButton(
        title: String,
        titleColor: Color,
        icon: PokitImage,
        iconColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 4) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(iconColor)
            
            Text(title)
                .pokitFont(.detail2)
                .foregroundStyle(titleColor)
        }
        .padding(.horizontal, 28)
    }
}

private extension MainTabSplitView {
    var pokitButtonIconColor: Color {
        switch store.state {
        case .pokit: return .pokit(.icon(.primary))
        case .remind: return .pokit(.icon(.tertiary))
        }
    }
    
    var pokitButtonTextColor: Color {
        switch store.state {
        case .pokit: return .pokit(.text(.primary))
        case .remind: return .pokit(.text(.tertiary))
        }
    }
    
    var remindButtonIconColor: Color {
        switch store.state {
        case .pokit: return .pokit(.icon(.tertiary))
        case .remind: return .pokit(.icon(.primary))
        }
    }
    
    var remindButtonTextColor: Color {
        switch store.state {
        case .pokit: return .pokit(.text(.tertiary))
        case .remind: return .pokit(.text(.primary))
        }
    }
}

//MARK: - Preview
#Preview {
    MainTabSplitView(
        store: Store(
            initialState: .init(),
            reducer: { MainTabSplitFeature() }
        )
    )
}


