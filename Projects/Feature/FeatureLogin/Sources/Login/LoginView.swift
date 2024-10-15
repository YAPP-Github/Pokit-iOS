//
//  SignUpNavigationStackView.swift
//  Feature
//
//  Created by 김도형 on 7/7/24.

import ComposableArchitecture
import SwiftUI

import DSKit

@ViewAction(for: LoginFeature.self)
public struct LoginView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<LoginFeature>
    /// - Initializer
    public init(store: StoreOf<LoginFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension LoginView {
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                WithPerceptionTracking {
                    VStack(spacing: 8) {
                        logo
                        
                        Spacer()
                        
                        appleLoginButton
                            .pokitMaxWidth()
                        
                        googleLoginButton
                            .pokitMaxWidth()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                    .background(.pokit(.bg(.base)))
                    .ignoresSafeArea(edges: .bottom)
                    .navigationBarBackButtonHidden()
                }
            } destination: { path in
                WithPerceptionTracking {
                    switch path.case {
                    case .agreeToTerms(let store):
                        AgreeToTermsView(store: store)
                    case .registerNickname(let store):
                        RegisterNicknameView(store: store)
                    case .selecteField(let store):
                        SelectFieldView(store: store)
                    }
                }
            }
        }
    }
}
//MARK: - Configure View
extension LoginView {
    private var logo: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 24) {
                Image(.logo(.pokit))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 72)
                    .foregroundStyle(.pokit(.icon(.brand)))
                
                Text("다양한 링크들을 한 곳에")
                    .pokitFont(.b1(.b))
                    .foregroundStyle(.pokit(.text(.secondary)))
            }
            
            Spacer()
        }
        .padding(.top, 254)
    }
    
    private var appleLoginButton: some View {
        Button {
            send(.애플로그인_버튼_눌렀을때)
        } label: {
            appleLoginButtonLabel
        }
    }
    
    private var appleLoginButtonLabel: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Spacer()
                
                Image(systemName: "apple.logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.pokit(.icon(.inverseWh)))
                
                Text("Apple로 계속하기")
                    .pokitFont(.l1(.r))
                    .foregroundStyle(.pokit(.text(.inverseWh)))
                
                Spacer()
            }
            
            Spacer()
        }
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.black)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.pokit(.border(.secondary)), lineWidth: 1)
                }
        }
        .frame(height: 50)
    }
    
    private var googleLoginButton: some View {
        Button {
            send(.구글로그인_버튼_눌렀을때)
        } label: {
            googleLoginButtonLabel
        }
    }
    
    private var googleLoginButtonLabel: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Spacer()
                
                Image(.icon(.google))
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text("Google로 계속하기")
                    .pokitFont(.l1(.r))
                    .foregroundStyle(.pokit(.text(.primary)))
                
                Spacer()
            }
            
            Spacer()
        }
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.pokit(.bg(.base)))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.pokit(.border(.secondary)), lineWidth: 1)
                }
        }
        .frame(height: 50)
    }
}
//MARK: - Preview
#Preview {
    LoginView(
        store: Store(
            initialState: .init(),
            reducer: { LoginFeature() }
        )
    )
}
