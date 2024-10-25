//
//  UIDevice+Extension.swift
//  Util
//
//  Created by 김도형 on 10/24/24.
//

import SwiftUI

public extension UIDevice {
    static let device = UIDevice.current.userInterfaceIdiom
    
    static let isPhone: Bool = device == .phone
    
    static let isPad: Bool = device == .pad
    
    static let isMac: Bool = device == .mac
}
