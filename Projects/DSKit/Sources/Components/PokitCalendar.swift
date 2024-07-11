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
    
    @State private var page: String
    @State private var months: [Date] = []
    @State private var isLastMonth: Bool = true
    @State private var isFirstMonth: Bool = false
    
    private let calendar = Calendar.current
    
    public init(
        startDate: Binding<Date>,
        endDate: Binding<Date>
    ) {
        self._startDate = startDate
        self._endDate = endDate
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        self._page = State(initialValue: formatter.string(from: .now))
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            yearMonthLabel
            
            calendarGrid
        }
        .onAppear {
            onAppeared()
        }
    }
    
    private var yearMonthLabel: some View {
        HStack {
            Text(page)
                .pokitFont(.b1(.b))
                .foregroundStyle(.pokit(.text(.primary)))
                .contentTransition(.numericText())
                .animation(.spring(bounce: 0.3), value: self.page)
            
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
                .foregroundStyle(.pokit(.icon(isFirstMonth ? .disable : .primary)))
        }
        .disabled(isFirstMonth)
    }
    
    private var nextMonthButton: some View {
        Button {
            self.nextButtonTapped()
        } label: {
            Image(.icon(.arrowRight))
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.pokit(.icon(isLastMonth ? .disable : .primary)))
        }
        .disabled(isLastMonth)
    }
    
    private var calendarGrid: some View {
        GeometryReader { proxy in
            let width = (proxy.size.width - 48) / 7
            
            VStack(spacing: 8) {
                weeks(width: width)
                
                datesOfMonth(width: width)
            }
            .animation(.smooth, value: self.page)
            .frame(height: proxy.size.width)
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
        TabView(selection: self.$page) {
            ForEach(self.months, id: \.self) { date in
                let page = pageFormatter.string(from: date)
                
                dateGrid(date, width: width)
                    .tag(page)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: page) { onChangedPage($0) }
    }
    
    @ViewBuilder
    private func dateGrid(_ date: Date, width: CGFloat) -> some View {
        let previousDate = previousDate(date)
        let dates = dates(date)
        
        LazyVGrid(columns: Array(repeating: .init(), count: 7), spacing: 8) {
            ForEach(previousDate, id: \.self) { date in
                dayCell(date, isCurrentMonth: false, width: width)
            }
            
            ForEach(dates, id: \.self) { date in
                dayCell(date, isCurrentMonth: true, width: width)
            }
            
            ForEach(nextDates(date, datesCount: previousDate.count + dates.count), id: \.self) { date in
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
        let ignoreTimeOfStartDate = ignoreTime(self.startDate)
        let ignoreTimeOfEndDate = ignoreTime(self.endDate)
        let isStartDate = ignoreTimeOfStartDate == date
        let isEndDate = ignoreTimeOfEndDate == date
        let isContains = (ignoreTimeOfStartDate...ignoreTimeOfEndDate).contains(date)
        let textColor: Color = .pokit(.text(isContains ? .inverseWh : .secondary))
        let isSelected = isStartDate || isEndDate
        let backgoundColor: Color = .pokit(.bg(.brand)).opacity(isSelected ? 1 : isContains ? 0.2 : 0)
        let day = calendar.component(.day, from: date)
        
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
    
    private func dates(_ date: Date) -> [Date] {
        var dates: [Date] = []
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        guard let range = calendar.range(
            of: .day,
            in: .month,
            for: date
        ) else {
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
    
    private func previousDate(_ date: Date) -> [Date] {
        var dates: [Date] = []
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        let firstWeekday = calendar.component(
            .weekday,
            from: firstDateOfMonth(date)
        )
        
        guard firstWeekday > 1 else { return dates }
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month - 1
        dateComponents.day = 1
        
        guard let monthDate = calendar.date(from: dateComponents) else {
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
            components.year = dateComponents.year
            components.month = dateComponents.month
            components.day = day
            return calendar.date(from: components) ?? .now
        }
        
        dates = monthDates
        
        return dates
    }
    
    private func nextDates(_ date: Date, datesCount: Int) -> [Date] {
        var dates: [Date] = []
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        let numberOfDays = datesCount
        
        if numberOfDays < 42 {
            let remainingDays = 42 - numberOfDays
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month + 1
            dateComponents.day = 1
            
            let nextMonthDates = (1...remainingDays).map { day in
                var components = DateComponents()
                components.year = dateComponents.year
                components.month = dateComponents.month
                components.day = day
                return calendar.date(from: components) ?? .now
            }
            
            dates = nextMonthDates
        }
        
        return dates
    }
    
    private func ignoreTime(_ date: Date) -> Date {
        let dateComponent = calendar.dateComponents(
            [.year, .month, .day, .calendar], from: date
        )
        return dateComponent.date ?? .now
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
            
            let ignoreTimeOfStartDate = ignoreTime(self.startDate)
            let ignoreTimeOfEndDate = ignoreTime(self.endDate)
            
            if isContains {
                let sinceStartDate = date.timeIntervalSince(ignoreTimeOfStartDate)
                let sinceEndDate = ignoreTimeOfEndDate.timeIntervalSince(date)
                
                if sinceStartDate < sinceEndDate {
                    self.startDate = date
                } else {
                    self.endDate = date
                }
            } else {
                if date < ignoreTimeOfStartDate {
                    self.startDate = date
                }
                
                if date > ignoreTimeOfEndDate {
                    self.endDate = date
                }
            }
        }
    }
    
    private func beforeButtonTapped() {
        guard let date = calendar.date(
            byAdding: .month,
            value: -1,
            to: currentDate
        ) else {
            return
        }
        
        self.page = pageFormatter.string(from: date)
    }
    
    private func nextButtonTapped() {
        guard let date = calendar.date(
            byAdding: .month,
            value: 1,
            to: currentDate
        ) else {
            return
        }
        
        self.page = pageFormatter.string(from: date)
    }
    
    private func weekdaySymbol(for weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.veryShortWeekdaySymbols[weekday]
    }
    
    private var pageFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        return formatter
    }
    
    private var currentDate: Date {
        guard let currentDate = pageFormatter.date(from: self.page) else {
            return .now
        }
        
        return currentDate
    }
    
    private func firstDateOfMonth(_ date: Date) -> Date {
        var dateComponent = calendar.dateComponents([.year, .month], from: date)
        dateComponent.setValue(1, for: .day)
        
        guard let date = calendar.date(from: dateComponent) else {
            return .now
        }
        
        return date
    }
    
    private func onAppeared() {
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        
        var monthList: [Date] = []
        let yearRange = -(year - 2000)...0
        
        for yearValue in yearRange {
            if let yearDate = calendar.date(
                byAdding: .year,
                value: yearValue,
                to: .now
            ) {
                let isCurrentYear = yearValue == 0
                let range = isCurrentYear ? (-month + 1)...0 : (-month + 1)...(12 - month)
                
                for value in range {
                    if let date = calendar.date(
                        byAdding: .month,
                        value: value,
                        to: yearDate
                    ) {
                        monthList.append(date)
                    }
                }
            }
        }
        
        self.months = monthList
    }
    
    private func onChangedPage(_ newValue: String) {
        withAnimation {
            if let dateOfLastMonth = months.last {
                let lastMonthPage = pageFormatter.string(from: dateOfLastMonth)
                self.isLastMonth = newValue == lastMonthPage
            }
            
            if let dateOfFirstMonth = months.first {
                let firstMonthPage = pageFormatter.string(from: dateOfFirstMonth)
                self.isFirstMonth = newValue == firstMonthPage
            }
        }
        
    }
}

