//
//  PokitCalendar.swift
//  DSKit
//
//  Created by 김도형 on 7/2/24.
//

import SwiftUI

public struct PokitCalendar: View {
    @Binding private var startDate: Date
    @Binding private var endDate: Date
    
    @State private var current: Date = .now
    
    public init(
        startDate: Binding<Date>,
        endDate: Binding<Date>
    ) {
        self._startDate = startDate
        self._endDate = endDate
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            yearMonthLabel
            
            calendar
        }
    }
    
    private var yearMonthLabel: some View {
        HStack {
            Text(yearMonth)
                .pokitFont(.b1(.b))
                .foregroundStyle(.pokit(.text(.primary)))
                .contentTransition(.numericText())
                .animation(.snappy, value: self.current)
            
            Spacer()
            
            monthButtons
        }
    }
    
    private var monthButtons: some View {
        HStack(spacing: 24) {
            beforeMonthButton
            
            nextMonthButton
        }
    }
    
    private var beforeMonthButton: some View {
        Button {
            self.beforeButtonTapped()
        } label: {
            Image(.icon(.arrowLeft))
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.pokit(.icon(.primary)))
        }
    }
    
    private var nextMonthButton: some View {
        Button {
            self.nextButtonTapped()
        } label: {
            Image(.icon(.arrowRight))
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.pokit(.icon(.primary)))
        }
    }
    
    private var calendar: some View {
        GeometryReader { proxy in
            let width = (proxy.size.width - 48) / 7
            
            VStack(spacing: 8) {
                weeks(width: width)
                
                datesOfMonth(width: width)
            }
            .animation(.snappy, value: self.current)
        }
    }
    
    private func weeks(width: CGFloat) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<7) { weekDay in
                week(self.weekdaySymbol(for: weekDay))
                    .frame(width: width, height: width)
            }
        }
    }
    
    @ViewBuilder
    private func week(_ weekDay: String) -> some View {
        Text(weekDay)
            .pokitFont(.detail1)
            .foregroundStyle(.pokit(.text(.tertiary)))
    }
    
    @ViewBuilder
    private func datesOfMonth(width: CGFloat) -> some View {
        LazyVGrid(columns: Array(repeating: .init(), count: 7), spacing: 8) {
            ForEach(previousDate, id: \.self) { date in
                dayCell(date, isCurrentMonth: false, width: width)
            }
            
            ForEach(dates, id: \.self) { date in
                dayCell(date, isCurrentMonth: true, width: width)
            }
            
            ForEach(nextDates(datesCount: previousDate.count + dates.count), id: \.self) { date in
                dayCell(date, isCurrentMonth: false, width: width)
            }
        }
    }
    
    @ViewBuilder
    private func dayCell(
        _ date: Date,
        isCurrentMonth: Bool,
        width: CGFloat
    ) -> some View {
        let isStartDate = ignoreTimeOfStartDate == date
        let isEndDate = ignoreTimeOfEndDate == date
        let isContains = (ignoreTimeOfStartDate...ignoreTimeOfEndDate).contains(date)
        let day = Calendar.current.component(.day, from: date)
        let textColor: Color = .pokit(.text(isContains ? .inverseWh : .secondary))
        let isSelected = isStartDate || isEndDate
        let backgoundColor: Color = .pokit(.bg(.brand)).opacity(isSelected ? 1 : isContains ? 0.2 : 0)
        
        Button {
            dayButtonTapped(
                date,
                isStartDate: isStartDate,
                isEndDate: isEndDate,
                isContains: isContains
            )
        } label: {
            Text("\(day)")
                .pokitFont(.b1(.m))
                .foregroundStyle(isCurrentMonth ? textColor : .pokit(.text(.tertiary)))
                .frame(width: width, height: width)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(backgoundColor)
                }
        }
    }
    
    private var dates: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        
        let year = calendar.component(.year, from: self.current)
        let month = calendar.component(.month, from: self.current)
        
        guard let range = calendar.range(of: .day, in: .month, for: self.firstDateOfMonth) else {
            return dates
        }
        
        dates = range.map { day in
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            return calendar.date(from: components) ?? .now
        }
        
        return dates
    }
    
    private var previousDate: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        
        let year = calendar.component(.year, from: self.current)
        let month = calendar.component(.month, from: self.current)
        
        let firstWeekday = calendar.component(
            .weekday,
            from: self.firstDateOfMonth
        )
        
        if firstWeekday > 1 {
            var monthDateComponents = DateComponents()
            monthDateComponents.year = year
            monthDateComponents.month = month - 1
            monthDateComponents.day = 1
            
            guard let monthDate = calendar.date(from: monthDateComponents) else {
                return dates
            }
            
            guard let monthRange = calendar.range(
                of: .day,
                in: .month,
                for: monthDate
            ) else {
                return dates
            }
            
            let monthDays = Array(monthRange).suffix(firstWeekday - 1)
            
            let monthDates = monthDays.map { day in
                var components = DateComponents()
                components.year = monthDateComponents.year
                components.month = monthDateComponents.month
                components.day = day
                return calendar.date(from: components) ?? .now
            }
            
            dates = monthDates
        }
        return dates
    }
    
    private var firstDateOfMonth: Date {
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: self.current)
        let month = calendar.component(.month, from: self.current)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: "\(year)-\(month)-\(1)") else {
            return .now
        }
        
        return date
    }
    
    private var ignoreTimeOfStartDate: Date {
        let dateComponent = Calendar.current.dateComponents(
            [.year, .month, .day, .calendar], from: self.startDate
        )
        return dateComponent.date ?? .now
    }
    
    private var ignoreTimeOfEndDate: Date {
        let dateComponent = Calendar.current.dateComponents(
            [.year, .month, .day, .calendar], from: self.endDate
        )
        return dateComponent.date ?? .now
    }
    
    private var yearMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        return formatter.string(from: self.current)
    }
    
    private func nextDates(datesCount: Int) -> [Date] {
        var dates: [Date] = []
        
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: self.current)
        let month = calendar.component(.month, from: self.current)
        
        let numberOfDays = datesCount
        
        if numberOfDays < 42 {
            let remainingDays = 42 - numberOfDays
            var monthDateComponents = DateComponents()
            monthDateComponents.year = year
            monthDateComponents.month = month + 1
            monthDateComponents.day = 1
            
            let nextMonthDates = (1...remainingDays).map { day in
                var components = DateComponents()
                components.year = monthDateComponents.year
                components.month = monthDateComponents.month
                components.day = day
                return Calendar.current.date(from: components) ?? .now
            }
            
            dates = nextMonthDates
        }
        
        return dates
    }
    
    private func dayButtonTapped(
        _ date: Date,
        isStartDate: Bool,
        isEndDate: Bool,
        isContains: Bool
    ) {
        withAnimation(.smooth) {
            guard !isStartDate else {
                self.startDate = endDate
                return
            }
            
            guard !isEndDate else {
                self.endDate = startDate
                return
            }
            
            if isContains {
                let sinceStartDate = date.timeIntervalSince(ignoreTimeOfStartDate)
                let sinceEndDate = ignoreTimeOfEndDate.timeIntervalSince(date)
                
                if sinceStartDate < sinceEndDate {
                    self.startDate = date
                } else {
                    self.endDate = date
                }
            } else {
                if date < self.ignoreTimeOfStartDate {
                    self.startDate = date
                }
                
                if date > self.ignoreTimeOfEndDate {
                    self.endDate = date
                }
            }
        }
    }
    
    private func beforeButtonTapped() {
        guard let date = Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: self.current
        ) else {
            return
        }
        self.current = date
    }
    
    private func nextButtonTapped() {
        guard let date = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: self.current
        ) else {
            return
        }
        self.current = date
    }
    
    private func weekdaySymbol(for weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.veryShortWeekdaySymbols[weekday]
    }
}

