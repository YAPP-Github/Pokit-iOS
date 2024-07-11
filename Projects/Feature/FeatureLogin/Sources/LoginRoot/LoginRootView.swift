//
//  SignUpNavigationStackView.swift
//  Feature
//
//  Created by 김도형 on 7/7/24.

import ComposableArchitecture
import SwiftUI

import DSKit

public struct LoginRootView: View {
    /// - Properties
    @Perception.Bindable
    private var store: StoreOf<LoginRootFeature>
    /// - Initializer
    public init(store: StoreOf<LoginRootFeature>) {
        self.store = store
        
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
public extension LoginRootView {
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                WithPerceptionTracking {
                    VStack(spacing: 8) {
                        Spacer()
                        
                        logo
                        
                        Spacer()
                        
                        appleLoginButton
                        
                        googleLoginButton
                    }
                    .padding(.horizontal, 20)
                    .background(.pokit(.bg(.base)))
                    .pokitNavigationBar(title: "")
                }
            } destination: { path in
                switch path.case {
                case .agreeToTerms(let store):
                    AgreeToTermsView(store: store)
                case .registerNickname(let store):
                    RegisterNicknameView(store: store)
                case .selecteField(let store):
                    SelectFieldView(store: store)
                case .signUpDone(let store):
                    SignUpDoneView(store: store)
                }
            }
        }
    }
}
//MARK: - Configure View
extension LoginRootView {
    private var logo: some View {
        Text("Pokit")
            .pokitFont(.title1)
            .foregroundStyle(.pokit(.text(.brand)))
            .frame(height: 171)
    }
    
    private var appleLoginButton: some View {
        Button {
            store.send(.appleLoginButtonTapped)
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
    LoginRootView(
        store: Store(
            initialState: .init(),
            reducer: { LoginRootFeature() }
        )
    )
}
