//
//  TimerManager.swift
//  168
//
//  Created by Corwin Cheung on 3/29/25.
//

import Foundation
import CoreData
import SwiftUI

class TimerManager: ObservableObject {
    @Published var activeActivity: Activity?
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning = false
    
    private var timer: Timer?
    private var startTime: Date?
    private var accumulatedTime: TimeInterval = 0
    
    var formattedElapsedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) % 3600 / 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func startTimer(for activity: Activity) {
        // Stop any existing timer
        stopTimer()
        
        // Start new timer
        activeActivity = activity
        startTime = Date()
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateElapsedTime()
        }
    }
    
    func stopTimer() {
        guard let activity = activeActivity, let startTime = startTime else { return }
        
        // Calculate final duration
        let duration = Date().timeIntervalSince(startTime) + accumulatedTime
        
        // Save time entry
        saveTimeEntry(for: activity, duration: duration)
        
        // Reset timer state
        timer?.invalidate()
        timer = nil
        self.activeActivity = nil
        self.startTime = nil
        self.accumulatedTime = 0
        self.elapsedTime = 0
        self.isRunning = false
    }
    
    func pauseTimer() {
        guard isRunning, let startTime = startTime else { return }
        
        accumulatedTime += Date().timeIntervalSince(startTime)
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func resumeTimer() {
        guard !isRunning, activeActivity != nil else { return }
        
        startTime = Date()
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateElapsedTime()
        }
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime) + accumulatedTime
    }
    
    private func saveTimeEntry(for activity: Activity, duration: TimeInterval) {
        let context = PersistenceController.shared.container.viewContext
        
        let timeEntry = TimeEntry(context: context)
        timeEntry.id = UUID()
        timeEntry.activity = activity
        timeEntry.duration = duration
        timeEntry.date = Calendar.current.startOfDay(for: Date())
        timeEntry.startTime = startTime
        
        do {
            try context.save()
        } catch {
            print("Error saving time entry: \(error)")
        }
    }
} 