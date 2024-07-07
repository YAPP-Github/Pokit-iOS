//
//  LoginView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI
import DSKit
import AuthenticationServices

public struct LoginView: View {
    @Environment(\.colorScheme) private var colorScheme
    /// - Properties
    private let store: StoreOf<LoginFeature>
    /// - Initializer
    public init(store: StoreOf<LoginFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension LoginView {
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            
            logo
            
            Spacer()
            
            appleLoginButton
            
            googleLoginButton
        }
        .padding(.horizontal, 20)
        .background(.pokit(.bg(.base)))
    }
    
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
                
                Text("Apple로 시작하기")
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
                
                Text("Google로 시작하기")
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
//MARK: - Configure View
extension LoginView {
    
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


