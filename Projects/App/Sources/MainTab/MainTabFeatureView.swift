//
//  MainTabView.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import SwiftUI

import ComposableArchitecture
import DSKit
import FeaturePokit
import FeatureRemind
import FeatureSetting
import FeatureCategorySetting
import FeatureLinkDetail
import FeatureAddLink
import FeatureCategoryDetail


@ViewAction(for: MainTabFeature.self)
public struct MainTabView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<MainTabFeature>
    /// - Initializer
    public init(store: StoreOf<MainTabFeature>) {
        self.store = store
        UITabBar.appearance().isHidden = true
    }
}
//MARK: - View
public extension MainTabView {
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                content
            } destination: { store in
                switch store.state {
                case .알림함:
                    if let store = store.scope(state: \.알림함, action: \.알림함) {
                        PokitAlertBoxView(store: store)
                    }
                case .검색:
                    if let store = store.scope(state: \.검색, action: \.검색) {
                        PokitSearchView(store: store)
                    }
                case .설정:
                    if let store = store.scope(state: \.설정, action: \.설정) {
                        PokitSettingView(store: store)
                    }
                case .포킷추가및수정:
                    if let store = store.scope(state: \.포킷추가및수정, action: \.포킷추가및수정) {
                        PokitCategorySettingView(store: store)
                    }
                case .링크추가및수정:
                    if let store = store.scope(state: \.링크추가및수정, action: \.링크추가및수정) {
                        AddLinkView(store: store)
                    }
                case .카테고리상세:
                    if let store = store.scope(state: \.카테고리상세, action: \.카테고리상세) {
                        CategoryDetailView(store: store)
                    }
                }
            }
        }
    }
}
//MARK: - Configure View
private extension MainTabView {
    var content: some View {
        VStack(spacing: 40)  {
            tabView
            bottomTabBar
        }
        .sheet(isPresented: $store.isBottomSheetPresented) {
            ///Todo: bottom sheet 추가
            TestView2()
        }
        .sheet(
            item: $store.scope(
                state: \.linkDetail,
                action: \.linkDetail
            )
        ) { store in
            LinkDetailView(store: store)
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(edges: .bottom)
        .toolbar { navigationBar }
    }
    
    var tabView: some View {
        TabView(selection: $store.selectedTab) {
            switch store.selectedTab {
            case .pokit:
                PokitRootView(store: store.scope(state: \.pokit, action: \.pokit))
            case .remind:
                RemindView(store: store.scope(state: \.remind, action: \.remind))
            }
        }
    }
    
    @ToolbarContentBuilder
    var pokitNavigationBar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text("Pokit")
                .font(.system(size: 36, weight: .heavy))
                .foregroundStyle(.pokit(.text(.brand)))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 12) {
                PokitToolbarButton(
                    .icon(.search),
                    action: { store.send(.pokit(.view(.searchButtonTapped))) }
                )
                PokitToolbarButton(
                    .icon(.bell),
                    action: { store.send(.pokit(.view(.alertButtonTapped))) }
                )
                PokitToolbarButton(
                    .icon(.setup),
                    action: { store.send(.pokit(.view(.settingButtonTapped))) }
                )
            }
        }
    }
    
    @ToolbarContentBuilder
    var remindNavigationBar: some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarLeading) {
            Text("Remind")
                .font(.system(size: 32, weight: .heavy))
                .foregroundStyle(.pokit(.text(.brand)))
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            PokitToolbarButton(
                .icon(.search),
                action: { store.send(.remind(.view(.searchButtonTapped))) }
            )
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            PokitToolbarButton(
                .icon(.bell),
                action: { store.send(.remind(.view(.bellButtonTapped))) }
            )
        }
        
    }
    
    @ToolbarContentBuilder
    var navigationBar: some ToolbarContent {
        switch store.selectedTab {
        case .pokit:  pokitNavigationBar
        case .remind: remindNavigationBar
        }
    }
    
    var bottomTabBar: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                let isSelected: Bool = store.selectedTab == tab
                
                VStack(spacing: 4) {
                    Image(tab.icon)
                        .foregroundStyle(
                            isSelected
                            ? .pokit(.icon(.primary))
                            : .pokit(.icon(.tertiary))
                        )
                    Text(tab.title)
                        .foregroundStyle(
                            isSelected
                            ? .pokit(.text(.primary))
                            : .pokit(.text(.tertiary))
                        )
                        .pokitFont(.detail2)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    store.send(.binding(.set(\.selectedTab, tab)))
                }
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 36)
        .background {
            Rectangle()
                .roundedCorner(20, corners: [.topLeft, .topRight])
                .foregroundStyle(.pokit(.bg(.base)))
                .pokitShadow(
                    x: 0,
                    y: -2,
                    blur: 20,
                    spread: 0,
                    color: Color.black,
                    colorPercent: 10
                )
        }
        .overlay(alignment: .top) {
            Button(action: { send(.addButtonTapped) }) {
                Circle()
                    .foregroundStyle(.pokit(.bg(.brand)))
                    .overlay {
                        Image(.icon(.plus))
                            .resizable()
                            .frame(width: 36, height: 36)
                            .padding(11)
                            .foregroundStyle(.pokit(.icon(.inverseWh)))
                    }
                    .frame(width: 60, height: 60)
                    .offset(y: -30)
            }
        }
        .animation(.spring, value: store.selectedTab)
    }
}
//MARK: - Preview
#Preview {
    MainTabView(
        store: Store(
            initialState: .init(),
            reducer: { MainTabFeature() }
        )
    )
}
//MARK: -  포킷, 리마인드 추가되면 지우기
public struct TestView1: View {
    public var body: some View {
        ZStack {
            Color.red
            HStack {
                Text("Pokit View")
                    .font(.largeTitle)
            }
        }
    }
}

public struct TestView2: View {
    public var body: some View {
        ZStack {
            Color.blue
            HStack {
                Text("Remind View")
                    .font(.largeTitle)
            }
        }
    }
}
