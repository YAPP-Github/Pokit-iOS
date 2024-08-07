//
//  RemindView.swift
//  Feature
//
//  Created by 김도형 on 7/12/24.

import SwiftUI

import ComposableArchitecture
import Domain
import DSKit
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
            ScrollView {
                VStack(spacing: 32) {
                    recommededContentList
                    
                    Group {
                        unreadContentList
                        
                        favoriteContentList
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 16)
                .padding(.bottom, 150)
            }
            .background(.pokit(.bg(.base)))
            .ignoresSafeArea(edges: .bottom)
            .pokitNavigationBar(title: "")
            .sheet(item: $store.bottomSheetItem) { content in
                PokitBottomSheet(
                    items: [.share, .edit, .delete],
                    height: 224
                ) { send(.bottomSheetButtonTapped(delegate: $0, content: content)) }
            }
            .sheet(item: $store.alertItem) { content in
                PokitAlert(
                    "링크를 정말 삭제하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며, \n복구하실 수 없습니다.",
                    confirmText: "삭제"
                ) { send(.deleteAlertConfirmTapped(content: content)) }
            }
            .onAppear { send(.remindViewOnAppeared) }
        }
    }
}
//MARK: - Configure View
extension RemindView {
    private var recommededContentList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘 이 링크는 어때요?")
                .pokitFont(.title2)
                .foregroundStyle(.pokit(.text(.primary)))
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.recommendedContents) { content in
                        recommendedContentCell(content: content)
                        
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    @ViewBuilder
    private func recommendedContentCell(content: BaseContent) -> some View {
        Button(action: { send(.linkCardTapped(content: content)) }) {
            recommendedContentCellLabel(content: content)
        }
        
    }
    
    @ViewBuilder
    private func recommendedContentCellLabel(content: BaseContent) -> some View {
        let date = formatter.string(from: content.createdAt)
        
        ZStack(alignment: .bottom) {
            AsyncImage(url: .init(string: content.thumbNail)) { image in
                image
                    .resizable()
            } placeholder: {
                Color.pokit(.bg(.disable))
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
                
                Text("\(date) • \(content.domain)")
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
    
    private var unreadContentList: some View {
        VStack(spacing: 0) {
            listNavigationLink("한번도 읽지 않았어요") {
                send(.unreadNavigationLinkTapped)
            }
            .padding(.bottom, 16)
            
            ForEach(store.unreadContents) { content in
                let isFirst = content == store.unreadContents.elements.first
                let isLast = content == store.unreadContents.elements.last
                
                PokitLinkCard(
                    link: content,
                    action: { send(.linkCardTapped(content: content)) },
                    kebabAction: { send(.kebabButtonTapped(content: content)) }
                )
                .divider(isFirst: isFirst, isLast: isLast)
            }
        }
    }
    
    private var favoriteContentList: some View {
        VStack(spacing: 0) {
            listNavigationLink("즐겨찾기 링크만 모았어요") {
                send(.favoriteNavigationLinkTapped)
            }
            .padding(.bottom, 16)
            
            ForEach(store.favoriteContents) { content in
                let isFirst = content == store.favoriteContents.elements.first
                let isLast = content == store.favoriteContents.elements.last
                
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


