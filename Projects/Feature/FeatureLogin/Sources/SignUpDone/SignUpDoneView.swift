//
//  SignUpDoneView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI

import DSKit

@ViewAction(for: SignUpDoneFeature.self)
public struct SignUpDoneView: View {
    /// - Properties
    public var store: StoreOf<SignUpDoneFeature>
    /// - Initializer
    public init(store: StoreOf<SignUpDoneFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SignUpDoneView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Spacer()
                
                    logo
                    
                    title
                        .padding(.top, 4)
                
                Spacer()
                
                images
                    .padding(.top, 78)
            }
            .padding(.horizontal, 20)
            .overlay(alignment: .bottom) {
                PokitBottomButton(
                    "시작하기",
                    state: .filled(.primary),
                    action: { send(.startButtonTapped) }
                )
                .pokitMaxWidth()
                .padding(.horizontal, 20)
                .background(.pokit(.bg(.base)))
            }
            .pokitNavigationBar {
                PokitHeader {
                    PokitHeaderItems(placement: .leading) {
                        PokitToolbarButton(.icon(.arrowLeft)) {
                            send(.backButtonTapped)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
//MARK: - Configure View
extension SignUpDoneView {
    private var logo: some View {
        HStack {
            Spacer()
            
            Image(.image(.firecracker))
                .resizable()
                .frame(width: 90, height: 90)
                .scaleEffect(
                    store.firecrackIsAppear ? 1 : 0,
                    anchor: .bottomTrailing
                )
                .onAppear { send(.firecrackerOnAppeared, animation: .pokitSpring) }
            
            Spacer()
        }
    }
    
    private var title: some View {
        VStack(spacing: 8) {
            Text("회원가입 완료!")
                .pokitFont(.title1)
                .foregroundStyle(.pokit(.text(.brand)))
            
            Text("다양한 링크를 포킷에 저장해보세요")
                .pokitFont(.b1(.b))
                .foregroundStyle(.pokit(.text(.secondary)))
                .multilineTextAlignment(.center)
        }
        .opacity(store.titleIsAppear ? 1 : 0)
        .onAppear { send(.titleOnAppeared, animation: .pokitDissolve) }
    }
    
    private var images: some View {
        ZStack(alignment: .bottom) {
            Image(.image(.confetti))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 308, height: 345)
                .padding(.bottom, 74)
                .scaleEffect(
                    store.confettiIsAppear ? 1 : 0,
                    anchor: .bottom
                )
                .onAppear { send(.confettiOnAppeared, animation: .pokitSpring) }
            
            Image(.character(.pooki))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 308, height: 345)
                .scaleEffect(
                    store.pookiIsAppear ? 1 : 0,
                    anchor: .bottom
                )
                .onAppear{ send(.pookiOnAppeared, animation: .pokitSpring) }
        }
    }
}
//MARK: - Preview
#Preview {
    SignUpDoneView(
        store: Store(
            initialState: .init(),
            reducer: { SignUpDoneFeature() }
        )
    )
}


