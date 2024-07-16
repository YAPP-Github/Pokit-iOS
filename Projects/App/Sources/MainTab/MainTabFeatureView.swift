//
//  MainTabView.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import SwiftUI

import ComposableArchitecture
import DSKit

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
            Group { content }
            .sheet(isPresented: $store.isBottomSheetPresented) {
                ///Todo: bottom sheet 추가
                TestView2()
            }
            .ignoresSafeArea(edges: .bottom)
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
    }
    
    var tabView: some View {
        TabView(selection: $store.selectedTab) {
            switch store.selectedTab {
            case .pokit:
//                포킷뷰(store: self.store.scope(state: \.포킷, action: \.포킷))
                TestView1()
            case .remind:
                TestView2()
            }
        }
        .toolbar(.hidden, for: .tabBar)
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
