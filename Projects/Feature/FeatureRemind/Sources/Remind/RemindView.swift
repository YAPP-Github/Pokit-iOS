//
//  RemindView.swift
//  Feature
//
//  Created by 김도형 on 7/12/24.

import SwiftUI

import ComposableArchitecture
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
                    recommededLinkList
                    
                    Group {
                        unreadLinkList
                        
                        favoriteLinkList
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 16)
            }
            .background(.pokit(.bg(.base)))
            .pokitNavigationBar(title: "")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    logo
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    PokitToolbarButton(.icon(.search)) {
                        
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    PokitToolbarButton(.icon(.bell)) {
                        
                    }
                }
            }
            .sheet(item: $store.bottomSheetItem) { link in
                PokitBottomSheet(
                    items: [.share, .edit, .delete],
                    height: 224
                ) { send(.bottomSheetButtonTapped(delegate: $0, link: link)) }
            }
            .sheet(item: $store.alertItem) { link in
                PokitAlert(
                    "링크를 정말 삭제하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며, \n복구하실 수 없습니다.",
                    confirmText: "삭제"
                ) { send(.deleteAlertConfirmTapped(link: link)) }
            }
        }
    }
}
//MARK: - Configure View
extension RemindView {
    private var logo: some View {
        Text("Remind")
            .font(.system(size: 32, weight: .heavy))
            .foregroundStyle(.pokit(.text(.brand)))
    }
    
    private var recommededLinkList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘 이 링크는 어때요?")
                .pokitFont(.title2)
                .foregroundStyle(.pokit(.text(.primary)))
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.recommendedLinks) { link in
                        recommendedLinkCell(link: link)
                        
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    @ViewBuilder
    private func recommendedLinkCell(link: LinkMock) -> some View {
        Button(action: {}) {
            recommendedLinkCellLabel(link: link)
        }
        
    }
    
    @ViewBuilder
    private func recommendedLinkCellLabel(link: LinkMock) -> some View {
        let date = formatter.string(from: link.createAt)
        
        ZStack(alignment: .bottom) {
            AsyncImage(url: .init(string: link.thumbNail)) { image in
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
                PokitBadge(link.categoryType, state: .small)
                
                HStack(spacing: 4) {
                    Text(link.title)
                        .pokitFont(.b2(.b))
                        .foregroundStyle(.pokit(.text(.inverseWh)))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    kebabButton {
                        send(.kebabButtonTapped(link: link))
                    }
                    .foregroundStyle(.pokit(.icon(.inverseWh)))
                    .zIndex(1)
                    
                }
                .padding(.top, 4)
                
                Text("\(date) • \(link.domain)")
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
    
    private var unreadLinkList: some View {
        VStack(spacing: 0) {
            listNavigationLink("한번도 읽지 않았어요") {
                
            }
            .padding(.bottom, 16)
            
            ForEach(store.unreadLinks) { link in
                let isFirst = link == store.unreadLinks.first
                let isLast = link == store.unreadLinks.last
                
                PokitLinkCard(
                    link: link,
                    action: { },
                    kebabAction: { send(.kebabButtonTapped(link: link)) }
                )
                .divider(isFirst: isFirst, isLast: isLast)
            }
        }
    }
    
    private var favoriteLinkList: some View {
        VStack(spacing: 0) {
            listNavigationLink("즐겨찾기 링크만 모았어요") {
                
            }
            .padding(.bottom, 16)
            
            ForEach(store.favoriteLinks) { link in
                let isFirst = link == store.favoriteLinks.first
                let isLast = link == store.favoriteLinks.last
                
                PokitLinkCard(
                    link: link,
                    action: {},
                    kebabAction: {}
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


