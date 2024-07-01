//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.

import ComposableArchitecture
import SwiftUI

public struct ___VARIABLE_sceneName___View: View {
    /// - Properties
    private let store: StoreOf<___VARIABLE_sceneName___Feature>
    /// - Initializer
    public init(store: StoreOf<___VARIABLE_sceneName___Feature>) {
        self.store = store
    }
}
//MARK: - View
public extension ___VARIABLE_sceneName___View {
    var body: some View {
        VStack {
            Text("Hello World!")
        }
    }
}
//MARK: - Configure View
extension ___VARIABLE_sceneName___View {
    
}
//MARK: - Preview
#Preview {
    ___VARIABLE_sceneName___View(
        store: Store(
            initialState: .init(),
            reducer: { ___VARIABLE_sceneName___Feature() }
        )
    )
}


