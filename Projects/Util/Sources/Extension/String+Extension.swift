//
//  String+Extension.swift
//  Util
//
//  Created by 김민호 on 8/16/24.
//

import Foundation

public extension String {
    /// 영어, 숫자, 한글로만 이루어져있는지 체크
    var isNickNameValid: Bool {
        let regex = "^[a-zA-Z0-9가-힣]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}
