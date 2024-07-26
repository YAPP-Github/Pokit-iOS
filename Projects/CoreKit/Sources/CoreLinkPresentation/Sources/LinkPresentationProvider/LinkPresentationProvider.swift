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
        
        /// - 파싱한 썸네일 정보가 `UIImage`인 경우
        if item is UIImage {
            image = item as? UIImage
        }
        
        /// - 파싱한 썸네일 정보가 `URL`인 경우
        if item is URL {
            guard let url = item as? URL,
                  let data = try? Data(contentsOf: url)
            else { return image }
            
            image = UIImage(data: data)
        }
        
        /// - 파싱한 썸네일 정보가 `Data`인 경우
        if item is Data {
            guard let data = item as? Data
            else { return image }
            
            image = UIImage(data: data)
        }
        
        return image
    }
    
    /// - 링크에 대한 메타데이터 제공
    public func provideMetadata(_ url: URL) async -> (String?, (any NSSecureCoding)?) {
        let provider = LPMetadataProvider()
        let metadata = try? await provider.startFetchingMetadata(for: url)
        let item = try? await metadata?.imageProvider?.loadItem(
            forTypeIdentifier: String(describing: UTType.image)
        )
        
        return (metadata?.title, item)
    }
}
