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
import FeatureContentDetail
import FeatureContentSetting
import FeatureCategoryDetail
import FeatureContentList

@ViewAction(for: MainTabFeature.self)
public struct MainTabView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<MainTabFeature>
    /// - Initializer
    public init(store: StoreOf<MainTabFeature>) {
        self.store = store
        UITabBar.appearance().isHidden = true
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithTransparentBackground()
        barAppearance.backgroundColor = UIColor(.pokit(.bg(.base)))
        barAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(.pokit(.text(.primary))),
            .font: DSKitFontFamily.Pretendard.medium.font(size: 18)
        ]
        barAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(.pokit(.text(.primary))),
            .font: DSKitFontFamily.Pretendard.medium.font(size: 18)
        ]
        
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        UINavigationBar.appearance().compactAppearance = barAppearance
    }
}
//MARK: - View
public extension MainTabView {
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                content
            } destination: { store in
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
                    }
                    
                    if self.store.isLinkSheetPresented {
                        PokitLinkPopup(
                            "복사한 링크 저장하기",
                            isPresented: $store.isLinkSheetPresented,
                            type: .link(url: self.store.link ?? ""),
                            action: { send(.linkCopyButtonTapped) }
                        )
                    }
                }
            }
        }
    }
}
//MARK: - Configure View
private extension MainTabView {
    var content: some View {
        tabView
            .overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    if store.isLinkSheetPresented {
                        PokitLinkPopup(
                            "복사한 링크 저장하기",
                            isPresented: $store.isLinkSheetPresented,
                            type: .link(url: store.link ?? ""),
                            action: { send(.linkCopyButtonTapped) }
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
            .pokitNavigationBar(title: "")
            .toolbar { navigationBar }
            .task { await send(.onAppear).finish() }
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
            Image(.logo(.pokit))
                .resizable()
                .frame(width: 104, height: 32)
                .foregroundStyle(.pokit(.icon(.brand)))
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
                        .renderingMode(.template)
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
        .padding(.top, 30)
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
            }
        }
        .animation(.spring, value: store.selectedTab)
    }
    struct AddSheet: View {
        @State private var height: CGFloat = 0
        var action: (TabAddSheetType) -> Void

        var body: some View {
            HStack(spacing: 20) {
                ForEach(TabAddSheetType.allCases, id: \.self) { type in
                    Button(action: { action(type) }) {
                        VStack(spacing: 4) {
                            type.icon
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.pokit(.text(.inverseWh)))
                                .padding(3.2)
                                .padding(.horizontal, 8)
                            Text(type.title)
                                .pokitFont(.b3(.m))
                                .foregroundStyle(.pokit(.text(.inverseWh)))
                        }
                        .padding(.vertical, 21)
                        .padding(.horizontal, 24)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.pokit(.bg(.brand)))
                        }
                    }
                }
            }
            .padding(.top)
            .padding(.top, 24)
            .padding(.bottom, 12)
            .background(.white)
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
