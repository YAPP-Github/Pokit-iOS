//
//  PokitLinkCard.swift
//  DSKit
//
//  Created by 김도형 on 7/10/24.
//

import SwiftUI

import Util

public struct PokitLinkCard<Item: PokitLinkCardItem>: View {
    private let link: Item
    private let action: () -> Void
    private let kebabAction: () -> Void
    
    public init(
        link: Item,
        action: @escaping () -> Void,
        kebabAction: @escaping () -> Void
    ) {
        self.link = link
        self.action = action
        self.kebabAction = kebabAction
    }
    
    public var body: some View {
        Button(action: action) {
            buttonLabel
        }
    }
    
    private var buttonLabel: some View {
        HStack(spacing: 12) {
            thumbleNail
            
            VStack(spacing: 8) {
                HStack {
                    title
                    
                    Spacer()
                }
                
                HStack {
                    subTitle
                    
                    Spacer()
                }
                
                HStack {
                    badges()
                    
                    Spacer()
                }
            }
            .overlay(alignment: .topTrailing) {
                kebabButton
            }
        }
    }
    
    private var title: some View {
        Text(link.title)
            .pokitFont(.b3(.b))
            .foregroundStyle(.pokit(.text(.primary)))
            .multilineTextAlignment(.leading)
            .lineLimit(2)
    }
    
    private var subTitle: some View {
        Text("\(date) • \(link.domain)")
            .pokitFont(.detail2)
            .foregroundStyle(.pokit(.text(.tertiary)))
    }
    
    @ViewBuilder
    private func badges() -> some View {
        let isUnCategorized = link.categoryType == "미분류"
        
        HStack(spacing: 6) {
            PokitBadge(
                link.categoryType,
                state: isUnCategorized ? .unCategorized : .default
            )
            
            if !link.isRead {
                PokitBadge("안읽음", state: .unRead)
            }
        }
    }
    
    private var kebabButton: some View {
        Button(action: kebabAction) {
            Image(.icon(.kebab))
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.pokit(.icon(.primary)))
        }
    }
    
    private var thumbleNail: some View {
        AsyncImage(url: .init(string: link.thumbNail)) { image in
            image
                .resizable()
        } placeholder: {
            Color.pokit(.bg(.disable))
        }
        .frame(width: 124, height: 94)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    private var date: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: link.createAt)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(.pokit(.color(.grayScale(._100))))
            .frame(height: 1)
    }
    
    @ViewBuilder
    public func divider(isFirst: Bool, isLast: Bool) -> some View {
        let edge: Edge.Set = isFirst ? .bottom : isLast ? .top : .vertical
        
        self
            .padding(edge, 20)
            .background(alignment: .bottom) {
                if !isLast {
                    divider
                }
            }
    }
}

fileprivate struct Link: PokitLinkCardItem {
    var title: String
    
    var thumbNail: String
    
    var createAt: Date
    
    var categoryType: String
    
    var isRead: Bool
    
    var domain: String
    
    init(
        title: String,
        thumbNail: String,
        createAt: Date,
        categoryType: String,
        isRead: Bool,
        domain: String
    ) {
        self.title = title
        self.thumbNail = thumbNail
        self.createAt = createAt
        self.categoryType = categoryType
        self.isRead = isRead
        self.domain = domain
    }
}

#Preview {
    VStack(spacing: 0) {
        PokitLinkCard(
            link: Link(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/200/300​",
                createAt: .now,
                categoryType: "미분류",
                isRead: false,
                domain: "youtube"
            ),
            action: {},
            kebabAction: {}
        )
        .divider(isFirst: true, isLast: false)
        
        PokitLinkCard(
            link: Link(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/200/300​",
                createAt: .now,
                categoryType: "미분류",
                isRead: false,
                domain: "youtube"
            ),
            action: {},
            kebabAction: {}
        )
        .divider(isFirst: false, isLast: false)
        
        PokitLinkCard(
            link: Link(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/200/300​",
                createAt: .now,
                categoryType: "미분류",
                isRead: false,
                domain: "youtube"
            ),
            action: {},
            kebabAction: {}
        )
        .divider(isFirst: false, isLast: true)
    }
    .padding(.horizontal, 20)
}
