//
//  Array+Sortable.swift
//  Util
//
//  Created by 김민호 on 8/22/24.
//

import Foundation

extension Array where Element: Sortable {
    /// createdAt을 이용해 최신순 정렬을 도와주는 함수
    public mutating func sortByDate(dateFormat: DateFormat = .yearMonthDate) {
        return self.sort { first, second in
            guard let firstDate = dateFormat.formatter.date(from: first.createdAt),
                  let secondDate = dateFormat.formatter.date(from: second.createdAt) else { return false }
            return firstDate > secondDate
        }
    }
}
