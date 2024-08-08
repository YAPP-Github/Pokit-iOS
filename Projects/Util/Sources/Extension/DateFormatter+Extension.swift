//
//  DateFormatter+Extension.swift
//  Util
//
//  Created by 김도형 on 8/5/24.
//

import Foundation

public extension DateFormatter {
    static func stringToDate(string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        guard let date = formatter.date(from: string) else { return .now }
        return date
    }
    
    static func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}
