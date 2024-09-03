//
//  PokitNavigationBarModifier.swift
//  DSKit
//
//  Created by 김도형 on 7/7/24.
//

import SwiftUI

struct PokitNavigationBarModifier<Header: View>: ViewModifier {
    @ViewBuilder
    private var header: Header
    
    init(@ViewBuilder header: () -> Header) {
        self.header = header()
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            header
            
            content
        }
        .navigationBarBackButtonHidden()
        .background(.pokit(.bg(.base)))
    }
}


public extension View {
    func pokitNavigationBar<Header: View>(@ViewBuilder header: () -> Header) -> some View {
        modifier(PokitNavigationBarModifier(header: header))
    }
}
