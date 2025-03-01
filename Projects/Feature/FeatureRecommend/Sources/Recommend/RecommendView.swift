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
    @Perception.Bindable
    public var store: StoreOf<RecommendFeature>
    
    /// - Initializer
    public init(store: StoreOf<RecommendFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension RecommendView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 10) {
                interestList
                
                list
            }
            .ignoresSafeArea(edges: .bottom)
            .sheet(item: $store.shareContent) { content in
                if let shareURL = URL(string: content.data) {
                    PokitShareSheet(
                        items: [shareURL],
                        completion: { send(.링크_공유_완료되었을때) }
                    )
                    .presentationDetents([.medium, .large])
                }
            }
            .task { await send(.onAppear).finish() }
            .sheet(isPresented: $store.showKeywordSheet) {
                RecommendKeywordBottomSheet(
                    selectedInterests: $store.selectedInterestList,
                    interests: store.interests,
                    action: { send(.키워드_선택_버튼_눌렀을때) }
                )
            }
            .sheet(item: $store.reportContent) { content in
                PokitAlert(
                    "링크를 신고하시겠습니까?",
                    message: "명확한 사유가 있는 경우 신고해주시기 바랍니다. \nex)음란성/선정성 이미지, 영상, 텍스트 등의 콘텐츠\n욕설, 비속어, 모욕, 저속한 단어 등",
                    confirmText: "확인",
                    action: { send(.신고하기_확인_버튼_눌렀을때(content)) },
                    cancelAction: { send(.경고시트_dismiss) }
                )
            }
        }
    }
}
//MARK: - Configure View
private extension RecommendView {
    var interestList: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                interestListContent(proxy)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .padding(.trailing, 40)
            }
            .overlay(alignment: .trailing) {
                interestEditButton
            }
            .padding(.bottom, 4)
        }
    }
    
    var interestEditButton: some View {
        PokitIconButton(
            .icon(.edit),
            state: .default(.secondary),
            size: .small,
            shape: .round,
            action: { send(.관심사_편집_버튼_눌렀을때) }
        )
        .padding([.leading, .vertical], 8)
        .padding(.trailing, 20)
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(
                        color: .pokit(.bg(.base)),
                        location: 0.00
                    ),
                    Gradient.Stop(
                        color: .pokit(.bg(.base)).opacity(0),
                        location: 1.00
                    ),
                ],
                startPoint: UnitPoint(x: 0.1, y: 0.52),
                endPoint: UnitPoint(x: 0, y: 0.52)
            )
        )
    }
    
    @ViewBuilder
    func interestListContent(_ proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 8) {
            let isAllSelected = store.selectedInterest == nil
            
            PokitTextButton(
                "전체보기",
                state: isAllSelected
                ? .filled(.primary)
                : .default(.secondary),
                size: .small,
                shape: .round
            ) {
                send(
                    .전체보기_버튼_눌렀을때(proxy),
                    animation: .pokitDissolve
                )
            }
            .id("전체보기")
            
            ForEach(store.myInterestList) { interest in
                let isSelected = store.selectedInterest == interest
                
                PokitTextButton(
                    interest.description,
                    state: isSelected
                    ? .filled(.primary)
                    : .default(.secondary),
                    size: .small,
                    shape: .round
                ) {
                    send(
                        .관심사_버튼_눌렀을때(interest, proxy),
                        animation: .pokitDissolve
                    )
                }
                .id(interest.description)
            }
        }
        .animation(.pokitDissolve, value: store.myInterestList)
    }
    
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
        PokitCaution(type: .추천_링크없음)
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
                    recommendedCard(content)
                }
                
                if store.hasNext {
                    PokitLoading()
                        .task { await send(.pagination).finish() }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 150)
        }
    }
    
    @ViewBuilder
    func recommendedCard(_ content: BaseContentItem) -> some View {
        Button(action: { send(.추천_컨텐츠_눌렀을때(content.data)) }) {
            recomendedCardLabel(content)
        }
    }

    @ViewBuilder
    func recomendedCardLabel(_ content: BaseContentItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let url = URL(string: content.thumbNail) {
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
                .multilineTextAlignment(.leading)
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


