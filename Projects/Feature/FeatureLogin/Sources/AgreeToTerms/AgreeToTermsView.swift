//
//  AgreeToTermsView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI

import DSKit

@ViewAction(for: AgreeToTermsFeature.self)
public struct AgreeToTermsView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<AgreeToTermsFeature>
    /// - Initializer
    public init(store: StoreOf<AgreeToTermsFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension AgreeToTermsView {
    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading) {
                Group {
                    title
                        .padding(.top, 16)
                    
                    agreeAllTerms
                        .padding(.top, 28)
                    
                    termsList
                        .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                PokitBottomButton(
                    "다음",
                    state: store.isPersonalAndUsageArgee && store.isServiceAgree ? .filled(.primary) : .disable
                ) {
                    send(.nextButtonTapped)
                }
            }
            .background(.pokit(.bg(.base)))
            .pokitNavigationBar(title: "")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    PokitToolbarButton(.icon(.arrowLeft)) {
                        send(.backButtonTapped)
                    }
                }
            }
        }
    }
}
//MARK: - Configure View
extension AgreeToTermsView {
    private var title: some View {
        Text("서비스 이용을 위해\n이용약관 동의가 필요합니다")
            .pokitFont(.title1)
            .foregroundStyle(.pokit(.text(.primary)))
    }
    
    private var agreeAllTerms: some View {
        HStack(spacing: 16) {
            PokitCheckBox(
                baseState: .default,
                selectedState: .filled,
                isSelected: $store.isAgreeAllTerms,
                shape: .rectangle
            )
            
            Text("약관 전체동의")
                .pokitFont(.b1(.b))
                .foregroundStyle(.pokit(.text(.primary)))
            
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.pokit(.border(.brand)), lineWidth: 1)
        }
    }
    
    private var termsList: some View {
        VStack(spacing: 12) {
            termsButton(
                "(필수)개인정보 수집 및 이용 동의",
                isSelected: $store.isPersonalAndUsageArgee
            ) {
                
            }
            
            termsButton(
                "(필수)서비스 이용약관",
                isSelected: $store.isServiceAgree
            ) {
                
            }
            
            termsButton(
                "(선택)마케팅 정보 수신",
                isSelected: $store.isMarketingAgree
            ) {
                
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 12)
    }
    
    @ViewBuilder
    private func termsButton(
        _ text: String,
        isSelected: Binding<Bool>,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 4) {
            PokitCheckBox(
                baseState: .iconOnlyDefault,
                selectedState: .iconOnly,
                isSelected: isSelected,
                shape: .rectangle
            )
            
            Button {
                action()
            } label: {
                Text(text)
                    .pokitFont(.b2(.m))
                    .foregroundStyle(.pokit(.text(.secondary)))
                
                Spacer()
                
                Image(.icon(.arrowRight))
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.pokit(.icon(.primary)))
            }
        }
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        AgreeToTermsView(
            store: Store(
                initialState: .init(),
                reducer: { AgreeToTermsFeature() }
            )
        )
    }
}


