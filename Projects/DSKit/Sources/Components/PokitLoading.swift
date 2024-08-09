//
//  PokitLoading.swift
//  DSKit
//
//  Created by 김도형 on 8/9/24.
//

import SwiftUI

public struct PokitLoading: View {
    public init() {}
    
    public var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                PokitSpinner()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.pokit(.icon(.brand)))
                
                Spacer()
            }
            
            Spacer()
        }
    }
}

#Preview {
    PokitLoading()
}
