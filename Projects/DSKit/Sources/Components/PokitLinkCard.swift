//
//  PokitLinkCard.swift
//  DSKit
//
//  Created by 김도형 on 7/10/24.
//

import SwiftUI

import Util
import NukeUI

public struct PokitLinkCard<Item: PokitLinkCardItem>: View {
    private let link: Item
    private let state: PokitLinkCard.State
    private let type: PokitLinkCard.CardType
    private let action: () -> Void
    private let kebabAction: (() -> Void)?
    private let fetchMetaData: (() -> Void)?
    private let favoriteAction: (() -> Void)?
    private let selectAction: (() -> Void)?
    
    public init(
        link: Item,
        state: PokitLinkCard.State,
        type: PokitLinkCard.CardType = .accept,
        action: @escaping () -> Void,
        kebabAction: (() -> Void)? = nil,
        fetchMetaData: (() -> Void)? = nil,
        favoriteAction: (() -> Void)? = nil,
        selectAction: (() -> Void)? = nil
    ) {
        self.link = link
        self.state = state
        self.type = type
        self.action = action
        self.kebabAction = kebabAction
        self.fetchMetaData = fetchMetaData
        self.favoriteAction = favoriteAction
        self.selectAction = selectAction
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Button(action: action) {
                buttonLabel
            }
            .padding(.top, state == .top ? 0 : 20)
            
            if case .top = state {
                divider
            }
            
            if case .middle = state {
                divider
            }
        }
    }
    
    @MainActor
    private var buttonLabel: some View {
        HStack(spacing: 12) {
            if let url = URL(string: link.thumbNail) {
                thumbleNail(url: url)
            } else {
                placeholder
            }
            
            VStack(spacing: 8) {
                HStack {
                    title
                    
                    Spacer(minLength: kebabAction != nil ? 24 : 0)
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
                if let kebabAction {
                    kebabButton(kebabAction)
                }
            }
        }
        .overlay(alignment: .bottomLeading) {
            if case .linkList = type,
               let isFavorite = link.isFavorite {
                PokitBookmark(
                    state: isFavorite ? .active : .default,
                    action: { favoriteAction?() }
                )
                .padding(4)
            }
        }
        .overlay(alignment: .topLeading) {
            if case .unCatgorized(let isSelected) = type {
                PokitCheckBox(
                    baseState: .default,
                    selectedState: .filled,
                    isSelected: .constant(isSelected),
                    shape: .rectangle,
                    action: { selectAction?() }
                )
                .padding(4)
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
            if let isRead = link.isRead, !isRead {
                PokitBadge(state: .unRead)
            }
            
            PokitBadge(
                state: isUnCategorized
                ? .unCategorized
                : .default(link.categoryName)
            )
            
            if let memo = link.memo, !memo.isEmpty {
                PokitBadge(state: .memo)
            }
        }
    }
    
    @ViewBuilder
    private func kebabButton(_ kebabAction: @escaping () -> Void) -> some View {
        Button(action: kebabAction) {
            Image(.icon(.kebab))
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.pokit(.icon(.primary)))
        }
    }
    
    @MainActor
    private func thumbleNail(url: URL) -> some View {
        LazyImage(url: url) { phase in
            Group {
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    placeholder
                        .onAppear { fetchMetaData?() }
                } else {
                    placeholder
                }
            }
            .animation(.pokitDissolve, value: phase.image)
            .frame(width: 124, height: 94)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
    
    private var divider: some View {
        Rectangle()
            .fill(.pokit(.color(.grayScale(._100))))
            .frame(height: 1)
    }
    
    private var placeholder: some View {
        ZStack {
            Color.pokit(.bg(.disable))
            
            PokitSpinner()
                .foregroundStyle(.pokit(.icon(.brand)))
                .frame(width: 48, height: 48)
        }
        .frame(width: 124, height: 94)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

extension PokitLinkCard {
    public enum State {
        case top
        case middle
        case bottom
    }
    
    public enum CardType {
        case linkList
        case unCatgorized(isSelected: Bool)
        case accept
    }
}
