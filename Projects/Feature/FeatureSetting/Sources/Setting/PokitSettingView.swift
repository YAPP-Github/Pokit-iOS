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
            .navigationBarBackButtonHidden()
            .pokitNavigationBar(title: "설정")
            .toolbar { navigationBar }
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
                action: { }
            )
            
            SettingItem(
                title: "알림 설정",
                action: { }
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
                action: { }
            )
            
            SettingItem(
                title: "서비스 이용약관",
                action: { }
            )
            
            SettingItem(
                title: "개인정보 처리방침",
                action: { }
            )
            
            SettingItem(
                title: "고객문의",
                action: { }
            )
        }
        PokitDivider()
            .padding(.vertical, 16)
    }
    var section3: some View {
        Section {
            SettingItem(
                title: "로그아웃",
                action: { }
            )
            
            SettingItem(
                title: "회원 탈퇴",
                action: { }
            )
        }
    }
    @ToolbarContentBuilder
    var navigationBar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            PokitToolbarButton(.icon(.arrowLeft)) {
                
            }
        }
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


