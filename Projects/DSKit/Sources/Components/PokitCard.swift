//
//  PokitCard.swift
//  DSKit
//
//  Created by 김도형 on 7/10/24.
//

import SwiftUI

import Util
import NukeUI

public struct PokitCard<Item: PokitCardItem & Shareable>: View {
    private let category: Item
    private let action: () -> Void
    private let kebabAction: () -> Void
    
    public init(
        category: Item,
        action: @escaping () -> Void,
        kebabAction: @escaping () -> Void
    ) {
        self.category = category
        self.action = action
        self.kebabAction = kebabAction
    }
    
    public var body: some View {
        Button(action: action) {
            buttonLabel
        }
    }
    
    @MainActor
    private var buttonLabel: some View {
        VStack(spacing: 0) {
            HStack {
                title
                
                Spacer(minLength: 28)
            }
            .overlay(alignment: .trailing) {
                kebabButton
            }
            
            HStack {
                subTitle
                
                Spacer()
            }
            .padding(.top, 2)
            
            Spacer()
            
            HStack {
                Spacer()
                
                thumbNail
            }
        }
        .padding([.top, .leading], 12)
        .padding([.bottom, .trailing], 8)
        .background {
            background
        }
        .frame(height: 152)
    }
    
    @ViewBuilder
    private var title: some View {
        let isPrivate = category.openType == .비공개
        
        HStack(spacing: isPrivate ? 2 : 0) {
            if isPrivate {
                Image(.icon(.lock))
                    .resizable()
                    .frame(width: 18, height: 18)
                    .padding(.vertical, 3)
                    .foregroundStyle(.pokit(.icon(.tertiary)))
            }
            Text(category.categoryName)
                .pokitFont(.b1(.b))
                .foregroundStyle(.pokit(.text(.primary)))
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
    
    @ViewBuilder
    private var subTitle: some View {
        let isShared = category.userCount > 1
        
        HStack(spacing: 2) {
            Text("링크 \(category.contentCount)개")
                .contentTransition(.numericText())
            
            if isShared {
                Text("•")
                    .pokitFont(.detail2)
                Image(.iconMember)
                    .resizable()
                    .frame(width: 16, height: 16)
                Text("\(category.userCount)명")
            }
        }
        .pokitFont(.detail2)
        .foregroundStyle(.pokit(.text(.tertiary)))
    }

    @MainActor
    private var thumbNail: some View {
        LazyImage(url: URL(string: category.categoryImage.imageURL)) { state in
            Group {
                if let image = state.image {
                    image
                        .resizable()
                } else {
                    PokitSpinner()
                        .foregroundStyle(.pokit(.icon(.brand)))
                        .frame(width: 48, height: 48)
                }
            }
            .animation(.pokitDissolve, value: state.image)
        }
        .frame(width: 84, height: 84)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(.pokit(.bg(.primary)))
    }
}
