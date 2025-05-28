//
//  CompletionStepView.swift
//  Novelty (Or part of OnboardingView.swift)
//
//  Created by YourTeam on May 23, 2025.
//

import SwiftUI

struct CompletionStepView: View {
    var body: some View {
        VStack(spacing: 30) { // Increased spacing for a celebratory feel
            Spacer() // Push content down from the top

            // Celebratory Icon
            Image(systemName: "party.popper.fill")
                .font(.system(size: 80, weight: .semibold)) // Large and impactful
                .foregroundColor(.yellow) // Gold/Yellow for celebration
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5) // Subtle shadow
                .padding(.bottom, 20)
                .symbolEffect(.bounce.up.byLayer, options: .repeating.speed(1), value: true) // Fun animation

            Text("You're All Set!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color.primary)

            VStack(spacing: 15) {
                Text("Thank you for setting things up.")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text("Get ready to embrace the unexpected and discover new perspectives each day with Novelty.")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.secondary) // Consistent with the above line
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30) // Keep text lines from being too wide

            Spacer() // Pushes content up
            Spacer() // More space before the bottom navigation buttons
        }
        .padding(30) // Overall padding
    }
}

// MARK: - Preview for CompletionStepView
struct CompletionStepView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Optional: for consistent preview context
            CompletionStepView()
        }
    }
}
