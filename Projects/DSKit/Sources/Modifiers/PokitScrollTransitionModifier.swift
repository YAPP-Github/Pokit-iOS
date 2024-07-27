//
//  PokitScrollTransitionModifier.swift
//  DSKit
//
//  Created by 김도형 on 7/27/24.
//

import SwiftUI

struct PokitScrollTransitionModifier: ViewModifier {
    private let effect: ScrollTransitionEffect
    
    init(effect: ScrollTransitionEffect) {
        self.effect = effect
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            switch effect {
            case .spring(let axes):
                switch axes {
                case .horizontal:
                    content
                        .scrollTransition(.animated(.pokitSpring)) { view, transition in
                            view
                                .offset(x: transition.isIdentity ? 0 : CGFloat(transition.value * 20))
                        }
                case .vertical:
                    content
                        .scrollTransition(.animated(.pokitSpring)) { view, transition in
                            view
                                .offset(y: transition.isIdentity ? 0 : CGFloat(transition.value * 50))
                        }
                default:
                    content
                        .scrollTransition(.animated(.pokitSpring)) { view, transition in
                            view
                                .offset(y: transition.isIdentity ? 0 : CGFloat(transition.value * 50))
                        }
                }
            case .opacity:
                content
                    .scrollTransition(.animated(.pokitSpring)) { view, transition in
                        view
                            .opacity(transition.isIdentity ? 1 : 0.5)
                    }
            case .scale:
                content
                    .scrollTransition(.animated(.pokitSpring)) { view, transition in
                        view
                            .scaleEffect(transition.isIdentity ? 1 : 0.8)
                    }
            }
        } else {
            content
        }
    }
}

public enum ScrollTransitionEffect {
    case spring(Axis.Set)
    case opacity
    case scale
}

public extension View {
    func pokitScrollTransition(_ effect: ScrollTransitionEffect = .opacity) -> some View {
        modifier(PokitScrollTransitionModifier(effect: effect))
    }
}
