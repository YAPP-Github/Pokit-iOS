//
//  DeeplinkActor.swift
//  CoreKit
//
//  Created by 김도형 on 2/17/26.
//

import Foundation

@globalActor
public struct DeeplinkActor {
    public actor ActorType {}
    public static let shared = ActorType()
}
