//
//  NickNameSettingView.swift
//  Feature
//
//  Created by 김민호 on 7/22/24.

import ComposableArchitecture
import SwiftUI

@ViewAction(for: NickNameSettingFeature.self)
public struct NickNameSettingView: View {
    /// - Properties
    public var store: StoreOf<NickNameSettingFeature>
    
    /// - Initializer
    public init(store: StoreOf<NickNameSettingFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension NickNameSettingView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Hello World!")
            }
        }
    }
}
//MARK: - Configure View
private extension NickNameSettingView {
    
}
//MARK: - Preview
#Preview {
    NickNameSettingView(
        store: Store(
            initialState: .init(),
            reducer: { NickNameSettingFeature() }
        )
    )
}


