//
//  WelcomeStepView.swift
//  Novelty (Or part of OnboardingView.swift)
//
//  Created by YourTeam on May 23, 2025.
//

import SwiftUI

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 30) { // Added a bit more spacing between elements
            Spacer() // Pushes content down a bit from the top edge or progress view

            // Thematic Symbol
            Image(systemName: "wand.and.stars") // Represents novelty, surprise, magic
                .font(.system(size: 70, weight: .light))
                .foregroundColor(.accentColor) // Use the app's accent color
                .padding(.bottom, 15)

            Text("Welcome to Novelty!")
                .font(.system(size: 30, weight: .bold, design: .rounded)) // Clear, welcoming title
                .multilineTextAlignment(.center)


            VStack(spacing: 15) {
                Text("Rediscover your day with moments of surprise and fresh perspectives.")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal) // Keep text lines from being too wide

                Text("We'll offer gentle nudges—unique activities and playful challenges—to spark a little joy and mindfulness.")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.gray) // Softer color for descriptive text
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20) // More padding for this longer text
            }

            Spacer()
            Spacer() // Pushes content up from the bottom navigation buttons
        }
        .padding(30) // Overall padding for the content within the step view
    }
}

// MARK: - Preview for WelcomeStepView
struct WelcomeStepView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Often useful to see it within a nav structure if your onboarding uses one
            WelcomeStepView()
        }
    }
}
