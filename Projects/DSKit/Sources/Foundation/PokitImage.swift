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
            case .plusR:
                return .init(.iconPlusR)
            case .reminder:
                return .init(.iconReminder)
            case .info:
                return .init(.iconInfo)
            case .link:
                return .init(.iconLink)
            case .folderLine:
                return .init(.iconFolderline)
            case .linkLine:
                return .init(.iconLinkline)
            case .align:
                return .init(.iconAlign)
            case .dash:
                return .init(.iconDash)
            case .dicover:
                return .init(.iconDiscover)
            case .filter:
                return .init(.iconFilter)
            case .x:
                return .init(.iconX)
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
        case plusR
        case reminder
        case info
        case link
        case folderLine
        case linkLine
        case align
        case dash
        case dicover
        case filter
        case x
    }
}
