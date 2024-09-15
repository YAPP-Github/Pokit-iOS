//
//  Date+formatter.swift
//  Util
//
//  Created by 김민호 on 8/22/24.
//

import Foundation

public enum DateFormat: String {
    /// 포맷형식: yyyy-MM-dd
    case yearMonthDate = "yyyy.MM.dd"
    case calendarPage = "yyyy년 MM월"
    case searchCondition = "yyyy-MM-dd"
    case dateFilter = "yy.MM.dd"
}

extension DateFormat {
    public var formatter: DateFormatter {
        guard let fmt = DateFormat.cachedFormatters[self] else {
            let generatedFormatter = DateFormat.makeFormatter(withDateFormat: self)
            DateFormat.cachedFormatters[self] = generatedFormatter
            return generatedFormatter
        }
        return fmt
    }
    
    private static var cachedFormatters: [DateFormat: DateFormatter] = [:]
    
    private static func makeFormatter(withDateFormat dateFormat: DateFormat) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.rawValue
        formatter.locale = .current
        return formatter
    }
}

extension Date {
    func formattedString(dateFormat: DateFormat) -> String {
        return dateFormat.formatter.string(from: self)
    }
}
