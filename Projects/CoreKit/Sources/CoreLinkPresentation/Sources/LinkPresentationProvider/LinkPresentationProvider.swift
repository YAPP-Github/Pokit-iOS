//
//  LinkPresentationProvider.swift
//  CoreKit
//
//  Created by 김도형 on 7/19/24.
//

import Foundation
import LinkPresentation
import UniformTypeIdentifiers

public final class LinkPresentationProvider {
    public func convertImage(_ item: (any NSSecureCoding)?) -> UIImage? {
        var image: UIImage?
        
        if item is UIImage {
            image = item as? UIImage
        }
        
        if item is URL {
            guard let url = item as? URL,
                  let data = try? Data(contentsOf: url)
            else { return image }
            
            image = UIImage(data: data)
        }
        
        if item is Data {
            guard let data = item as? Data
            else { return image }
            
            image = UIImage(data: data)
        }
        
        return image
    }
    
    public func provideMetadata(_ url: URL) async -> (String?, (any NSSecureCoding)?) {
        let provider = LPMetadataProvider()
        let metadata = try? await provider.startFetchingMetadata(for: url)
        let item = try? await metadata?.imageProvider?.loadItem(
            forTypeIdentifier: String(describing: UTType.image)
        )
        
        return (metadata?.title, item)
    }
}
