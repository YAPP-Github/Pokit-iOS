//
//  PokitCard.swift
//  DSKit
//
//  Created by 김도형 on 7/10/24.
//

import SwiftUI

import Util

public struct PokitCard<Item: PokitCardItem>: View {
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
    
    private var buttonLabel: some View {
        VStack(spacing: 0) {
            HStack {
                title
                
                Spacer()
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
        .frame(width: 161.5, height: 152)
    }
    
    private var title: some View {
        Text(category.categoryType)
            .pokitFont(.b1(.b))
            .foregroundStyle(.pokit(.text(.primary)))
    }
    
    private var kebabButton: some View {
        Button(action: kebabAction) {
            Image(.icon(.kebab))
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.pokit(.icon(.primary)))
        }
    }
    
    private var subTitle: some View {
        Text("링크 \(category.contentSize)개")
            .pokitFont(.detail2)
            .foregroundStyle(.pokit(.text(.tertiary)))
    }
    
    private var thumbNail: some View {
        AsyncImage(url: .init(string: category.thumbNail)) { image in
            image
                .resizable()
        } placeholder: {
            Color.pokit(.bg(.disable))
        }
        .frame(width: 68, height: 68)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(.pokit(.bg(.primary)))
    }
}

fileprivate struct Category: PokitCardItem {
    var id: Int
    
    var categoryType: String
    
    var contentSize: Int
    
    var thumbNail: String
    
    init(id: Int, categoryName: String, contentSize: Int, thumbNail: String) {
        self.id = id
        self.categoryType = categoryName
        self.contentSize = contentSize
        self.thumbNail = thumbNail
    }
}

#Preview {
    PokitCard(
        category: Category(
            id: 1,
            categoryName: "요리/레시피", 
            contentSize: 10,
            thumbNail: "https://picsum.photos/200/300​"
        ),
        action: {},
        kebabAction: {}
    )
}
