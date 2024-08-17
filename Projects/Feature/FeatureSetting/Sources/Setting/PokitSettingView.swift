//
//  PokitSettingView.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import SwiftUI

import ComposableArchitecture
import DSKit

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
                section1
                section2
                section3
                Spacer()
            }
            .padding(.top, 16)
            .pokitNavigationBar { navigationBar }
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $store.isLogoutPresented) {
                PokitAlert(
                    "로그아웃 하시겠습니까?",
                    confirmText: "로그아웃",
                    action: { send(.로그아웃수행) }
                )
            }
            .sheet(isPresented: $store.isWithdrawPresented) {
                PokitAlert(
                    "회원 탈퇴하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며,\n복구하실 수 없습니다.",
                    confirmText: "탈퇴하기",
                    action: { send(.회원탈퇴수행) }
                )
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.nickNameSettingState,
                    action: \.nickNameSettingAction
                )
            ) { store in
                NickNameSettingView(store: store)
            }
            .onAppear { send(.onAppear) }
        }
    }
}
//MARK: - Configure View
private extension PokitSettingView {
    @ViewBuilder
    var section1: some View {
        Section {
            SettingItem(
                title: "닉네임 설정",
                action: { send(.닉네임설정) }
            )
            
            SettingItem(
                title: "알림 설정",
                action: { send(.알림설정) }
            )
        }
        PokitDivider()
            .padding(.vertical, 16)
    }
    
    @ViewBuilder
    var section2: some View {
        Section {
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
    
    var section3: some View {
        Section {
            SettingItem(
                title: "로그아웃",
                action: { send(.로그아웃) }
            )
            
            SettingItem(
                title: "회원 탈퇴",
                action: { send(.회원탈퇴) }
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
            .buttonStyle(.plain)
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


