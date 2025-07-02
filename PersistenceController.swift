//
//  PersistenceController.swift
//  168
//
//  Created by Corwin Cheung on 3/29/25.
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DailyMeaningTracker")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Preview
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data
        let reading = Activity(context: viewContext)
        reading.id = UUID()
        reading.name = "Reading"
        reading.icon = "book"
        reading.color = "systemBlue"
        reading.createdAt = Date()
        
        let meditation = Activity(context: viewContext)
        meditation.id = UUID()
        meditation.name = "Meditation"
        meditation.icon = "brain.head.profile"
        meditation.color = "systemPurple"
        meditation.createdAt = Date()
        
        let walking = Activity(context: viewContext)
        walking.id = UUID()
        walking.name = "Walking"
        walking.icon = "figure.walk"
        walking.color = "systemGreen"
        walking.createdAt = Date()
        
        // Add sample time entries
        let today = Calendar.current.startOfDay(for: Date())
        
        let readingEntry = TimeEntry(context: viewContext)
        readingEntry.id = UUID()
        readingEntry.activity = reading
        readingEntry.duration = 3600 // 1 hour
        readingEntry.date = today
        readingEntry.startTime = today
        
        let meditationEntry = TimeEntry(context: viewContext)
        meditationEntry.id = UUID()
        meditationEntry.activity = meditation
        meditationEntry.duration = 1800 // 30 minutes
        meditationEntry.date = today
        meditationEntry.startTime = today
        
        // Add sample goal
        let readingGoal = Goal(context: viewContext)
        readingGoal.id = UUID()
        readingGoal.activity = reading
        readingGoal.targetHours = 5.0
        readingGoal.timeframe = "weekly"
        readingGoal.createdAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
} 