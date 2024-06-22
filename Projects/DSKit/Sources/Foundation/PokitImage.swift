//
//  PokitImage.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

public enum PokitImage {
    case icon(Self.Name)
    
    public var image: Image {
        switch self {
        case .icon(let name):
            switch name {
            case .arrowDown:
                return .init(.iconArrowDown)
            case .arrowLeft:
                return .init(.iconArrowLeft)
            case .arrowRight:
                return .init(.iconArrowRight)
            case .arrowUp:
                return .init(.iconArrowUp)
            case .bell:
                return .init(.iconBell)
            case .edit:
                return .init(.iconEdit)
            case .folder:
                return .init(.iconFolder)
            case .home:
                return .init(.iconHome)
            case .kebab:
                return .init(.iconKebab)
            case .plus:
                return .init(.iconPlus)
            case .search:
                return .init(.iconSearch)
            case .setup:
                return .init(.iconSetup)
            case .share:
                return .init(.iconShare)
            case .star:
                return .init(.iconStar)
            case .trash:
                return .init(.iconTrash)
            }
        }
    }
}

public extension PokitImage {
    enum Name {
        case arrowDown
        case arrowLeft
        case arrowRight
        case arrowUp
        case bell
        case edit
        case folder
        case home
        case kebab
        case plus
        case search
        case setup
        case share
        case star
        case trash
    }
}
