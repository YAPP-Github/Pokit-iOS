//
//  MainTabView.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import SwiftUI

import ComposableArchitecture
import DSKit
import FeaturePokit
import FeatureRecommend
import FeatureSetting
import FeatureCategorySetting
import FeatureContentDetail
import FeatureContentSetting
import FeatureCategoryDetail
import FeatureContentList
import FeatureCategorySharing

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
                WithPerceptionTracking {
                    ZStack(alignment: .bottom) {
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
                                ContentSettingView(store: store)
                            }
                        case .카테고리상세:
                            if let store = store.scope(state: \.카테고리상세, action: \.카테고리상세) {
                                CategoryDetailView(store: store)
                            }
                        case .링크목록:
                            if let store = store.scope(state: \.링크목록, action: \.링크목록) {
                                ContentListView(store: store)
                            }
                        case .링크공유:
                            if let store = store.scope(state: \.링크공유, action: \.링크공유) {
                                CategorySharingView(store: store)
                            }
                        }
                        
                        if self.store.linkPopup != nil {
                            PokitLinkPopup(
                                type: $store.linkPopup,
                                action: { send(.링크팝업_버튼_눌렀을때, animation: .pokitSpring) }
                            )
                        }
                    }
                }
            }
            .onOpenURL { send(.onOpenURL(url: $0)) }
        }
    }
}
//MARK: - Configure View
private extension MainTabView {
    var content: some View {
        tabView
            .overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    if store.linkPopup != nil {
                        PokitLinkPopup(
                            type: $store.linkPopup,
                            action: { send(.링크팝업_버튼_눌렀을때, animation: .pokitSpring) }
                        )
                        .padding(.bottom, 20)
                    }
                    
                    bottomTabBar
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $store.isBottomSheetPresented) {
                ///Todo: bottom sheet 추가
                AddSheet(action: { send(.addSheetTypeSelected($0)) })
            }
            .sheet(
                item: $store.scope(
                    state: \.contentDetail,
                    action: \.contentDetail
                )
            ) { store in
                ContentDetailView(store: store)
            }
            .sheet(isPresented: $store.isErrorSheetPresented) {
                PokitAlert(
                    store.error?.title ?? "에러",
                    message: store.error?.message ?? "메세지",
                    confirmText: "확인",
                    action: { send(.경고_확인버튼_클릭) }
                )
            }
            .task { await send(.onAppear).finish() }
    }
    
    var tabView: some View {
        TabView(selection: $store.selectedTab) {
            switch store.selectedTab {
            case .pokit:
                PokitRootView(store: store.scope(state: \.pokit, action: \.pokit))
                    .pokitNavigationBar { pokitNavigationBar }
                    .toolbarBackground(.hidden, for: .tabBar)
                
            case .recommend:
                RecommendView(store: store.scope(state: \.recommend, action: \.recommend))
                    .pokitNavigationBar { remindNavigationBar }
                    .toolbarBackground(.hidden, for: .tabBar)
            }
        }
    }
    
    var pokitNavigationBar: some View {
        PokitHeader {
            PokitHeaderItems(placement: .leading) {
                Image(.logo(.pokit))
                    .resizable()
                    .frame(width: 104, height: 32)
                    .foregroundStyle(.pokit(.icon(.brand)))
            }
            
            PokitHeaderItems(placement: .trailing) {
                PokitToolbarButton(
                    .icon(.search),
                    action: { store.send(.pokit(.view(.검색_버튼_눌렀을때))) }
                )
                PokitToolbarButton(
                    .icon(.bell),
                    action: { store.send(.pokit(.view(.알람_버튼_눌렀을때))) }
                )
                PokitToolbarButton(
                    .icon(.setup),
                    action: { store.send(.pokit(.view(.설정_버튼_눌렀을때))) }
                )
            }
        }
        .padding(.vertical, 8)
    }
    
    var remindNavigationBar: some View {
        PokitHeader {
            PokitHeaderItems(placement: .leading) {
                Text("링크추천")
                    .pokitFont(.title2)
                    .foregroundStyle(.pokit(.text(.primary)))
            }
            
            PokitHeaderItems(placement: .trailing) {
                PokitToolbarButton(
                    .icon(.search),
                    action: { send(.검색_버튼_눌렀을때) }
                )
                PokitToolbarButton(
                    .icon(.bell),
                    action: { send(.알림_버튼_눌렀을때) }
                )
            }
        }
        .padding(.vertical, 8)
    }
    
    var bottomTabBar: some View {
        HStack(alignment: .bottom, spacing: 0) {
            bottomTabBarItem(.pokit)
            
            Spacer()
            
            bottomTabBarItem(.recommend)
        }
        .padding(.horizontal, 48)
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
        .padding(.top, 30)
        .overlay(alignment: .top) {
            Button(action: { send(.addButtonTapped) }) {
                Image(.icon(.plus))
                    .resizable()
                    .frame(width: 36, height: 36)
                    .padding(12)
                    .foregroundStyle(.pokit(.icon(.inverseWh)))
                    .background {
                        RoundedRectangle(cornerRadius: 9999, style: .continuous)
                            .fill(.pokit(.bg(.brand)))
                    }
                    .frame(width: 60, height: 60)
            }
        }
        .pokitMaxWidth()
        .animation(.pokitDissolve, value: store.selectedTab)
    }
    
    @ViewBuilder
    func bottomTabBarItem(_ tab: MainTab) -> some View {
        let isSelected: Bool = store.selectedTab == tab
        
        VStack(spacing: 4) {
            Image(tab.icon)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
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
        .padding(.horizontal, 28)
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light)
                .impactOccurred()
            store.send(.binding(.set(\.selectedTab, tab)))
        }
    }
    
    struct AddSheet: View {
        @State private var height: CGFloat = 0
        var action: (TabAddSheetType) -> Void
        
        var body: some View {
            GeometryReader { proxy in
                let bottomSafeArea = proxy.safeAreaInsets.bottom
                HStack(spacing: 20) {
                    Spacer()
                    
                    ForEach(TabAddSheetType.allCases, id: \.self) { type in
                        Button(action: { action(type) }) {
                            VStack(spacing: 4) {
                                Spacer()
                                
                                type.icon
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28)
                                    .foregroundStyle(.pokit(.icon(.inverseWh)))
                                
                                Text(type.title)
                                    .pokitFont(.b3(.m))
                                    .foregroundStyle(.pokit(.text(.inverseWh)))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .background {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .foregroundStyle(.pokit(.bg(.brand)))
                            }
                            .frame(height: 96)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 48 - bottomSafeArea)
                .padding(.top, 36)
                .pokitPresentationCornerRadius()
                .pokitPresentationBackground()
                .presentationDragIndicator(.visible)
                .readHeight()
                .onPreferenceChange(HeightPreferenceKey.self) { height in
                    if let height {
                        self.height = height
                    }
                }
                .presentationDetents([.height(self.height)])
            }
        }
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
