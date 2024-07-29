//
//  TabAddSheetType.swift
//  App
//
//  Created by 김민호 on 7/30/24.
//

import SwiftUI

public enum TabAddSheetType: String, CaseIterable {
    case 링크추가
    case 포킷추가
    
    var title: String { self.rawValue }
    var icon: Image {
        switch self {
        case .링크추가: return .init(.icon(.link))
        case .포킷추가: return .init(.icon(.folderFill))
        }
    }
}
