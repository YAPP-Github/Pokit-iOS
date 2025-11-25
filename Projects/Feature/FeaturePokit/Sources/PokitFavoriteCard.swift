//
//  PokitFavoriteCard.swift
//  FeaturePokit
//
//  Created by 김민호 on 1/6/25.
//

import SwiftUI

import NukeUI
import DSKit
import Util

public struct PokitFavoriteCard: View {
    private let linkCount: Int
    private let action: () -> Void
    
    public init(
        linkCount: Int,
        action: @escaping () -> Void
    ) {
        self.linkCount = linkCount
        self.action = action
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
                
                Spacer(minLength: 28)
            }
            .overlay(alignment: .trailing) {
                Image(.icon(.tack))
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.pokit(.icon(.primary)))
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
    
    private var title: some View {
        Text("즐겨찾기")
            .pokitFont(.b1(.b))
            .foregroundStyle(.pokit(.text(.primary)))
    }
    
    private var subTitle: some View {
        Text("링크 \(linkCount)개")
            .pokitFont(.detail2)
            .foregroundStyle(.pokit(.text(.tertiary)))
            .contentTransition(.numericText())
    }

    private var thumbNail: some View {
        LazyImage(url: Constants.즐겨찾기_썸네일_주소) { state in
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
            .fill(.pokit(.bg(.brand)).opacity(0.1))
    }
}

#Preview {
    PokitFavoriteCard(linkCount: 3, action: {})
}
