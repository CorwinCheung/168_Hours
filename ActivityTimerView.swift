import SwiftUI

struct ActivityTimerView: View {
    let activity: Activity
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            // Activity Icon
            Image(systemName: activity.icon ?? "book")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(Color.from(name: activity.color ?? "blue"))
                .padding()
            
            // Activity Name
            Text(activity.name ?? "Activity")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.bottom, 8)
            
            // Timer
            Text(timerManager.formattedElapsedTime)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .padding(.bottom, 16)
            
            // Start/Pause/Stop Button
            HStack(spacing: 24) {
                if timerManager.isRunning && timerManager.activeActivity?.id == activity.id {
                    Button(action: { timerManager.pauseTimer() }) {
                        Text("Pause")
                            .font(.title2)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color.from(name: activity.color ?? "blue"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    Button(action: { timerManager.stopTimer() }) {
                        Text("Stop")
                            .font(.title2)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                } else {
                    Button(action: { timerManager.startTimer(for: activity) }) {
                        Text("Start")
                            .font(.title2)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color.from(name: activity.color ?? "blue"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            Spacer()
        }
        .navigationTitle(activity.name ?? "Activity")
        .background(Color.from(name: activity.color ?? "blue").ignoresSafeArea())
    }
} 