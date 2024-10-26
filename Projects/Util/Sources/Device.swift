//
//  Device.swift
//  Util
//
//  Created by 김도형 on 10/26/24.
//

import SwiftUI

public struct Device {
#if os(iOS)
    static private let device = UIDevice.current.userInterfaceIdiom
#endif
    
    public static var isPhone: Bool {
#if os(macOS)
        return false
#endif
        return device == .phone
    }
    
    public static var isPad: Bool {
#if os(macOS)
        return false
#endif
        return device == .pad
    }
    
    public static var isMac: Bool {
#if os(macOS)
        return true
#endif
        return device == .mac
    }
    
    public static var isPortrait: Bool {
#if os(macOS)
        return false
#endif
        return UIDevice.current.orientation == .portrait
        || UIDevice.current.orientation == .portraitUpsideDown
    }
}
