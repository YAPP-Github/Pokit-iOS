//
//  LinkPresentationClient.swift
//  CoreKit
//
//  Created by 김도형 on 7/19/24.
//

import UIKit
import LinkPresentation
import UniformTypeIdentifiers

import Dependencies

public struct LinkPresentationClient {
    public var convertImage: (_ item: (any NSSecureCoding)?) -> UIImage?
    public var provideMetadata: @Sendable (_ url: URL) async -> (String?, (any NSSecureCoding)?)
}

extension LinkPresentationClient: DependencyKey {
    public static let liveValue: Self = {
        let linkPresentationProvider = LinkPresentationProvider()
        
        return Self(
            convertImage: { item in
                linkPresentationProvider.convertImage(item)
            },
            provideMetadata: { url in
                await linkPresentationProvider.provideMetadata(url)
            }
        )
    }()
    
    public static let previewValue: Self = liveValue
}

public extension DependencyValues {
    var linkPresentation: LinkPresentationClient {
        get { self[LinkPresentationClient.self] }
        set { self[LinkPresentationClient.self] = newValue }
    }
}
