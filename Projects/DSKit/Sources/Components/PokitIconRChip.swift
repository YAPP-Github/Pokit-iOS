//
//  PokitIconRChip.swift
//  DSKit
//
//  Created by 김도형 on 6/28/24.
//

import SwiftUI

public struct PokitIconRChip: View {
    private let labelText: String
    private let state: PokitButtonStyle.State
    private let size: PokitButtonStyle.Size
    private let action: (() -> Void)?
    
    public init(
        _ labelText: String,
        state: PokitButtonStyle.State,
        size: PokitButtonStyle.Size,
        action: (() -> Void)? = nil
    ) {
        self.labelText = labelText
        self.state = state
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        PokitIconRButton(
            self.labelText,
            .icon(.x),
            state: state,
            size: size, 
            shape: .round
        ) {
            action?()
        }
    }
}
