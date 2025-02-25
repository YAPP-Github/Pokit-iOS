//
//  PokitSettingView.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import SwiftUI

import ComposableArchitecture
import DSKit
import NukeUI

@ViewAction(for: PokitSettingFeature.self)
public struct PokitSettingView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<PokitSettingFeature>
    
    /// - Initializer
    public init(store: StoreOf<PokitSettingFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitSettingView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                profileSection
                menuSection
                accountSection
                Spacer()
            }
            .padding(.top, 16)
            .pokitNavigationBar { navigationBar }
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $store.isLogoutPresented) {
                PokitAlert(
                    "로그아웃 하시겠습니까?",
                    confirmText: "로그아웃",
                    action: { send(.로그아웃_팝업_확인_눌렀을때) }
                )
            }
            .sheet(isPresented: $store.isWithdrawPresented) {
                PokitAlert(
                    "회원 탈퇴하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며,\n복구하실 수 없습니다.",
                    confirmText: "탈퇴하기",
                    action: { send(.회원탈퇴_팝업_확인_눌렀을때) }
                )
            }
            .fullScreenCover(isPresented: $store.isWebViewPresented) {
                PokitWebView(url: $store.webViewURL)
                    .ignoresSafeArea()
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.nickNameSettingState,
                    action: \.nickNameSettingAction
                )
            ) { store in
                NickNameSettingView(store: store)
            }
            .task { await send(.onAppear).finish() }
        }
    }
}
//MARK: - Configure View
private extension PokitSettingView {
    @ViewBuilder
    var profileSection: some View {
        HStack(spacing: 12) {
            LazyImage(url: URL(string: store.user?.profile?.imageURL ?? "")) { state in
                Group {
                    if let image = state.image {
                        image
                            .resizable()
                            .clipShape(.circle)
                    } else if state.isLoading {
                        PokitSpinner()
                            .foregroundStyle(.pokit(.icon(.brand)))
                    } else {
                        Image(.image(.profile))
                            .resizable()
                    }

                }
                .animation(.pokitDissolve, value: state.image)
            }
            .frame(width: 40, height: 40)
            Text(store.user?.nickname ?? "")
                .pokitFont(.b1(.m))
            Spacer()
            PokitTextButton(
                "프로필 편집",
                state: .stroke(.secondary),
                size: .small,
                shape: .rectangle,
                action: { send(.프로필설정) }
            )
        }
        .padding(.top, 16)
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        PokitDivider()
            .padding(.vertical, 16)
    }
    
    @ViewBuilder
    var menuSection: some View {
        Section {
            SettingItem(
                title: "알림 설정",
                action: { send(.알림설정) }
            )
            
            SettingItem(
                title: "공지사항",
                action: { send(.공지사항) }
            )
            
            SettingItem(
                title: "서비스 이용약관",
                action: { send(.서비스_이용약관) }
            )
            
            SettingItem(
                title: "개인정보 처리방침",
                action: { send(.개인정보_처리방침) }
            )
            
            SettingItem(
                title: "고객문의",
                action: { send(.고객문의) }
            )
        }
        PokitDivider()
            .padding(.vertical, 16)
    }
    
    var accountSection: some View {
        Section {
            SettingItem(
                title: "로그아웃",
                action: { send(.로그아웃_버튼_눌렀을때) }
            )
            
            SettingItem(
                title: "회원 탈퇴",
                action: { send(.회원탈퇴_버튼_눌렀을때) }
            )
        }
    }
    
    var navigationBar: some View {
        PokitHeader(title: "설정") {
            PokitHeaderItems(placement: .leading) {
                PokitToolbarButton(.icon(.arrowLeft)) {
                    send(.dismiss)
                }
            }
        }
        .padding(.top, 8)
    }
    
    struct SettingItem: View {
        private let title: String
        private let action: () -> Void
        
        init(title: String, action: @escaping() -> Void) {
            self.title = title
            self.action = action
        }
        
        var body: some View {
            Button(action: { action() }) {
                HStack(spacing: 0) {
                    Text(title)
                        .foregroundStyle(.pokit(.text(.primary)))
                        .pokitFont(.b1(.m))
                    
                    Spacer()
                    
                    Image(.icon(.arrowRight))
                        .resizable()
                        .foregroundStyle(.black)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        PokitSettingView(
            store: Store(
                initialState: .init(),
                reducer: { PokitSettingFeature() }
            )
        )
    }
}


