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
    private let formatter = DateFormatter()
    /// - Initializer
    public init(store: StoreOf<RemindFeature>) {
        self.store = store
        formatter.dateFormat = "yyyy.MM.dd"
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
                .sheet(item: $store.bottomSheetItem) { content in
                    PokitBottomSheet(
                        items: [.share, .edit, .delete],
                        height: 224
                    ) { send(.bottomSheetButtonTapped(delegate: $0, content: content)) }
                }
                .sheet(item: $store.shareSheetItem) { content in
                    if let shareURL = URL(string: content.data) {
                        PokitShareSheet(
                            items: [shareURL],
                            completion: { send(.링크_공유_완료(completed: $0)) }
                        )
                        .presentationDetents([.medium, .large])
                    }
                }
                .sheet(item: $store.alertItem) { content in
                    PokitAlert(
                        "링크를 정말 삭제하시겠습니까?",
                        message: "함께 저장한 모든 정보가 삭제되며, \n복구하실 수 없습니다.",
                        confirmText: "삭제"
                    ) { send(.deleteAlertConfirmTapped(content: content)) }
                }
                .task { await send(.remindViewOnAppeared, animation: .pokitDissolve).finish() }
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
                        PokitCaution(
                            image: .sad,
                            titleKey: "링크가 부족해요!",
                            message: "링크를 5개 이상 저장하고 추천을 받아보세요"
                        )
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
                PokitCaution(
                    image: .sad,
                    titleKey: "링크가 부족해요!",
                    message: "링크를 5개 이상 저장하고 추천을 받아보세요"
                )
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
        Button(action: { send(.linkCardTapped(content: content)) }) {
            recommendedContentCellLabel(content: content)
        }
        
    }
    
    @ViewBuilder
    private func recommendedContentCellLabel(content: BaseContentItem) -> some View {
        ZStack(alignment: .bottom) {
            LazyImage(url: .init(string: content.thumbNail)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                } else {
                    ZStack {
                        Color.pokit(.bg(.disable))
                        
                        PokitSpinner()
                            .foregroundStyle(.pokit(.icon(.brand)))
                            .frame(width: 48, height: 48)
                    }
                }
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
                PokitBadge(content.categoryName, state: .small)
                
                HStack(spacing: 4) {
                    Text(content.title)
                        .pokitFont(.b2(.b))
                        .foregroundStyle(.pokit(.text(.inverseWh)))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    kebabButton {
                        send(.kebabButtonTapped(content: content))
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
                            send(.unreadNavigationLinkTapped)
                        }
                        .padding(.bottom, 16)
                    }
                    
                    ForEach(unreadContents, id: \.id) { content in
                        let isFirst = content == unreadContents.elements.first
                        let isLast = content == unreadContents.elements.last
                        
                        PokitLinkCard(
                            link: content,
                            action: { send(.linkCardTapped(content: content)) },
                            kebabAction: { send(.kebabButtonTapped(content: content)) }
                        )
                        .divider(isFirst: isFirst, isLast: isLast)
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
                send(.favoriteNavigationLinkTapped)
            }
            .padding(.bottom, 16)
            
            if favoriteContents.isEmpty {
                PokitCaution(
                    image: .empty,
                    titleKey: "즐겨찾기 링크가 없어요!",
                    message: "링크를 즐겨찾기로 관리해보세요"
                )
                .padding(.top, 16)
            } else {
                ForEach(favoriteContents, id: \.id) { content in
                    let isFirst = content == favoriteContents.elements.first
                    let isLast = content == favoriteContents.elements.last
                    
                    PokitLinkCard(
                        link: content,
                        action: { send(.linkCardTapped(content: content)) },
                        kebabAction: { send(.kebabButtonTapped(content: content)) }
                    )
                    .divider(isFirst: isFirst, isLast: isLast)
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


