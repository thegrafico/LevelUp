//
//  UserProgressSheet.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/6/25.
//

import SwiftUI
import Charts

struct UserProgressSheet: View {
    @Environment(\.theme) private var theme
    @Environment(\.currentUser) private var user
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate: Date = Date()
    @State private var showingCalendarPicker: Bool = false
    
    
    @State private var selectedEvent: ProgressEvent? = nil
    
    @State private var isChartInteracting = false
    
    
    private let calendar = Calendar.current
    
    // MARK: Computed
    private var events: [ProgressEvent] {
        user.events(on: selectedDate).filter { $0.type == .completedMission }
    }
    
    private var xpForSelectedDay: Double {
        Double(events.reduce(0) { $0 + ($1.missionXP ?? 0) })
    }
    
    private var labelForSelectedDate: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Stacks for Today"
        } else {
            return "Stacks for \(selectedDate.formatted(.dateTime.day().month(.wide)))"
        }
    }
    
    
    private var xpForSelectedWeek: Double {
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate)!
        let weekLogs = user.progressLogs.filter { weekInterval.contains($0.date) }
        let completedEvents = weekLogs.flatMap { $0.events }
            .filter { $0.type == .completedMission }
        return Double(completedEvents.reduce(0) { $0 + ($1.missionXP ?? 0) })
    }
    
    // MARK: Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                dateSelector
                    .padding(.bottom, -20) // pull it closer to the summary card
                
                xpSummaryCarousel
                progressGraphs
                activityList
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        }
        .background(theme.background.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(theme.primary)
            }
        }
    }
}

// MARK: - HEADER
extension UserProgressSheet {
    private var header: some View {
        VStack(spacing: 6) {
            Text("Your Daily Progress")
                .font(.title2.weight(.bold))
                .foregroundStyle(theme.textPrimary)
            Text("See how your XP stacks up this week")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
        }
        .padding(.top, 10)
    }
}

// MARK: - DATE SELECTOR
extension UserProgressSheet {
    private var dateSelector: some View {
        let days = (-7...2).compactMap {
            calendar.date(byAdding: .day, value: $0, to: .now)
        }
        let today = calendar.startOfDay(for: .now)
        
        let visibleRange = days.map { calendar.startOfDay(for: $0) }
        let selectedDayStart = calendar.startOfDay(for: selectedDate)
        let isSelectedOutsideRange = !visibleRange.contains(selectedDayStart)
        
        return VStack(spacing: 8) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // 🗓️ Calendar button (same as before)
                        Button {
                            showingCalendarPicker.toggle()
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(isSelectedOutsideRange ? .white : theme.primary)
                                Text("Pick")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(isSelectedOutsideRange ? .white : theme.textPrimary)
                            }
                            .frame(width: 52, height: 60)
                            .background(isSelectedOutsideRange ? theme.primary : theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(
                                color: isSelectedOutsideRange ? theme.primary.opacity(0.4) : theme.shadowLight,
                                radius: 6,
                                y: 3
                            )
                            .scaleEffect(isSelectedOutsideRange ? 1.1 : 1.0)
                            .animation(.spring(response: 0.4), value: isSelectedOutsideRange)
                        }
                        
                        // 📅 Day chips
                        ForEach(days, id: \.self) { day in
                            let dayStart = calendar.startOfDay(for: day)
                            let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                            let isToday = calendar.isDateInToday(day)
                            let isFuture = dayStart > today && !isToday
                            
                            VStack(spacing: 4) {
                                Text(day, format: .dateTime.weekday(.abbreviated))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(
                                        isSelected ? .white :
                                            isToday ? theme.primary : theme.textPrimary
                                    )
                                Text(day, format: .dateTime.day())
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(
                                        isSelected ? .white :
                                            isToday ? theme.primary : theme.textPrimary
                                    )
                            }
                            .frame(width: 52, height: 60)
                            .background(
                                Group {
                                    if isSelected {
                                        theme.primary
                                    } else if isToday {
                                        theme.primary.opacity(0.12) // subtle “today” highlight
                                    } else {
                                        theme.cardBackground
                                    }
                                }
                            )
                            .overlay(
                                Group {
                                    if isToday && !isSelected {
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(theme.primary, lineWidth: 1.5)
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: isSelected ? theme.primary.opacity(0.4) : .clear, radius: 6, y: 3)
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                            .opacity(isFuture ? 0.4 : 1.0)
                            .onTapGesture {
                                if !isFuture {
                                    withAnimation(.spring(response: 0.4)) {
                                        selectedDate = day
                                        proxy.scrollTo(day, anchor: .center)
                                    }
                                }
                            }
                            .id(day)
                            .animation(.spring(response: 0.4), value: selectedDate)
                            .allowsHitTesting(!isFuture)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
                }
                .task {
                    if let todayMatch = days.first(where: { calendar.isDateInToday($0) }) {
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        withAnimation(.easeOut(duration: 0.6)) {
                            proxy.scrollTo(todayMatch, anchor: .center)
                        }
                    }
                }
            }
            
            // 💬 Center text below the picker
            Text(labelForSelectedDate)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .scale))
                .animation(.easeInOut(duration: 0.3), value: selectedDate)
        }
        .sheet(isPresented: $showingCalendarPicker) {
            VStack {
                
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(theme.primary)
                    .padding()
                
                Button("Done") {
                    showingCalendarPicker = false
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.primary)
                .padding(.bottom, 20)
            }
            .presentationDetents([.medium])
            .background(theme.background.ignoresSafeArea())
        }
    }
}

