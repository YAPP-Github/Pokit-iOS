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
                    
                    Spacer(minLength: 24)
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
        Text("\(link.createdAt) • \(link.domain)")
            .pokitFont(.detail2)
            .foregroundStyle(.pokit(.text(.tertiary)))
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    private func badges() -> some View {
        let isUnCategorized = link.categoryName == "미분류"
        
        HStack(spacing: 6) {
            PokitBadge(
                link.categoryName,
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
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ZStack {
                Color.pokit(.bg(.disable))
                
                PokitSpinner()
                    .foregroundStyle(.pokit(.icon(.brand)))
                    .frame(width: 48, height: 48)
            }
        }
        .frame(width: 124, height: 94)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
