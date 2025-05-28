//
//  QuietHoursStepView.swift
//  Novelty
//
//  Created by Hosein Darabi on 23/05/25.
//

import SwiftUI

struct QuietHoursStepView: View {
    // Bindings to the state variables in the parent OnboardingView
    @Binding var quietPeriods: [QuietPeriod] // The list of quiet periods being built
    @Binding var showingAddSheet: Bool      // To signal the parent to show the AddQuietPeriodView sheet

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Spacer() // Push content down a bit

            // Section Title
            HStack {
                Image(systemName: "moon.zzz.fill") // SF Symbol for sleep/quiet time
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.accentColor) // Use app's accent color
                Text("Set Your Quiet Hours")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
            }
            .padding(.bottom, 5)

            Text("Tell us when you prefer not to receive notifications. You can add multiple periods (e.g., for nighttime sleep and focused work hours).")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.bottom, 15)

            // List of Quiet Periods
            if quietPeriods.isEmpty {
                VStack { // Center the "empty" message
                    Spacer()
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.bottom, 10)
                    Text("No quiet hours added yet.")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity) // Ensure VStack takes full width for centering
            } else {
                List {
                    ForEach(quietPeriods) { period in
                        QuietPeriodRowView(period: period) // Using a dedicated row view for clarity
                    }
                    .onDelete(perform: deleteQuietPeriod)
                }
                .listStyle(InsetGroupedListStyle()) // A more modern list style
                .frame(height: min(CGFloat(quietPeriods.count * 70 + 40), 300)) // Dynamic height with max
            }
            
            // Add Button
            HStack {
                Spacer() // Center the button
                Button {
                    showingAddSheet = true // Signal parent OnboardingView to present the sheet
                } label: {
                    Label("Add Quiet Period", systemImage: "plus.circle.fill")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .buttonStyle(.bordered) // Prominent style for adding
                .controlSize(.regular)
                Spacer()
            }
            .padding(.top, 10)
            
            Spacer() // Push content upwards
        }
        .padding(30) // Overall padding for the content
    }

    // Method to delete quiet periods from the list
    private func deleteQuietPeriod(at offsets: IndexSet) {
        quietPeriods.remove(atOffsets: offsets)
    }
}

// MARK: - QuietPeriodRowView (Helper view to display a single quiet period)
struct QuietPeriodRowView: View {
    let period: QuietPeriod

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(period.name ?? "Quiet Time")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text("\(formatTime(period.startTime)) - \(formatTime(period.endTime))")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                Text("Days: \(daysDisplay(period.daysOfWeek))")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.gray)
            }
            Spacer()
            if period.isEnabled {
                Image(systemName: "bell.slash.fill") // Icon indicating DND is active for this period
                    .foregroundColor(.blue)
            } else {
                 Image(systemName: "bell.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 5) // Add some padding within the row
    }

    // Helper to format time (should be consistent with how it's used elsewhere)
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Helper to display days (should be consistent)
    private func daysDisplay(_ days: Set<Int>) -> String {
        if days.isEmpty { return "Not set" } // Or "One-time" if that's a use case
        if days.count == 7 { return "Every Day" }
        
        // Sort days based on calendar convention (Sunday as 1)
        let sortedDays = days.sorted()
        let symbols = Calendar.current.shortWeekdaySymbols // ["Sun", "Mon", ..., "Sat"]
        
        // Check for common patterns
        if days == Set([1,7]) { return "Weekends" } // Sunday & Saturday
        if days == Set([2,3,4,5,6]) { return "Weekdays" } // Monday to Friday
        
        return sortedDays.map { symbols[$0 - 1] }.joined(separator: ", ")
    }
}


// MARK: - Preview for QuietHoursStepView
struct QuietHoursStepView_Previews: PreviewProvider {
    // Create dummy @State variables for the preview using a wrapper or .constant
    @State static var periods: [QuietPeriod] = [
        QuietPeriod(startTime: Calendar.current.date(from: DateComponents(hour: 22, minute: 0))!,
                    endTime: Calendar.current.date(from: DateComponents(hour: 7, minute: 0))!,
                    daysOfWeek: [1,2,3,4,5,6,7], name: "Night Time", isEnabled: true),
        QuietPeriod(startTime: Calendar.current.date(from: DateComponents(hour: 13, minute: 0))!,
                    endTime: Calendar.current.date(from: DateComponents(hour: 14, minute: 0))!,
                    daysOfWeek: [2,3,4,5,6], name: "Lunch Break Focus", isEnabled: true)
    ]
    @State static var showSheet: Bool = false

    static var previews: some View {
        NavigationView { // Optional: for consistent previewing context
            QuietHoursStepView(quietPeriods: $periods, showingAddSheet: $showSheet)
        }
    }
}
