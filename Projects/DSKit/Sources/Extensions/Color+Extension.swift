//
//  Color+Extension.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

public extension Color {
    typealias Blue = DSKitAsset.Blue
    typealias Green = DSKitAsset.Green
    typealias Orange = DSKitAsset.Orange
    typealias Red = DSKitAsset.Red
    typealias Yellow = DSKitAsset.Yellow
    typealias Gray = DSKitAsset.GrayScale
    
    private static func pokitColor(_ color: PokitColor.Color) -> Color {
        switch color {
        case .blue(let scale):
            switch scale {
            case ._50:   return Blue._50.swiftUIColor
            case ._100:  return Blue._100.swiftUIColor
            case ._200:  return Blue._200.swiftUIColor
            case ._300:  return Blue._300.swiftUIColor
            case ._400:  return Blue._400.swiftUIColor
            case ._500:  return Blue._500.swiftUIColor
            case ._600:  return Blue._600.swiftUIColor
            case ._700:  return Blue._700.swiftUIColor
            case ._800:  return Blue._800.swiftUIColor
            case ._900:  return Blue._900.swiftUIColor
            case .white: return Color.white
            }
            
        case .green(let scale):
            switch scale {
            case ._50:   return Green._50.swiftUIColor
            case ._100:  return Green._100.swiftUIColor
            case ._200:  return Green._200.swiftUIColor
            case ._300:  return Green._300.swiftUIColor
            case ._400:  return Green._400.swiftUIColor
            case ._500:  return Green._500.swiftUIColor
            case ._600:  return Green._600.swiftUIColor
            case ._700:  return Green._700.swiftUIColor
            case ._800:  return Green._800.swiftUIColor
            case ._900:  return Green._900.swiftUIColor
            case .white: return Color.white
            }
            
        case .orange(let scale):
            switch scale {
            case ._50:   return Orange._50.swiftUIColor
            case ._100:  return Orange._100.swiftUIColor
            case ._200:  return Orange._200.swiftUIColor
            case ._300:  return Orange._300.swiftUIColor
            case ._400:  return Orange._400.swiftUIColor
            case ._500:  return Orange._500.swiftUIColor
            case ._600:  return Orange._600.swiftUIColor
            case ._700:  return Orange._700.swiftUIColor
            case ._800:  return Orange._800.swiftUIColor
            case ._900:  return Orange._900.swiftUIColor
            case .white: return Color.white
            }
            
        case .red(let scale):
            switch scale {
            case ._50:   return Red._50.swiftUIColor
            case ._100:  return Red._100.swiftUIColor
            case ._200:  return Red._200.swiftUIColor
            case ._300:  return Red._300.swiftUIColor
            case ._400:  return Red._400.swiftUIColor
            case ._500:  return Red._500.swiftUIColor
            case ._600:  return Red._600.swiftUIColor
            case ._700:  return Red._700.swiftUIColor
            case ._800:  return Red._800.swiftUIColor
            case ._900:  return Red._900.swiftUIColor
            case .white: return Color.white
            }
            
        case .yellow(let scale):
            switch scale {
            case ._50:   return Yellow._50.swiftUIColor
            case ._100:  return Yellow._100.swiftUIColor
            case ._200:  return Yellow._200.swiftUIColor
            case ._300:  return Yellow._300.swiftUIColor
            case ._400:  return Yellow._400.swiftUIColor
            case ._500:  return Yellow._500.swiftUIColor
            case ._600:  return Yellow._600.swiftUIColor
            case ._700:  return Yellow._700.swiftUIColor
            case ._800:  return Yellow._800.swiftUIColor
            case ._900:  return Yellow._900.swiftUIColor
            case .white: return Color.white
            }
            
        case .grayScale(let scale):
            switch scale {
            case ._50:   return Gray._50.swiftUIColor
            case ._100:  return Gray._100.swiftUIColor
            case ._200:  return Gray._200.swiftUIColor
            case ._300:  return Gray._300.swiftUIColor
            case ._400:  return Gray._400.swiftUIColor
            case ._500:  return Gray._500.swiftUIColor
            case ._600:  return Gray._600.swiftUIColor
            case ._700:  return Gray._700.swiftUIColor
            case ._800:  return Gray._800.swiftUIColor
            case ._900:  return Gray._900.swiftUIColor
            case .white: return Color.white
            }
        }
    }
    
    static func pokit(_ pokitColor: PokitColor) -> Color {
        switch pokitColor {
        case .color(let color): return .pokitColor(color)
        /// - text Color
        case .text(let text):
            switch text {
            case .brand:     return .pokitColor(.orange(._700))
            case .disable:   return .pokitColor(.grayScale(._500))
            case .error:     return .pokitColor(.red(._500))
            case .info:      return .pokitColor(.blue(._700))
            case .inverseWh: return .pokitColor(.grayScale(.white))
            case .primary:   return .pokitColor(.grayScale(._900))
            case .secondary: return .pokitColor(.grayScale(._700))
            case .success:   return .pokitColor(.green(._400))
            case .tertiary:  return .pokitColor(.grayScale(._400))
            case .warning:   return .pokitColor(.yellow(._400))
            }
        /// - icon Color
        case .icon(let icon):
            switch icon {
            case .brand:     return .pokitColor(.orange(._700))
            case .disable:   return .pokitColor(.grayScale(._500))
            case .error:     return .pokitColor(.red(._500))
            case .info:      return .pokitColor(.blue(._700))
            case .inverseWh: return .pokitColor(.grayScale(.white))
            case .primary:   return .pokitColor(.grayScale(._800))
            case .secondary: return .pokitColor(.grayScale(._400))
            case .success:   return .pokitColor(.green(._400))
            case .tertiary:  return .pokitColor(.grayScale(._200))
            case .warning:   return .pokitColor(.yellow(._400))
            }
        /// - background Color
        case .bg(let bg):
            switch bg {
            case .base:      return .pokitColor(.grayScale(.white))
            case .baseIcon:  return Color(hue: 0, saturation: 0, brightness: 85, opacity: 0.6)
            case .brand:     return .pokitColor(.orange(._700))
            case .disable:   return .pokitColor(.grayScale(._200))
            case .error:     return .pokitColor(.red(._500))
            case .info:      return .pokitColor(.blue(._700))
            case .primary:   return .pokitColor(.grayScale(._50))
            case .secondary: return .pokitColor(.grayScale(._100))
            case .success:   return .pokitColor(.green(._400))
            case .tertiary:  return .pokitColor(.grayScale(._700))
            case .warning:   return .pokitColor(.yellow(._400))
            }
        /// - border Color
        case .border(let border):
            switch border {
            case .brand:     return .pokitColor(.orange(._700))
            case .disable:   return .pokitColor(.grayScale(._200))
            case .error:     return .pokitColor(.red(._500))
            case .info:      return .pokitColor(.blue(._700))
            case .inverseWh: return .pokitColor(.grayScale(.white))
            case .primary:   return .pokitColor(.grayScale(._700))
            case .secondary: return .pokitColor(.grayScale(._200))
            case .success:   return .pokitColor(.green(._400))
            case .tertiary:  return .pokitColor(.grayScale(._100))
            case .warning:   return .pokitColor(.yellow(._400))
            }
        }
    }
}
