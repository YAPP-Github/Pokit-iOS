//
//  PokitBottomSwitchRadio.swift
//  DSKit
//
//  Created by 김도형 on 7/9/24.
//

import SwiftUI

public struct PokitBottomSwitchRadio<Content: View>: View {
    @ViewBuilder private var buttons: Content
    
    public init(@ViewBuilder buttons: () -> Content) {
        self.buttons = buttons()
    }
    
    public var body: some View {
        PokitSwitchRadio {
            buttons
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
//        .padding(.bottom, 28)
        .background(.pokit(.bg(.base)))
    }
}

