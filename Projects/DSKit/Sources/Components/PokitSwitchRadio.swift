//
//  PokitSwitchRadio.swift
//  DSKit
//
//  Created by 김도형 on 6/28/24.
//

import SwiftUI

public struct PokitSwitchRadio<Content: View>: View {
    @ViewBuilder private var buttons: Content
    
    public init(@ViewBuilder buttons: () -> Content) {
        self.buttons = buttons()
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            buttons
        }
    }
}
