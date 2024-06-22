//
//  Color+Extension.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

public extension Color {
    private static func pokitColor(_ color: PokitColor.Color) -> Color {
        switch color {
            case .blue(let scale):
                switch scale {
                case ._50:
                    return DSKitAsset.Blue._50.swiftUIColor
                case ._100:
                    return DSKitAsset.Blue._100.swiftUIColor
                case ._200:
                    return DSKitAsset.Blue._200.swiftUIColor
                case ._300:
                    return DSKitAsset.Blue._300.swiftUIColor
                case ._400:
                    return DSKitAsset.Blue._400.swiftUIColor
                case ._500:
                    return DSKitAsset.Blue._500.swiftUIColor
                case ._600:
                    return DSKitAsset.Blue._600.swiftUIColor
                case ._700:
                    return DSKitAsset.Blue._700.swiftUIColor
                case ._800:
                    return DSKitAsset.Blue._800.swiftUIColor
                case ._900:
                    return DSKitAsset.Blue._900.swiftUIColor
                case .white:
                    return Color.white
                }
            case .green(let scale):
                switch scale {
                case ._50:
                    return DSKitAsset.Green._50.swiftUIColor
                case ._100:
                    return DSKitAsset.Green._100.swiftUIColor
                case ._200:
                    return DSKitAsset.Green._200.swiftUIColor
                case ._300:
                    return DSKitAsset.Green._300.swiftUIColor
                case ._400:
                    return DSKitAsset.Green._400.swiftUIColor
                case ._500:
                    return DSKitAsset.Green._500.swiftUIColor
                case ._600:
                    return DSKitAsset.Green._600.swiftUIColor
                case ._700:
                    return DSKitAsset.Green._700.swiftUIColor
                case ._800:
                    return DSKitAsset.Green._800.swiftUIColor
                case ._900:
                    return DSKitAsset.Green._900.swiftUIColor
                case .white:
                    return Color.white
                }
            case .orange(let scale):
                switch scale {
                case ._50:
                    return DSKitAsset.Orange._50.swiftUIColor
                case ._100:
                    return DSKitAsset.Orange._100.swiftUIColor
                case ._200:
                    return DSKitAsset.Orange._200.swiftUIColor
                case ._300:
                    return DSKitAsset.Orange._300.swiftUIColor
                case ._400:
                    return DSKitAsset.Orange._400.swiftUIColor
                case ._500:
                    return DSKitAsset.Orange._500.swiftUIColor
                case ._600:
                    return DSKitAsset.Orange._600.swiftUIColor
                case ._700:
                    return DSKitAsset.Orange._700.swiftUIColor
                case ._800:
                    return DSKitAsset.Orange._800.swiftUIColor
                case ._900:
                    return DSKitAsset.Orange._900.swiftUIColor
                case .white:
                    return Color.white
                }
            case .red(let scale):
                switch scale {
                case ._50:
                    return DSKitAsset.Red._50.swiftUIColor
                case ._100:
                    return DSKitAsset.Red._100.swiftUIColor
                case ._200:
                    return DSKitAsset.Red._200.swiftUIColor
                case ._300:
                    return DSKitAsset.Red._300.swiftUIColor
                case ._400:
                    return DSKitAsset.Red._400.swiftUIColor
                case ._500:
                    return DSKitAsset.Red._500.swiftUIColor
                case ._600:
                    return DSKitAsset.Red._600.swiftUIColor
                case ._700:
                    return DSKitAsset.Red._700.swiftUIColor
                case ._800:
                    return DSKitAsset.Red._800.swiftUIColor
                case ._900:
                    return DSKitAsset.Red._900.swiftUIColor
                case .white:
                    return Color.white
                }
            case .yellow(let scale):
                switch scale {
                case ._50:
                    return DSKitAsset.Yellow._50.swiftUIColor
                case ._100:
                    return DSKitAsset.Yellow._100.swiftUIColor
                case ._200:
                    return DSKitAsset.Yellow._200.swiftUIColor
                case ._300:
                    return DSKitAsset.Yellow._300.swiftUIColor
                case ._400:
                    return DSKitAsset.Yellow._400.swiftUIColor
                case ._500:
                    return DSKitAsset.Yellow._500.swiftUIColor
                case ._600:
                    return DSKitAsset.Yellow._600.swiftUIColor
                case ._700:
                    return DSKitAsset.Yellow._700.swiftUIColor
                case ._800:
                    return DSKitAsset.Yellow._800.swiftUIColor
                case ._900:
                    return DSKitAsset.Yellow._900.swiftUIColor
                case .white:
                    return Color.white
                }
            case .grayScale(let scale):
                switch scale {
                case ._50:
                    return DSKitAsset.GrayScale._50.swiftUIColor
                case ._100:
                    return DSKitAsset.GrayScale._100.swiftUIColor
                case ._200:
                    return DSKitAsset.GrayScale._200.swiftUIColor
                case ._300:
                    return DSKitAsset.GrayScale._300.swiftUIColor
                case ._400:
                    return DSKitAsset.GrayScale._400.swiftUIColor
                case ._500:
                    return DSKitAsset.GrayScale._500.swiftUIColor
                case ._600:
                    return DSKitAsset.GrayScale._600.swiftUIColor
                case ._700:
                    return DSKitAsset.GrayScale._700.swiftUIColor
                case ._800:
                    return DSKitAsset.GrayScale._800.swiftUIColor
                case ._900:
                    return DSKitAsset.GrayScale._900.swiftUIColor
                case .white:
                    return Color.white
                }
            }
    }
    
