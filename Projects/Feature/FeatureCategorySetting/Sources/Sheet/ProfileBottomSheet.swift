//
//  ProfileBottomSheet.swift
//  Feature
//
//  Created by 김민호 on 7/25/24.

import SwiftUI

import Domain
import CoreKit
import DSKit
import NukeUI

public struct ProfileBottomSheet: View {
    @State private var height: CGFloat = 0
    @State private var images: [BaseCategoryImage]
    let selectedImage: BaseCategoryImage?
    private let colmumns = [
        GridItem(.fixed(66), spacing: 20),
        GridItem(.fixed(66), spacing: 20),
        GridItem(.fixed(66), spacing: 0)
    ]
    private let delegateSend: ((ProfileBottomSheet.Delegate) -> Void)?
    
    public init(
        selectedImage: BaseCategoryImage?,
        images: [BaseCategoryImage],
        delegateSend: ((ProfileBottomSheet.Delegate) -> Void)?
    ) {
        self.selectedImage = selectedImage
        self.images = images
        self.delegateSend = delegateSend
    }
    
}
//MARK: - View
public extension ProfileBottomSheet {
    @MainActor
    var body: some View {
        ScrollView {
            LazyVGrid(columns: colmumns, spacing: 12) {
                ForEach(images) { item in
                    LazyImage(
                        url: URL(string: item.imageURL),
                        transaction: .init(animation: .pokitDissolve)
                    ) { phase in
                        if let image = phase.image {
                            Button(action: { delegateSend?(.imageSelected(item)) }) {
                                image
                                    .resizable()
                                    .roundedCorner(12, corners: .allCorners)
                            }
                            .buttonStyle(.plain)
                            .overlay {
                                if let selectedImage, item.imageURL == selectedImage.imageURL {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.pokit(.border(.brand)), lineWidth: 2)
                                }
                            }
                        } else {
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
        selectedImage: BaseCategoryImage(imageId: 312, imageURL: "https://pokit-storage.s3.ap-northeast-2.amazonaws.com/logo/pokit.png"),
        images: CategoryImageResponse.mock.map { $0.toDomain() },
        delegateSend: nil
    )
}


