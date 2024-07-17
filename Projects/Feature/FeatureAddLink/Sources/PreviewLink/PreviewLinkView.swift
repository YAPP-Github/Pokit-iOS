//
//  PreviewLinkView.swift
//  Feature
//
//  Created by 김도형 on 7/17/24.

import ComposableArchitecture
import SwiftUI

import DSKit

@ViewAction(for: PreviewLinkFeature.self)
public struct PreviewLinkView: View {
    /// - Properties
    public var store: StoreOf<PreviewLinkFeature>
    
    /// - Initializer
    public init(store: StoreOf<PreviewLinkFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PreviewLinkView {
    var body: some View {
        WithPerceptionTracking {
            content
        }
    }
}
//MARK: - Configure View
private extension PreviewLinkView {
    var content: some View {
        HStack(spacing: 16) {
            Image(uiImage: store.image)
                .resizable()
                .frame(width: 124, height: 108)
            
            info(title: store.title)
            
            Spacer()
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.pokit(.bg(.base)))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.pokit(.border(.tertiary)), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 3, x: 2, y: 2)
    }
    
    @ViewBuilder
    func info(title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .pokitFont(.b3(.b))
                .foregroundStyle(.pokit(.text(.secondary)))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            Text(store.url)
                .pokitFont(.detail2)
                .foregroundStyle(.pokit(.text(.tertiary)))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
        .padding(.vertical, 16)
        .padding(.trailing, 20)
    }
}
//MARK: - Preview
#Preview {
//    PreviewLinkView(
//        store: Store(
//            initialState: .init(title: "네이버", image: UIImage),
//            reducer: { PreviewLinkFeature()._printChanges() }
//        )
//    )
}