// MARK: - SUMMARY
extension UserProgressSheet {
    private var dailySummary: some View {
        VStack(spacing: 14) {
            HStack {
                Text("XP Gained")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Text("\(Int(xpForSelectedDay)) XP")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(theme.primary)
            }
            
            ProgressView(value: xpForSelectedDay, total: User.LIMIT_POINTS_PER_DAY)
                .progressViewStyle(ThickLinearProgressStyle(height: 10))
            
            HStack {
                Text("Completed \(events.count) mission\(events.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                Spacer()
            }
        }
        .padding()
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
        .shadow(color: theme.shadowLight, radius: 4, y: 2)
    }
}

// MARK: - MULTI-GRAPH VIEW
extension UserProgressSheet {
    private var progressGraphs: some View {
        TabView {
            missionTimeline
                .tag(0)
            
            missionTypeHistogram
                .tag(1)
            
            weeklyXPTrend
                .tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .frame(height: 260)
        .padding(.top, 10)
    }
}


// MARK: - TIMELINE GRAPH
extension UserProgressSheet {
    private var missionTimeline: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Completion Timeline")
                .font(.headline.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
                .padding(.bottom, 4)
            
            if events.isEmpty {
                Text("No missions completed on this day.")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                let sortedEvents = events.sorted {
                    guard
                        let t1 = $0.missionCompletionTime,
                        let t2 = $1.missionCompletionTime
                    else { return false }
                    return t1 < t2
                }
                
                ZStack(alignment: .bottomLeading) {
                    Chart(sortedEvents, id: \.id) { event in
                        if let time = event.missionCompletionTime {
                            LineMark(
                                x: .value("Time", time),
                                y: .value("XP", event.missionXP ?? 0)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(theme.primary.gradient)
                            
                            PointMark(
                                x: .value("Time", time),
                                y: .value("XP", event.missionXP ?? 0)
                            )
                            .symbol(.circle)
                            .foregroundStyle(theme.primary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartPlotStyle { plot in
                        plot
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                    }
                    .chartXScale(domain: paddedDomain(for: sortedEvents))
                    .chartOverlay { proxy in
                        GeometryReader { _ in
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .allowsHitTesting(isChartInteracting)
                                .gesture(
                                    LongPressGesture(minimumDuration: 0.15)
                                        .onChanged { _ in isChartInteracting = true }
                                        .sequenced(before: DragGesture(minimumDistance: 0))
                                        .onChanged { value in
                                            switch value {
                                            case .second(true, let drag?):
                                                if let date: Date = proxy.value(atX: drag.location.x) {
                                                    let nearest = sortedEvents.min(by: {
                                                        abs(($0.missionCompletionTime ?? .distantPast)
                                                            .timeIntervalSince(date)) <
                                                                abs(($1.missionCompletionTime ?? .distantPast)
                                                                    .timeIntervalSince(date))
                                                    })
                                                    selectedEvent = nearest
                                                }
                                            default: break
                                            }
                                        }
                                        .onEnded { _ in
                                            isChartInteracting = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                selectedEvent = nil
                                            }
                                        }
                                )
                            
                            // 💬 Tooltip
                            if let event = selectedEvent,
                               let time = event.missionCompletionTime,
                               let positionX = proxy.position(forX: time) {
                                Text("\(time.formatted(date: .omitted, time: .shortened))  +\(event.missionXP ?? 0) XP")
                                    .font(.caption2.weight(.semibold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(theme.primary.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .position(x: positionX, y: 26)
                            }
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: theme.shadowLight, radius: 4, y: 2)
                    
                    // 👇 Add tiny axis labels INSIDE the card bounds
                    VStack(alignment: .leading, spacing: 2) {
                        Text("XP")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundStyle(theme.textSecondary.opacity(0.5))
                            .rotationEffect(.degrees(-90))
                            .offset(x: 10, y: -30)
                    }
                    
                    Text("Time")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(theme.textSecondary.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
    
    
    private var missionTypeHistogram: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mission Type Comparison")
                .font(.headline.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
                .padding(.bottom, 4)
            
            if events.isEmpty {
                Text("No missions completed on this day.")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                let grouped = Dictionary(grouping: events) { $0.missionType ?? "Unknown" }
                let data = grouped.map { (type, missions) in
                    (type, missions.count)
                }
                ZStack(alignment: .bottomLeading) {
                    // your current Chart code here
                    Chart(data, id: \.0) { type, count in
                        BarMark(
                            x: .value("Mission Type", type),
                            y: .value("Completed", count)
                        )
                        .foregroundStyle(
                            type == "Global"
                            ? theme.textSecondary.opacity(0.5)
                            : theme.primary.opacity(0.8)
                        )
                        .cornerRadius(6)
                        .annotation(position: .top) {
                            Text("\(count)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(theme.textPrimary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisValueLabel()
                                .font(.caption.weight(.medium))
                        }
                    }
                    .frame(height: 180)
                    .padding()
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: theme.shadowLight, radius: 4, y: 2)
                    
                    VStack(alignment: .leading) {
                        Text("Count")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundStyle(theme.textSecondary.opacity(0.5))
                            .rotationEffect(.degrees(-90))
                            .offset(x: -3, y: -25)
                    }
                        
                }
            }
        }
    }
    
    private var weeklyXPTrend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("XP Trend This Week")
                .font(.headline.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
                .padding(.bottom, 4)
            
            let weekStart = calendar.date(byAdding: .day, value: -6, to: selectedDate) ?? .now
            let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
            
            let weeklyData: [(Date, Double)] = days.map { day in
                let dailyXP = user.events(on: day)
                    .filter { $0.type == .completedMission }
                    .reduce(0) { $0 + Double($1.missionXP ?? 0) }
                return (day, dailyXP)
            }
            ZStack(alignment: .bottomLeading) {
                
                Chart(weeklyData, id: \.0) { date, xp in
                    LineMark(
                        x: .value("Date", date),
                        y: .value("XP", xp)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(theme.primary.gradient)
                    
                    AreaMark(
                        x: .value("Date", date),
                        y: .value("XP", xp)
                    )
                    .foregroundStyle(theme.primary.opacity(0.15))
                }
                .chartXAxis {
                    AxisMarks(values: days) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            .font(.caption2)
                            .foregroundStyle(theme.textSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 180)
                .padding()
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: theme.shadowLight, radius: 4, y: 2)
                
                // 👇 Add tiny axis labels INSIDE the card bounds
                VStack(alignment: .leading, spacing: 2) {
                    Text("XP")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(theme.textSecondary.opacity(0.5))
                        .rotationEffect(.degrees(-90))
                        .offset(x: 10, y: -30)
                }
            }
        }
    }
    
    /// Expands time range slightly to avoid clipping
    private func paddedDomain(for events: [ProgressEvent]) -> ClosedRange<Date> {
        let times = events.compactMap { $0.missionCompletionTime }.sorted()
        guard let minTime = times.first, let maxTime = times.last else {
            let now = Date()
            return now.addingTimeInterval(-1800)...now.addingTimeInterval(1800)
        }
        
        let span = maxTime.timeIntervalSince(minTime)
        let pad = max(span * 0.15, 300) // 15% or 5 minutes minimum
        return minTime.addingTimeInterval(-pad)...maxTime.addingTimeInterval(pad)
    }
    
    /// Returns up to 3 timestamps: first, middle, last
    private func xAxisValues(for events: [ProgressEvent]) -> [Date] {
        let times = events.compactMap { $0.missionCompletionTime }.sorted()
        guard !times.isEmpty else { return [] }
        
        switch times.count {
        case 1...3:
            return times
        default:
            let first = times.first!
            let middle = times[times.count / 2]
            let last = times.last!
            return [first, middle, last]
        }
    }
}

// MARK: - ACTIVITY LIST
extension UserProgressSheet {
    private var activityList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Completed Missions")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                // ✅ Total count
                if !events.isEmpty {
                    Text("\(events.count) total")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }
            }
            if events.isEmpty {
                Text("Nothing completed yet.")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                PaginatedListView(
                    items: events.sorted {
                        ($0.missionCompletionTime ?? .distantPast) >
                        ($1.missionCompletionTime ?? .distantPast)
                    },
                    pageSize: 10
                ) { event in
                    HStack(spacing: 12) {
                        // 🌍 Use globe for global missions, checkmark for custom
                        Image(systemName: event.missionType == "Global" ? "globe.americas.fill" : "checkmark.circle.fill")
                            .foregroundStyle(
                                event.missionType == "Global"
                                ? theme.textSecondary // bright for globals
                                : theme.primary
                            )
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(event.missionTitle ?? "Unknown mission")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.textPrimary)
                            
                            if let time = event.missionCompletionTime {
                                Text(time.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(theme.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        Text("+\(event.missionXP ?? 0) XP")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(theme.primary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                }
                
            }
        }
        .padding()
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
        .shadow(color: theme.shadowLight, radius: 4, y: 2)
    }
}

// MARK: - XP CAROUSEL
extension UserProgressSheet {
    private var xpSummaryCarousel: some View {
        TabView {
            // 🟢 XP for Selected Day
            xpSummaryCard(
                title: calendar.isDateInToday(selectedDate) ? "XP Today" : "XP on \(selectedDate.formatted(.dateTime.day().month(.abbreviated)))",
                value: xpForSelectedDay,
                total: User.LIMIT_POINTS_PER_DAY,
                subtitle: "\(Int(xpForSelectedDay)) / \(Int(User.LIMIT_POINTS_PER_DAY)) XP"
            )
            
            // 🔵 XP for Selected Week
            xpSummaryCard(
                title: "XP This Week",
                value: xpForSelectedWeek,
                total: User.LIMIT_POINTS_PER_DAY * 7,
                subtitle: "\(Int(xpForSelectedWeek)) XP this week"
            )
            
            // 🟣 Total XP Overall
            xpSummaryCard(
                title: "Total XP Earned",
                value: user.xpGainedTotal,
                total: Double(user.level * 100), // can be arbitrary or tied to your leveling formula
                subtitle: "\(Int(user.xpGainedTotal)) total XP"
            )
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .frame(height: 160)
    }
    
    private func xpSummaryCard(title: String, value: Double, total: Double, subtitle: String) -> some View {
        let safeValue = value.clamped(to: 0...total)
        
        return VStack(spacing: 14) {
            HStack {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Text("\(Int(value)) XP")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(theme.primary)
            }
            
            ProgressView(value: safeValue, total: total)
                .progressViewStyle(ThickLinearProgressStyle(height: 10))
            
            HStack {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                Spacer()
            }
        }
        .padding()
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
        .shadow(color: theme.shadowLight, radius: 4, y: 2)
        .padding(.horizontal, 4)
    }
}

extension Double {
    /// Ensures the value stays within the provided range.
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

/// Generic reusable paginated list view
struct PaginatedListView<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let pageSize: Int
    @ViewBuilder let content: (Item) -> Content
    
    @State private var currentPage: Int = 0
    
    private var totalPages: Int {
        max(1, Int(ceil(Double(items.count) / Double(pageSize))))
    }
    
    private var paginatedItems: [Item] {
        let start = currentPage * pageSize
        let end = min(start + pageSize, items.count)
        return Array(items[start..<end])
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(paginatedItems) { item in
                content(item)
            }
            
            // 🔹 Pagination Controls
            HStack(spacing: 16) {
                Button {
                    withAnimation { currentPage = max(currentPage - 1, 0) }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(currentPage > 0 ? Color.primary : Color.gray)
                }
                .disabled(currentPage == 0)
                
                Text("Page \(currentPage + 1) of \(totalPages)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Button {
                    withAnimation { currentPage = min(currentPage + 1, totalPages - 1) }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundStyle(currentPage < totalPages - 1 ? Color.primary : Color.gray)
                }
                .disabled(currentPage >= totalPages - 1)
            }
            .padding(.top, 6)
        }
    }
}


#Preview {
    UserProgressSheet()
        .modelContainer(SampleData.shared.modelContainer)
        .environment(BadgeManager())
        .environment(\.currentUser, User.sampleUserWithLogs())
}
