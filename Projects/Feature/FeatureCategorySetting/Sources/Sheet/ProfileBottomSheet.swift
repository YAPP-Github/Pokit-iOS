//
//  ProfileBottomSheet.swift
//  Feature
//
//  Created by 김민호 on 7/25/24.

import SwiftUI

import DSKit

public struct ProfileBottomSheet: View {
    @State private var height: CGFloat = 0
    @State private var images: [CategorySettingImageMock]
    private let colmumns = [
        GridItem(.fixed(66), spacing: 20),
        GridItem(.fixed(66), spacing: 20),
        GridItem(.fixed(66), spacing: 0)
    ]
    private let delegateSend: ((ProfileBottomSheet.Delegate) -> Void)?
    
    public init(
        images: [CategorySettingImageMock],
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
                ForEach(images, id: \.imageId) { item in
                    AsyncImage(
                        url: URL(string: item.imageUrl),
                        transaction: .init(animation: .spring)
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
                            RoundedRectangle(cornerRadius: 12)
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
        .ignoresSafeArea(edges: [.bottom])
        .background(.white)
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
        case imageSelected(CategorySettingImageMock)
    }
}
//MARK: - Preview
#Preview {
    ProfileBottomSheet(
        images: CategorySettingImageMock.mock,
        delegateSend: nil
    )
}


