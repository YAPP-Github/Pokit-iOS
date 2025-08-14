//
//  PokitProfileBottomSheet.swift
//  DSKit
//
//  Created by 김민호 on 2/24/25.
//

import SwiftUI

import Util
import NukeUI

public struct PokitProfileBottomSheet<ImageType: CategoryImage & Identifiable & Equatable>: View {
    @State private var height: CGFloat = 0
    @State private var images: [ImageType]
    let selectedImage: ImageType?
    private let colmumns = [
        GridItem(.fixed(72), spacing: 20),
        GridItem(.fixed(72), spacing: 20),
        GridItem(.fixed(72), spacing: 0)
    ]
    private let delegateSend: ((PokitProfileBottomSheet.Delegate) -> Void)?
    
    public init(
        selectedImage: ImageType?,
        images: [ImageType],
        delegateSend: ((PokitProfileBottomSheet.Delegate) -> Void)?
    ) {
        self.selectedImage = selectedImage
        self.images = images
        self.delegateSend = delegateSend
    }
    
}
//MARK: - View
public extension PokitProfileBottomSheet {
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
public extension PokitProfileBottomSheet {
    enum Delegate: Equatable {
        case 이미지_선택했을때(ImageType)
    }
}
//MARK: - Preview
#if DEBUG
struct BaseCategoryImageMock: Equatable, Identifiable, CategoryImage {
    public var id: Int
    public var imageURL: String
}
extension BaseCategoryImageMock {
    static var mock: [Self] {
        return [
            BaseCategoryImageMock(
                id: 231,
                imageURL: "https://pokit-storage.s3.ap-northeast-2.amazonaws.com/logo/pokit.png"
            )
        ]
    }
}
#Preview {
    PokitProfileBottomSheet(
        selectedImage: BaseCategoryImageMock(
            id: 312,
            imageURL: "https://pokit-storage.s3.ap-northeast-2.amazonaws.com/logo/pokit.png"),
        images: BaseCategoryImageMock.mock,
        delegateSend: nil
    )
}
#endif

