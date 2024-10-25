//
//  DeviceClient+LiveKey.swift
//  CoreKit
//
//  Created by 김도형 on 10/25/24.
//

import SwiftUI

import Dependencies

extension DeviceClient: DependencyKey {
    public static let liveValue: Self = {
#if os(iOS)
        let device = UIDevice.current.userInterfaceIdiom
#endif
        
        return Self(
            isPhone: {
#if os(macOS)
                return false
#endif
                return device == .phone
            },
            isPad: {
#if os(macOS)
                return false
#endif
                return device == .pad
            },
            isMac: {
#if os(macOS)
                return true
#endif
                return false
            }
        )
    }()
}
