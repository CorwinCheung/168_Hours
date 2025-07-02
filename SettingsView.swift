//
//  SettingsView.swift
//  168
//
//  Created by Corwin Cheung on 3/29/25.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.createdAt, ascending: true)],
        animation: .default)
    private var activities: FetchedResults<Activity>
    
    @State private var showingAddActivity = false
    @State private var showingAddGoal = false
    @State private var selectedActivity: Activity?
    @State private var enableReminders = false
    @State private var singleTimerMode = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Activities Management
                        activitiesSection
                        
                        // Goals Management
                        goalsSection
                        
                        // App Preferences
                        preferencesSection
                        
                        // About
                        aboutSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView()
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(activity: selectedActivity)
            }
        }
    }
    
    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Activities")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { showingAddActivity = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(activities, id: \.id) { activity in
                    ActivitySettingsRow(activity: activity)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Goals")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    selectedActivity = activities.first
                    showingAddGoal = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
                .disabled(activities.isEmpty)
            }
            
            VStack(spacing: 12) {
                ForEach(activities, id: \.id) { activity in
                    if let goal = (activity.goals as? Set<Goal>)?.first {
                        GoalSettingsRow(activity: activity, goal: goal)
                    } else {
                        EmptyGoalRow(activity: activity) {
                            selectedActivity = activity
                            showingAddGoal = true
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                Toggle("Daily Reminders", isOn: $enableReminders)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                
                Toggle("Single Timer Mode", isOn: $singleTimerMode)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                
                Divider()
                
                Button(action: exportData) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        Text("Export Data")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: resetData) {
                    HStack {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(.red)
                        
                        Text("Reset All Data")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                InfoRow(title: "Version", value: "1.0.0")
                InfoRow(title: "Build", value: "1")
                InfoRow(title: "Privacy", value: "Local Only")
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private func exportData() {
        // Placeholder for data export functionality
        print("Export data")
    }
    
    private func resetData() {
        // Placeholder for data reset functionality
        print("Reset data")
    }
}

struct ActivitySettingsRow: View {
    let activity: Activity
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingDeleteAlert = false
    
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
                
                Text("Created \(createdDateString)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { showingDeleteAlert = true }) {
                Image(systemName: "trash")
                    .font(.title3)
                    .foregroundColor(.red)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .alert("Delete Activity", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteActivity()
            }
        } message: {
            Text("Are you sure you want to delete '\(activity.name ?? "Unknown")'? This will also delete all associated time entries and goals.")
        }
    }
    
    private var createdDateString: String {
        guard let createdAt = activity.createdAt else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: createdAt)
    }
    
    private func deleteActivity() {
        viewContext.delete(activity)
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting activity: \(error)")
        }
    }
}

struct GoalSettingsRow: View {
    let activity: Activity
    let goal: Goal
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingEditGoal = false
    
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
                
                Text("\(goal.targetHours, specifier: "%.1f") hours per \(goal.timeframe ?? "week")")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { showingEditGoal = true }) {
                Image(systemName: "pencil")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingEditGoal) {
            EditGoalView(goal: goal)
        }
    }
}

struct EmptyGoalRow: View {
    let activity: Activity
    let onAddGoal: () -> Void
    
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
                
                Text("No goal set")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onAddGoal) {
                Image(systemName: "plus.circle")
                    .font(.title3)
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct AddGoalView: View {
    let activity: Activity?
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var targetHours: Double = 5.0
    @State private var timeframe = "weekly"
    
    private let timeframes = ["daily", "weekly", "monthly"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Activity Info
                    if let activity = activity {
                        HStack(spacing: 16) {
                            Image(systemName: activity.icon ?? "book")
                                .font(.title)
                                .foregroundColor(Color(activity.color ?? "blue"))
                                .frame(width: 60, height: 60)
                                .background(Color(activity.color ?? "blue").opacity(0.1))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Set Goal for")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                Text(activity.name ?? "Unknown")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                    }
                    
                    // Target Hours
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Target Hours")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Slider(value: $targetHours, in: 0.5...20, step: 0.5)
                                .accentColor(.purple)
                            
                            Text("\(targetHours, specifier: "%.1f")h")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.purple)
                                .frame(width: 60)
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    
                    // Timeframe
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Timeframe")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Picker("Timeframe", selection: $timeframe) {
                            ForEach(timeframes, id: \.self) { tf in
                                Text(tf.capitalized).tag(tf)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let activity = activity else { return }
        
        let goal = Goal(context: viewContext)
        goal.id = UUID()
        goal.activity = activity
        goal.targetHours = targetHours
        goal.timeframe = timeframe
        goal.createdAt = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving goal: \(error)")
        }
    }
}

struct EditGoalView: View {
    let goal: Goal
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var targetHours: Double
    @State private var timeframe: String
    
    private let timeframes = ["daily", "weekly", "monthly"]
    
    init(goal: Goal) {
        self.goal = goal
        self._targetHours = State(initialValue: goal.targetHours)
        self._timeframe = State(initialValue: goal.timeframe ?? "weekly")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Target Hours
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Target Hours")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Slider(value: $targetHours, in: 0.5...20, step: 0.5)
                                .accentColor(.purple)
                            
                            Text("\(targetHours, specifier: "%.1f")h")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.purple)
                                .frame(width: 60)
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    
                    // Timeframe
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Timeframe")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Picker("Timeframe", selection: $timeframe) {
                            ForEach(timeframes, id: \.self) { tf in
                                Text(tf.capitalized).tag(tf)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                }
            }
        }
    }
    
    private func saveGoal() {
        goal.targetHours = targetHours
        goal.timeframe = timeframe
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving goal: \(error)")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 