    static func pokit(_ pokitColor: PokitColor) -> Color {
        switch pokitColor {
        case .color(let color):
            return .pokitColor(color)
        case .text(let text):
            switch text {
            case .brand:
                return .pokitColor(.orange(._500))
            case .disable:
                return .pokitColor(.grayScale(._500))
            case .error:
                return .pokitColor(.red(._500))
            case .info:
                return .pokitColor(.blue(._700))
            case .inverseWh:
                return .pokitColor(.grayScale(.white))
            case .primary:
                return .pokitColor(.grayScale(._900))
            case .secondary:
                return .pokitColor(.grayScale(._700))
            case .success:
                return .pokitColor(.green(._400))
            case .tertiary:
                return .pokitColor(.grayScale(._400))
            case .warning:
                return .pokitColor(.yellow(._400))
            }
        case .icon(let icon):
            switch icon {
            case .brand:
                return .pokitColor(.orange(._500))
            case .brandBold:
                return .pokitColor(.orange(._700))
            case .disable:
                return .pokitColor(.grayScale(._500))
            case .error:
                return .pokitColor(.red(._500))
            case .info:
                return .pokitColor(.blue(._700))
            case .inverseWh:
                return .pokitColor(.grayScale(.white))
            case .primary:
                return .pokitColor(.grayScale(._800))
            case .secondary:
                return .pokitColor(.grayScale(._400))
            case .success:
                return .pokitColor(.green(._400))
            case .tertiary:
                return .pokitColor(.grayScale(._200))
            case .warning:
                return .pokitColor(.yellow(._400))
            }
        case .bg(let bg):
            switch bg {
            case .base:
                return .pokitColor(.grayScale(.white))
            case .baseIcon:
                return DSKitAsset.Bg.baseIcon.swiftUIColor
            case .brand:
                return .pokitColor(.orange(._500))
            case .disable:
                return .pokitColor(.grayScale(._200))
            case .error:
                return .pokitColor(.red(._500))
            case .info:
                return .pokitColor(.blue(._700))
            case .primary:
                return .pokitColor(.grayScale(._50))
            case .secondary:
                return .pokitColor(.grayScale(._100))
            case .success:
                return .pokitColor(.green(._400))
            case .tertiary:
                return .pokitColor(.grayScale(._700))
            case .warning:
                return .pokitColor(.yellow(._400))
            }
        case .border(let border):
            switch border {
            case .brand:
                return .pokitColor(.orange(._500))
            case .disable:
                return .pokitColor(.grayScale(._200))
            case .error:
                return .pokitColor(.red(._500))
            case .info:
                return .pokitColor(.blue(._700))
            case .inverseWh:
                return .pokitColor(.grayScale(.white))
            case .primary:
                return .pokitColor(.grayScale(._700))
            case .secondary:
                return .pokitColor(.grayScale(._200))
            case .success:
                return .pokitColor(.green(._400))
            case .tertiary:
                return .pokitColor(.grayScale(._100))
            case .warning:
                return .pokitColor(.yellow(._400))
            }
        }
    }
}
