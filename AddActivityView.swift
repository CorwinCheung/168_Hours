//
//  AddActivityView.swift
//  168
//
//  Created by Corwin Cheung on 3/29/25.
//

import SwiftUI
import CoreData

struct AddActivityView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var activityName = ""
    @State private var selectedIcon = "book"
    @State private var selectedColor = "blue"
    
    private let icons = [
        "book", "brain.head.profile", "figure.walk", "pencil", "leaf", 
        "heart", "music.note", "paintbrush", "gamecontroller", "camera",
        "house", "car", "airplane", "bicycle", "dumbbell", "yoga",
        "meditation", "cooking", "cleaning", "shopping", "social"
    ]
    
    private let colors = [
        "blue", "purple", "green", "orange", "red", "pink", "indigo", "teal"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Activity Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Activity Name")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("e.g., Reading, Meditation, Walking", text: $activityName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: 16, design: .rounded))
                        }
                        
                        // Icon Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose an Icon")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(icons, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.title2)
                                            .foregroundColor(selectedIcon == icon ? .white : Color(selectedColor))
                                            .frame(width: 44, height: 44)
                                            .background(
                                                Circle()
                                                    .fill(selectedIcon == icon ? Color(selectedColor) : Color(selectedColor).opacity(0.1))
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        // Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose a Color")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                                ForEach(colors, id: \.self) { color in
                                    Button(action: { selectedColor = color }) {
                                        Circle()
                                            .fill(Color(color))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Activity")
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
                        saveActivity()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(activityName.isEmpty ? .secondary : .purple)
                    .disabled(activityName.isEmpty)
                }
            }
        }
    }
    
    private func saveActivity() {
        let activity = Activity(context: viewContext)
        activity.id = UUID()
        activity.name = activityName.trimmingCharacters(in: .whitespacesAndNewlines)
        activity.icon = selectedIcon
        activity.color = selectedColor
        activity.createdAt = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving activity: \(error)")
        }
    }
}

struct AddActivityView_Previews: PreviewProvider {
    static var previews: some View {
        AddActivityView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 