//
//  AnalyticsView.swift
//  168
//
//  Created by Corwin Cheung on 3/29/25.
//

import SwiftUI
import CoreData

struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.createdAt, ascending: true)],
        animation: .default)
    private var activities: FetchedResults<Activity>
    
    @State private var selectedTimeframe: Timeframe = .week
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Timeframe Selector
                        timeframeSelector
                        
                        // Summary Cards
                        summaryCards
                        
                        // Activity Breakdown Chart
                        activityBreakdownChart
                        
                        // Goals Progress
                        goalsProgress
                        
                        // Consistency Insights
                        consistencyInsights
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var timeframeSelector: some View {
        Picker("Timeframe", selection: $selectedTimeframe) {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var summaryCards: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            SummaryCard(
                title: "Total Time",
                value: totalTimeString,
                icon: "clock",
                color: .purple
            )
            
            SummaryCard(
                title: "Activities",
                value: "\(activeActivitiesCount)",
                icon: "list.bullet",
                color: .blue
            )
            
            SummaryCard(
                title: "Best Day",
                value: bestDayString,
                icon: "star",
                color: .orange
            )
            
            SummaryCard(
                title: "Streak",
                value: "\(currentStreak) days",
                icon: "flame",
                color: .red
            )
        }
    }
    
    private var activityBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Breakdown")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(activities, id: \.id) { activity in
                    if let duration = timeframeDuration(for: activity) {
                        ActivityChartRow(
                            activity: activity,
                            duration: duration,
                            totalDuration: totalTimeframeDuration
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var goalsProgress: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goals Progress")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                ForEach(activities, id: \.id) { activity in
                    if let goal = (activity.goals as? Set<Goal>)?.first {
                        GoalProgressRow(activity: activity, goal: goal)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var consistencyInsights: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Consistency Insights")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                InsightRow(
                    icon: "calendar",
                    title: "Most Active Day",
                    value: mostActiveDay,
                    color: .green
                )
                
                InsightRow(
                    icon: "clock.arrow.circlepath",
                    title: "Average Daily Time",
                    value: averageDailyTime,
                    color: .blue
                )
                
                InsightRow(
                    icon: "target",
                    title: "Goal Completion",
                    value: goalCompletionRate,
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Computed Properties
    
    private var totalTimeString: String {
        let totalHours = totalTimeframeDuration / 3600
        let hours = Int(totalHours)
        let minutes = Int((totalHours.truncatingRemainder(dividingBy: 1)) * 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private var activeActivitiesCount: Int {
        activities.filter { activity in
            timeframeDuration(for: activity) ?? 0 > 0
        }.count
    }
    
    private var bestDayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: bestDay)
    }
    
    private var currentStreak: Int {
        // Simplified streak calculation
        return 5 // Placeholder
    }
    
    private var totalTimeframeDuration: TimeInterval {
        activities.reduce(0) { total, activity in
            total + (timeframeDuration(for: activity) ?? 0)
        }
    }
    
    private var mostActiveDay: String {
        "Wednesday" // Placeholder
    }
    
    private var averageDailyTime: String {
        let avgHours = (totalTimeframeDuration / 3600) / Double(selectedTimeframe == .week ? 7 : 30)
        return String(format: "%.1fh", avgHours)
    }
    
    private var goalCompletionRate: String {
        "75%" // Placeholder
    }
    
    private var bestDay: Date {
        Date() // Placeholder
    }
    
    private func timeframeDuration(for activity: Activity) -> TimeInterval? {
        let entries = activity.timeEntries?.allObjects as? [TimeEntry] ?? []
        let now = Date()
        
        let startDate: Date
        if selectedTimeframe == .week {
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        } else {
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        }
        
        let timeframeEntries = entries.filter { entry in
            guard let entryDate = entry.date else { return false }
            return entryDate >= startDate && entryDate <= now
        }
        
        let totalDuration = timeframeEntries.reduce(0) { $0 + $1.duration }
        return totalDuration > 0 ? totalDuration : nil
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct ActivityChartRow: View {
    let activity: Activity
    let duration: TimeInterval
    let totalDuration: TimeInterval
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.icon ?? "book")
                .font(.title3)
                .foregroundColor(Color(activity.color ?? "blue"))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name ?? "Unknown")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(formattedDuration)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(percentage))%")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
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
    
    private var percentage: Double {
        guard totalDuration > 0 else { return 0 }
        return (duration / totalDuration) * 100
    }
}

struct GoalProgressRow: View {
    let activity: Activity
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: activity.icon ?? "book")
                    .font(.title3)
                    .foregroundColor(Color(activity.color ?? "blue"))
                
                Text(activity.name ?? "Unknown")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(progressPercentage))%")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progressPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(activity.color ?? "blue")))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(.vertical, 8)
    }
    
    private var progressPercentage: Double {
        // Simplified progress calculation
        return 75.0 // Placeholder
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 