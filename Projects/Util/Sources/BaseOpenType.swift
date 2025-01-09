//
//  BaseOpenType.swift
//  Util
//
//  Created by 김민호 on 1/6/25.
//

public enum BaseOpenType: String {
    case 공개 = "PUBLIC"
    case 비공개 = "PRIVATE"
    
    var title: String { self.rawValue }
}
