//
//  AddActivityView.swift
//  168
//
//  Created by Corwin Cheung on 3/29/25.
//

import SwiftUI
import CoreData

extension Color {
    init(colorName: String) {
        switch colorName {
        case "systemBlue":
            self = .blue
        case "systemPurple":
            self = .purple
        case "systemGreen":
            self = .green
        case "systemOrange":
            self = .orange
        case "systemRed":
            self = .red
        case "systemPink":
            self = .pink
        case "systemIndigo":
            self = .indigo
        case "systemTeal":
            self = .teal
        case "systemMint":
            self = .mint
        case "systemCyan":
            self = .cyan
        default:
            self = .blue // fallback
        }
    }
}

struct AddActivityView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var activityName = ""
    @State private var selectedIcon = "book"
    @State private var selectedColor = "systemBlue"
    
    private let icons = [
        "book",                              // reading
        "chevron.left.slash.chevron.right",  // coding
        "pencil"                             // writing
    ]
    
    private let colors: [(name: String, color: Color)] = [
        ("systemBlue", .blue),
        ("systemPurple", .purple),
        ("systemGreen", .green),
        ("systemOrange", .orange),
        ("systemRed", .red),
        ("systemPink", .pink),
        ("systemIndigo", .indigo),
        ("systemTeal", .teal),
        ("systemMint", .mint),
        ("systemCyan", .cyan)
    ]
    
    private var selectedColorValue: Color {
        colors.first { $0.name == selectedColor }?.color ?? .blue
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Header with context
                        VStack(spacing: 8) {
                            Text("Create New Activity")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Track what matters most to you")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Activity Name Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Activity Name")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("e.g., Reading, Meditation, Walking", text: $activityName)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 16, design: .rounded))
                                .padding(16)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                        
                        // Icon Selection Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Choose an Icon")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 24) {
                                ForEach(icons, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedIcon == icon ? .white : selectedColorValue)
                                            .frame(width: 56, height: 56)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(selectedIcon == icon ? selectedColorValue : selectedColorValue.opacity(0.1))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedIcon == icon ? selectedColorValue : Color.clear, lineWidth: 2)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                Spacer()
                            }
                        }
                        
                        // Color Selection Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Choose a Color")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 5), spacing: 16) {
                                ForEach(colors, id: \.name) { colorItem in
                                    Button(action: { selectedColor = colorItem.name }) {
                                        Circle()
                                            .fill(colorItem.color)
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: selectedColor == colorItem.name ? 3 : 0)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == colorItem.name ? 2 : 0)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        // Preview Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preview")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 16) {
                                Image(systemName: selectedIcon)
                                    .font(.title2)
                                    .foregroundColor(selectedColorValue)
                                    .frame(width: 40, height: 40)
                                    .background(selectedColorValue.opacity(0.1))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(activityName.isEmpty ? "Activity Name" : activityName)
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(activityName.isEmpty ? .secondary : .primary)
                                    
                                    Text("0m today")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                            }
                            .padding(16)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
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