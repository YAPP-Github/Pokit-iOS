//
//  PokitImage.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

public enum PokitImage {
    case icon(Self.Icon)
    case logo(Self.Logo)
    case character(Self.Character)
    case image(Self.PokitImage)
    
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
            case .spinner:
                return DSKitAsset.iconSpinner.swiftUIImage
            case .invite:
                return DSKitAsset.iconInvite.swiftUIImage
            case .memo:
                return DSKitAsset.iconMemo.swiftUIImage
            case .arrowDown2:
                return DSKitAsset.iconArrowDown2.swiftUIImage
            case .hashtag:
                return DSKitAsset.iconHashtag.swiftUIImage
            case .savePokit:
                return DSKitAsset.iconSavepokit.swiftUIImage
            case .pin:
                return DSKitAsset.iconPin.swiftUIImage
            case .member:
                return DSKitAsset.iconMember.swiftUIImage
            case .lock:
                return DSKitAsset.iconLock.swiftUIImage
            case .movePokit:
                return DSKitAsset.iconMovepokit.swiftUIImage
            case .allCheck:
                return DSKitAsset.iconAllcheck.swiftUIImage
            case .allUncheck:
                return DSKitAsset.iconAlluncheck.swiftUIImage
            case .report:
                return DSKitAsset.iconReport.swiftUIImage
            case .tack:
                return DSKitAsset.iconTack.swiftUIImage
            }
        case .logo(let name):
            switch name {
            case .pokit:
                return DSKitAsset.logoPokit.swiftUIImage
            }
        case .character(let name):
            switch name {
            case .empty:
                return DSKitAsset.characterEmpty.swiftUIImage
            case .sad:
                return DSKitAsset.characterSad.swiftUIImage
            case .pooki:
                return DSKitAsset.characterPooki.swiftUIImage
            }
        case .image(let name):
            switch name {
            case .confetti:
                return DSKitAsset.imageConfetti.swiftUIImage
            case .firecracker:
                return DSKitAsset.imageFirecracker.swiftUIImage
            case .profile:
                return DSKitAsset.imageProfile.swiftUIImage
            }
        }
    }
}

public extension PokitImage {
    enum Icon {
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
        case spinner
        case invite
        case memo
        case arrowDown2
        case hashtag
        case savePokit
        case pin
        case member
        case lock
        case movePokit
        case allCheck
        case allUncheck
        case report
        case tack
    }
    
    enum Logo {
        case pokit
    }
    
    enum Character {
        case empty
        case sad
        case pooki
    }
    
    enum PokitImage {
        case confetti
        case firecracker
        case profile
    }
}
