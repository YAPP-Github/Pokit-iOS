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
                return DSKitAsset.iconArrowDown.swiftUIImage
            case .arrowLeft:
                return DSKitAsset.iconArrowLeft.swiftUIImage
            case .arrowRight:
                return DSKitAsset.iconArrowRight.swiftUIImage
            case .arrowUp:
                return DSKitAsset.iconArrowUp.swiftUIImage
            case .bell:
                return DSKitAsset.iconBell.swiftUIImage
            case .edit:
                return DSKitAsset.iconEdit.swiftUIImage
            case .folderFill:
                return DSKitAsset.iconFolderFill.swiftUIImage
            case .homeFill:
                return DSKitAsset.iconHomeFill.swiftUIImage
            case .kebab:
                return DSKitAsset.iconKebab.swiftUIImage
            case .plus:
                return DSKitAsset.iconPlus.swiftUIImage
            case .search:
                return DSKitAsset.iconSearch.swiftUIImage
            case .setup:
                return DSKitAsset.iconSetup.swiftUIImage
            case .share:
                return DSKitAsset.iconShare.swiftUIImage
            case .star:
                return DSKitAsset.iconStar.swiftUIImage
            case .starFill:
                return DSKitAsset.iconStarFill.swiftUIImage
            case .trash:
                return DSKitAsset.iconTrash.swiftUIImage
            case .plusR:
                return DSKitAsset.iconPlus.swiftUIImage
            case .remind:
                return DSKitAsset.iconRemind.swiftUIImage
            case .reminder:
                return DSKitAsset.iconReminder.swiftUIImage
            case .info:
                return DSKitAsset.iconInfo.swiftUIImage
            case .link:
                return DSKitAsset.iconLink.swiftUIImage
            case .folderLine:
                return DSKitAsset.iconFolderline.swiftUIImage
            case .linkLine:
                return DSKitAsset.iconLinkline.swiftUIImage
            case .align:
                return DSKitAsset.iconAlign.swiftUIImage
            case .dash:
                return DSKitAsset.iconDash.swiftUIImage
            case .dicover:
                return DSKitAsset.iconDiscover.swiftUIImage
            case .filter:
                return DSKitAsset.iconFilter.swiftUIImage
            case .x:
                return DSKitAsset.iconX.swiftUIImage
            case .check:
                return DSKitAsset.iconCheck.swiftUIImage
            case .google:
                return DSKitAsset.iconGoogle.swiftUIImage
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
        case folderFill
        case homeFill
        case kebab
        case plus
        case search
        case setup
        case share
        case star
        case starFill
        case trash
        case plusR
        case remind
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
        case check
        case google
    }
}
