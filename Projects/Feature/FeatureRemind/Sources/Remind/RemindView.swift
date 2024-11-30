//
//  RemindView.swift
//  Feature
//
//  Created by 김도형 on 7/12/24.

import SwiftUI

import ComposableArchitecture
import Domain
import DSKit
import NukeUI
import Util

@ViewAction(for: RemindFeature.self)
public struct RemindView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<RemindFeature>
    private let formatter = DateFormat.yearMonthDate.formatter
    /// - Initializer
    public init(store: StoreOf<RemindFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension RemindView {
    var body: some View {
        WithPerceptionTracking {
            contents
                .background(.pokit(.bg(.base)))
                .ignoresSafeArea(edges: .bottom)
                .navigationBarBackButtonHidden(true)
                .task { await send(.뷰가_나타났을때, animation: .pokitDissolve).finish() }
        }
    }
}
//MARK: - Configure View
extension RemindView {
    private var contents: some View {
        Group {
            if let recommendedContents = store.recommendedContents,
               let unreadContents = store.unreadContents,
               let favoriteContents = store.favoriteContents {
                if recommendedContents.isEmpty &&
                   unreadContents.isEmpty &&
                   favoriteContents.isEmpty {
                    VStack {
                        PokitCaution(type: .링크부족)
                        .padding(.top, 100)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 32) {
                            recommededContentList(recommendedContents)
                            
                            Group {
                                unreadContentList(unreadContents)
                                
                                favoriteContentList(favoriteContents)
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer()
                        }
                        .padding(.bottom, 150)
                    }
                }
            } else {
                PokitLoading()
            }
        }
    }
    
    @ViewBuilder
    private func recommededContentList(
        _ recommendedContents: IdentifiedArrayOf<BaseContentItem>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘 이 링크는 어때요?")
                .pokitFont(.title2)
                .foregroundStyle(.pokit(.text(.primary)))
                .padding(.horizontal, 20)
            
            if recommendedContents.isEmpty {
                PokitCaution(type: .링크부족)
                .padding(.top, 24)
                .padding(.bottom, 32)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(recommendedContents, id: \.id) { content in
                            recommendedContentCell(content: content)
                            
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    @ViewBuilder
    private func recommendedContentCell(content: BaseContentItem) -> some View {
        Button(action: { send(.컨텐츠_항목_눌렀을때(content: content)) }) {
            recommendedContentCellLabel(content: content)
        }
    }
    
    @ViewBuilder
    private func recommendedContentCellLabel(content: BaseContentItem) -> some View {
        ZStack(alignment: .bottom) {
            if let url = URL(string: content.thumbNail) {
                recommendedContentCellImage(url: url, contentId: content.id)
            } else {
                imagePlaceholder
            }
            
            LinearGradient(
                stops: [
                    Gradient.Stop(
                        color: .black.opacity(0),
                        location: 0.00
                    ),
                    Gradient.Stop(
                        color: Color(red: 0.02, green: 0.02, blue: 0.02).opacity(0.49),
                        location: 1.00
                    ),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 0) {
                PokitBadge(state: .small(content.categoryName))
                
                HStack(spacing: 4) {
                    Text(content.title)
                        .pokitFont(.b2(.b))
                        .foregroundStyle(.pokit(.text(.inverseWh)))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    kebabButton {
                        send(.컨텐츠_항목_케밥_버튼_눌렀을때(content: content))
                    }
                    .foregroundStyle(.pokit(.icon(.inverseWh)))
                    .zIndex(1)
                    
                }
                .padding(.top, 4)
                
                Text("\(content.createdAt) • \(content.domain)")
                    .pokitFont(.detail2)
                    .foregroundStyle(.pokit(.text(.tertiary)))
                    .padding(.top, 8)
            }
            .padding(12)
        }
        .frame(width: 216, height: 194)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .clipped()
    }
    
    @MainActor
    private func recommendedContentCellImage(url: URL, contentId: Int) -> some View {
        LazyImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if phase.error != nil {
                imagePlaceholder
                    .task { await send(.리마인드_항목_이미지오류_나타났을때(contentId: contentId)).finish() }
            } else {
                imagePlaceholder
            }
        }
    }
    
    private var imagePlaceholder: some View {
        ZStack {
            Color.pokit(.bg(.disable))
            
            PokitSpinner()
                .foregroundStyle(.pink)
                .frame(width: 48, height: 48)
        }
    }
    
    @ViewBuilder
    private func kebabButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(.icon(.kebab))
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
    
    @ViewBuilder
    private func listNavigationLink(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .pokitFont(.title2)
                
                Spacer()
                
                Image(.icon(.arrowRight))
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .foregroundStyle(.pokit(.icon(.primary)))
        }
    }
    
    @ViewBuilder
    private func unreadContentList(
        _ unreadContents: IdentifiedArrayOf<BaseContentItem>
    ) -> some View {
        Group {
            if !unreadContents.isEmpty {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        listNavigationLink("한번도 읽지 않았어요") {
                            send(.안읽음_목록_버튼_눌렀을때)
                        }
                        .padding(.bottom, 16)
                    }
                    
                    ForEach(unreadContents, id: \.id) { content in
                        let isFirst = content.id == unreadContents.first?.id
                        let isLast = content.id == unreadContents.last?.id
                        
                        PokitLinkCard(
                            link: content,
                            state: isFirst
                            ? .top
                            : isLast ? .bottom : .middle,
                            action: { send(.컨텐츠_항목_눌렀을때(content: content)) },
                            kebabAction: { send(.컨텐츠_항목_케밥_버튼_눌렀을때(content: content)) },
                            fetchMetaData: { send(.읽지않음_항목_이미지_조회(contentId: content.id)) }
                        )
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func favoriteContentList(
        _ favoriteContents: IdentifiedArrayOf<BaseContentItem>
    ) -> some View {
        VStack(spacing: 0) {
            listNavigationLink("즐겨찾기 링크만 모았어요") {
                send(.즐겨찾기_목록_버튼_눌렀을때)
            }
            .padding(.bottom, 16)
            
            if favoriteContents.isEmpty {
                PokitCaution(type: .즐겨찾기_링크없음)
                .padding(.top, 16)
            } else {
                ForEach(favoriteContents, id: \.id) { content in
                    let isFirst = content.id == favoriteContents.first?.id
                    let isLast = content.id == favoriteContents.last?.id
                    
                    PokitLinkCard(
                        link: content,
                        state: isFirst
                        ? .top
                        : isLast ? .bottom : .middle,
                        action: { send(.컨텐츠_항목_눌렀을때(content: content)) },
                        kebabAction: { send(.컨텐츠_항목_케밥_버튼_눌렀을때(content: content)) },
                        fetchMetaData: { send(.즐겨찾기_항목_이미지_조회(contentId: content.id)) }
                    )
                }
            }
        }
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        RemindView(
            store: Store(
                initialState: .init(),
                reducer: { RemindFeature() }
            )
        )
    }
}


