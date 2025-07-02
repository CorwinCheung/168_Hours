//
//  ContentView.swift
//  168
//
//  Created by Corwin Cheung on 3/29/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var timerManager = TimerManager()
    @State private var showingAddActivity = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimerHubView()
                .environmentObject(timerManager)
                .tabItem {
                    Image(systemName: "timer")
                    Text("Timer")
                }
                .tag(0)
            
            CalendarView()
                .environmentObject(timerManager)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(1)
            
            AnalyticsView()
                .environmentObject(timerManager)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Analytics")
                }
                .tag(2)
        }
        .accentColor(.purple)
    }
}

struct TimerHubView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var timerManager: TimerManager
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.createdAt, ascending: true)],
        animation: .default)
    private var activities: FetchedResults<Activity>
    
    @State private var showingAddActivity = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("What matters today?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Tap an activity to start tracking")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    // Active Timer Display
                    if let activeActivity = timerManager.activeActivity {
                        ActiveTimerView(activity: activeActivity)
                            .padding(.horizontal, 20)
                            .padding(.top, 30)
                    }
                    
                    // Activities List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(activities, id: \.id) { activity in
                                ActivityRowView(activity: activity)
                                    .environmentObject(timerManager)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddActivity = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView()
            }
        }
    }
}

struct ActivityRowView: View {
    let activity: Activity
    @EnvironmentObject var timerManager: TimerManager
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationLink(destination: ActivityTimerView(activity: activity, timerManager: timerManager)) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: activity.icon ?? "book")
                    .font(.title2)
                    .foregroundColor(Color.from(name: activity.color ?? "blue"))
                    .frame(width: 40, height: 40)
                    .background(Color.from(name: activity.color ?? "blue").opacity(0.1))
                    .clipShape(Circle())
                
                // Activity Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.name ?? "Unknown")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(todayDuration(for: activity))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Timer Status
                if timerManager.activeActivity?.id == activity.id {
                    Image(systemName: "pause.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func todayDuration(for activity: Activity) -> String {
        let today = Calendar.current.startOfDay(for: Date())
        let entries = activity.timeEntries?.allObjects as? [TimeEntry] ?? []
        let todayEntries = entries.filter { entry in
            guard let entryDate = entry.date else { return false }
            return Calendar.current.isDate(entryDate, inSameDayAs: today)
        }
        
        let totalSeconds = todayEntries.reduce(0) { $0 + $1.duration }
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m today"
        } else {
            return "\(minutes)m today"
        }
    }
}

struct ActiveTimerView: View {
    let activity: Activity
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: activity.icon ?? "book")
                    .font(.title)
                    .foregroundColor(Color.from(name: activity.color ?? "blue"))
                
                Text(activity.name ?? "Unknown")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                
                Spacer()
                
                Button(action: { timerManager.stopTimer() }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            
            Text(timerManager.formattedElapsedTime)
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundColor(.primary)
                .monospacedDigit()
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
