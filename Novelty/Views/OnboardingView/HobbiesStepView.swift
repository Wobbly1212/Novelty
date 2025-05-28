//
//  HobbiesStepView.swift
//  Novelty (Or part of OnboardingView.swift)
//
//  Created by YourTeam on May 23, 2025.
//

import SwiftUI

struct HobbiesStepView: View {
    // Binding to update the hobbiesInput state variable in the parent OnboardingView
    @Binding var hobbiesInput: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) { // Align content to leading
            Spacer() // Pushes content down slightly

            // Section Title
            HStack {
                Image(systemName: "figure.play") // SF Symbol representing activities/hobbies
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.accentColor)
                Text("Share Your Interests")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
            }
            .padding(.bottom, 10)

            Text("What do you enjoy doing in your free time? (Optional)")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.bottom, 20)

            // Hobbies Input
            VStack(alignment: .leading, spacing: 5) {
                Text("Hobbies (Optional)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                
                TextField("e.g., Reading, Hiking, Photography, Cooking", text: $hobbiesInput)
                    .padding(12)
                    .background(Color(UIColor.systemGray6)) // Subtle background
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(UIColor.systemGray3), lineWidth: 1) // Subtle border
                    )
                
                Text("You can list a few, separated by commas.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.top, 3)
            }
            
            Spacer() // Pushes content upwards
            Spacer() // Provides more space at the bottom
        }
        .padding(30) // Overall padding for the content
    }
}

// MARK: - Preview for HobbiesStepView
struct HobbiesStepView_Previews: PreviewProvider {
    // Create a dummy @State variable for the preview
    @State static var hobbies: String = ""

    static var previews: some View {
        NavigationView { // Optional: for consistent previewing context
            HobbiesStepView(hobbiesInput: $hobbies)
        }
    }
}
