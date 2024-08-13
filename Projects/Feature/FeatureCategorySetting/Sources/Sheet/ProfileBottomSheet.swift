//
//  ProfileBottomSheet.swift
//  Feature
//
//  Created by 김민호 on 7/25/24.

import SwiftUI

import Domain
import CoreKit
import DSKit

public struct ProfileBottomSheet: View {
    @State private var height: CGFloat = 0
    @State private var images: [BaseCategoryImage]
    private let colmumns = [
        GridItem(.fixed(66), spacing: 20),
        GridItem(.fixed(66), spacing: 20),
        GridItem(.fixed(66), spacing: 0)
    ]
    private let delegateSend: ((ProfileBottomSheet.Delegate) -> Void)?
    
    public init(
        images: [BaseCategoryImage],
        delegateSend: ((ProfileBottomSheet.Delegate) -> Void)?
    ) {
        self.images = images
        self.delegateSend = delegateSend
    }
    
}
//MARK: - View
public extension ProfileBottomSheet {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: colmumns, spacing: 12) {
                ForEach(images) { item in
                    AsyncImage(
                        url: URL(string: item.imageURL),
                        transaction: .init(animation: .smooth)
                    ) { phase in
                        switch phase {
                        case .success(let image):
                            Button(action: { delegateSend?(.imageSelected(item)) }) {
                                image
                                    .resizable()
                                    .roundedCorner(12, corners: .allCorners)
                            }
                            .buttonStyle(.plain)
                        default:
                            PokitSpinner()
                                .foregroundStyle(.pokit(.icon(.brand)))
                                .frame(width: 48, height: 48)
                        }
                    }
                    .frame(width: 66, height: 66)
                }
            }
            .padding(.vertical, 12)
            .background(.white)
        }
        .padding(.top)
        .padding(.top, 26)
        .padding(.bottom, 36)
        .fixedSize(horizontal: false, vertical: true)
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .bottom)
        .background(.pokit(.bg(.base)))
        .pokitPresentationCornerRadius()
        .pokitPresentationBackground()
        .presentationDragIndicator(.visible)
        .readHeight()
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            if let height {
                self.height = height
            }
        }
        .presentationDetents([.height(height)])
    }
}
//MARK: - Delegate
public extension ProfileBottomSheet {
    enum Delegate: Equatable {
        case imageSelected(BaseCategoryImage)
    }
}
//MARK: - Preview
#Preview {
    ProfileBottomSheet(
        images: CategoryImageResponse.mock.map { $0.toDomain() },
        delegateSend: nil
    )
}


