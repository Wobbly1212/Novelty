//
//  HowItWorksStepView.swift
//  Novelty (Or part of OnboardingView.swift)
//
//  Created by YourTeam on May 23, 2025.
//

import SwiftUI

struct HowItWorksStepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 25) { // Main VStack for the content
            Spacer() // Push content down a bit

            HStack { // Title with an icon
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.accentColor)
                Text("How Novelty Works")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
            }
            .padding(.bottom, 15)

            // Informational Rows
            InfoRow(
                systemImage: "bell.badge.fill",
                imageColor: .orange,
                title: "Daily Surprise",
                description: "Once a day, at a random time, you'll receive a notification proposing a unique 'Novelty'."
            )

            InfoRow(
                systemImage: "hand.tap.fill",
                imageColor: .green,
                title: "Your Choice",
                description: "You can choose to accept the novelty, delay it for later, or simply discard it."
            )

            InfoRow(
                systemImage: "figure.walk.motion", // Icon for activity/guidance
                imageColor: .blue,
                title: "Guided Experience",
                description: "If you accept, the app will guide you through the novelty – a brief, engaging activity."
            )

            InfoRow(
                systemImage: "archivebox.fill",
                imageColor: .brown,
                title: "Inner Archive",
                description: "Completed novelties and your reflections can be saved in your private 'Inner Archive'."
            )

            InfoRow(
                systemImage: "moon.zzz.fill", // Icon for quiet hours
                imageColor: .indigo,
                title: "Quiet Hours",
                description: "You'll soon set up 'Quiet Hours' to ensure notifications don't arrive when you prefer silence."
            )
            
            Spacer() // Push content upwards
            Spacer()
        }
        .padding(30) // Overall padding for the content
    }
}

// Helper View for consistent row styling
struct InfoRow: View {
    let systemImage: String
    let imageColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .semibold)) // Prominent icon
                .foregroundColor(imageColor)
                .frame(width: 35, alignment: .center) // Fixed width for icon alignment

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Text(description)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(nil) // Allow text to wrap indefinitely
            }
        }
    }
}

// MARK: - Preview for HowItWorksStepView
struct HowItWorksStepView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HowItWorksStepView()
        }
    }
}
