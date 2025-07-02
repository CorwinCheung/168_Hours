//
//  CalendarView.swift
//  168
//
//  Created by Corwin Cheung on 3/29/25.
//

import SwiftUI
import CoreData

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.createdAt, ascending: true)],
        animation: .default)
    private var activities: FetchedResults<Activity>
    
    @State private var selectedDate = Date()
    @State private var showingDayDetail = false
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Month Header
                        monthHeader
                        
                        // Calendar Grid
                        calendarGrid
                        
                        // Legend
                        legend
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingDayDetail) {
                DayDetailView(date: selectedDate)
            }
        }
    }
    
    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
        }
    }
    
    private var calendarGrid: some View {
        VStack(spacing: 8) {
            // Day headers
            HStack(spacing: 0) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: daysInWeek), spacing: 8) {
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            intensity: dayIntensity(for: date),
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                        )
                        .onTapGesture {
                            selectedDate = date
                            showingDayDetail = true
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
    }
    
    private var legend: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Spent")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                ForEach(0..<5) { level in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(intensityColor(for: Double(level) / 4.0))
                            .frame(width: 16, height: 16)
                        
                        Text(legendText(for: level))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.top, 20)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var calendarDays: [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days in the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func dayIntensity(for date: Date) -> Double {
        let entries = activities.flatMap { activity in
            activity.timeEntries?.allObjects as? [TimeEntry] ?? []
        }
        
        let dayEntries = entries.filter { entry in
            guard let entryDate = entry.date else { return false }
            return calendar.isDate(entryDate, inSameDayAs: date)
        }
        
        let totalHours = dayEntries.reduce(0) { $0 + $1.duration } / 3600
        
        // Normalize to 0-1 range (assuming 8 hours is max)
        return min(totalHours / 8.0, 1.0)
    }
    
    private func intensityColor(for intensity: Double) -> Color {
        let baseColor = Color.purple
        return baseColor.opacity(0.2 + intensity * 0.8)
    }
    
    private func legendText(for level: Int) -> String {
        let hours = level * 2
        return hours == 0 ? "0h" : "\(hours)h+"
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let intensity: Double
    let isSelected: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Circle()
                .fill(intensityColor)
                .frame(width: 40, height: 40)
            
            if isSelected {
                Circle()
                    .stroke(Color.purple, lineWidth: 2)
                    .frame(width: 40, height: 40)
            }
            
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(intensity > 0.5 ? .white : .primary)
        }
    }
    
    private var intensityColor: Color {
        let baseColor = Color.purple
        return baseColor.opacity(0.2 + intensity * 0.8)
    }
}

struct DayDetailView: View {
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var activities: FetchedResults<Activity>
    
    init(date: Date) {
        self.date = date
        self._activities = FetchRequest(
            entity: Activity.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Activity.createdAt, ascending: true)]
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Date header
                        Text(dateString)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        // Activity breakdown
                        LazyVStack(spacing: 12) {
                            ForEach(activities, id: \.id) { activity in
                                if let duration = dayDuration(for: activity) {
                                    ActivityBreakdownRow(activity: activity, duration: duration)
                                }
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Day Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func dayDuration(for activity: Activity) -> TimeInterval? {
        let entries = activity.timeEntries?.allObjects as? [TimeEntry] ?? []
        let dayEntries = entries.filter { entry in
            guard let entryDate = entry.date else { return false }
            return Calendar.current.isDate(entryDate, inSameDayAs: date)
        }
        
        let totalDuration = dayEntries.reduce(0) { $0 + $1.duration }
        return totalDuration > 0 ? totalDuration : nil
    }
}

struct ActivityBreakdownRow: View {
    let activity: Activity
    let duration: TimeInterval
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: activity.icon ?? "book")
                .font(.title2)
                .foregroundColor(Color(activity.color ?? "blue"))
                .frame(width: 40, height: 40)
                .background(Color(activity.color ?? "blue").opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name ?? "Unknown")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(formattedDuration)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 