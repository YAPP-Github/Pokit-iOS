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
        GridItem(.fixed(72), spacing: 20),
        GridItem(.fixed(72), spacing: 20),
        GridItem(.fixed(72), spacing: 0)
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
                            Button(action: { delegateSend?(.이미지_선택했을때(item)) }) {
                                image
                                    .resizable()
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .overlay {
                                if let selectedImage, item.imageURL == selectedImage.imageURL {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(.pokit(.border(.brand)), lineWidth: 2)
                                }
                            }
                        } else {
                            PokitSpinner()
                                .foregroundStyle(.pokit(.icon(.brand)))
                                .frame(width: 48, height: 48)
                        }
                    }
                    .frame(width: 72, height: 72)
                    
                }
            }
            .padding(.vertical, 12)
            .background(.white)
        }
        .padding(.top, 36)
        .padding(.bottom, 28)
        .fixedSize(horizontal: false, vertical: true)
        .scrollIndicators(.hidden)
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
        .ignoresSafeArea(edges: .bottom)
    }
}
//MARK: - Delegate
public extension ProfileBottomSheet {
    enum Delegate: Equatable {
        case 이미지_선택했을때(BaseCategoryImage)
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


