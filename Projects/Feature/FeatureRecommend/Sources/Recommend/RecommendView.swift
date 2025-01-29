//
//  RecommendView.swift
//  Feature
//
//  Created by 김도형 on 1/29/25.

import SwiftUI

import ComposableArchitecture
import Domain
import DSKit
import NukeUI

@ViewAction(for: RecommendFeature.self)
public struct RecommendView: View {
    /// - Properties
    public let store: StoreOf<RecommendFeature>
    
    /// - Initializer
    public init(store: StoreOf<RecommendFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension RecommendView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 16) {
                list
            }
            .padding(.top, 12)
            .ignoresSafeArea(edges: .bottom)
            .task { await send(.onAppear).finish() }
        }
    }
}
//MARK: - Configure View
private extension RecommendView {
    @ViewBuilder
    var list: some View {
        if let recommendedList = store.recommendedList {
            if recommendedList.isEmpty {
                empty
            } else {
                listContent(recommendedList)
            }
        } else {
            PokitLoading()
        }
    }
    
    @ViewBuilder
    var empty: some View {
        PokitCaution(type: .링크없음)
            .padding(.top, 100)
        
        Spacer()
    }
    
    @ViewBuilder
    func listContent(
        _ recommendedList: IdentifiedArrayOf<BaseContentItem>
    ) -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(recommendedList) { content in
                    recomendedCard(content)
                }
                
                if store.hasNext {
                    PokitLoading()
                        .task { await send(.pagination).finish() }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
    }
    

    @ViewBuilder
    func recomendedCard(_ content: BaseContentItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let url = URL(string: content.data) {
                recommendedImage(url: url)
            }
            
            recommededTitle(content)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.pokit(.bg(.base)))
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .inset(by: 0.5)
                .stroke(.pokit(.border(.tertiary)), lineWidth: 1)
        )
        .clipped()
        .overlay(alignment: .topTrailing) {
            recommendedCardButton(content)
                .padding(12)
        }
    }
    
    @ViewBuilder
    func recommendedCardButton(_ content: BaseContentItem) -> some View {
        HStack(spacing: 6) {
            PokitIconButton(
                .icon(.plusR),
                state: .opacity,
                size: .small,
                shape: .round,
                action: { send(.추가하기_버튼_눌렀을때(content)) }
            )
            
            PokitIconButton(
                .icon(.share),
                state: .opacity,
                size: .small,
                shape: .round,
                action: { send(.공유하기_버튼_눌렀을때(content)) }
            )
            
            PokitIconButton(
                .icon(.report),
                state: .opacity,
                size: .small,
                shape: .round,
                action: { send(.신고하기_버튼_눌렀을때(content)) }
            )
        }
    }
    
    @ViewBuilder
    func recommededTitle(_ content: BaseContentItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                if let keyword = content.keyword {
                    PokitBadge(state: .default(keyword))
                }
                
                PokitBadge(state: .default(content.domain))
            }
            
            Text(content.title)
                .foregroundStyle(.pokit(.text(.primary)))
                .pokitFont(.b3(.b))
                .lineLimit(2)
        }
    }
    
    @MainActor
    @ViewBuilder
    func recommendedImage(url: URL) -> some View {
        LazyImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if phase.error != nil {
                imagePlaceholder
            } else {
                imagePlaceholder
            }
        }
        .frame(height: 141)
    }
    
    var imagePlaceholder: some View {
        ZStack {
            Color.pokit(.bg(.disable))
            
            PokitSpinner()
                .foregroundStyle(.pink)
                .frame(width: 48, height: 48)
        }
    }
}
//MARK: - Preview
#Preview {
    RecommendView(
        store: Store(
            initialState: .init(),
            reducer: { RecommendFeature() }
        )
    )
}


