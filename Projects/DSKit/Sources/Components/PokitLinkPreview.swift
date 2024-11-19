//
//  PokitLinkPreview.swift
//  DSKit
//
//  Created by 김도형 on 7/19/24.
//

import SwiftUI

import NukeUI

public struct PokitLinkPreview: View {
    @Environment(\.openURL)
    private var openURL
    
    private let title: String
    private let url: String
    private let imageURL: String
    
    public init(
        title: String,
        url: String,
        imageURL: String
    ) {
        self.title = title
        self.url = url
        self.imageURL = imageURL
    }
    
    public var body: some View {
        Button(action: buttonTapped) {
            buttonLabel
        }
    }
    
    @MainActor
    private var buttonLabel: some View {
        HStack(spacing: 16) {
            LazyImage(url: URL(string: imageURL)) { phase in
                Group {
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        PokitSpinner()
                            .foregroundStyle(.pokit(.icon(.brand)))
                            .frame(width: 48, height: 48)
                    }
                }
                .animation(.pokitDissolve, value: phase.image)
            }
            .frame(width: 124, height: 108)
            .clipped()
            
            info(title: title)
            
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
        .onAppear {
            withAnimation {
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.success)
            }
        }
    }
    
    @ViewBuilder
    private func info(title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .pokitFont(.b3(.b))
                .foregroundStyle(.pokit(.text(.secondary)))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            Text(url)
                .pokitFont(.detail2)
                .foregroundStyle(.pokit(.text(.tertiary)))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
        .padding(.vertical, 16)
        .padding(.trailing, 20)
    }
    
    private func buttonTapped() {
        guard let url = URL(string: url) else { return }
        openURL(url)
    }
}
