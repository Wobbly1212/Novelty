//
//  AboutYouStepView.swift
//  Novelty (Or part of OnboardingView.swift)
//
//  Created by YourTeam on May 23, 2025.
//

import SwiftUI

struct AboutYouStepView: View {
    // Bindings to update the state variables in the parent OnboardingView
    @Binding var ageInput: String
    @Binding var professionInput: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) { // Align content to leading for a common form feel
            Spacer() // Pushes content down slightly

            // Section Title
            HStack {
                Image(systemName: "person.text.rectangle.fill") // SF Symbol for user details
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.accentColor)
                Text("A Little About You")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
            }
            .padding(.bottom, 10)

            Text("Providing this information is optional. It helps us understand our community better and could allow us to tailor your experience in the future (though this is not yet implemented). We respect your privacy.")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.bottom, 20)

            // Age Input
            VStack(alignment: .leading, spacing: 5) {
                Text("Age (Optional)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                TextField("e.g., 30", text: $ageInput)
                    .keyboardType(.numberPad) // Ensures only numbers can be typed
                    .padding(12)
                    .background(Color(UIColor.systemGray6)) // Subtle background for text field
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(UIColor.systemGray3), lineWidth: 1) // Subtle border
                    )
            }

            // Profession Input
            VStack(alignment: .leading, spacing: 5) {
                Text("Profession (Optional)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                TextField("e.g., Designer, Student, Engineer", text: $professionInput)
                    .padding(12)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                    )
            }
            
            Spacer() // Pushes content upwards
            Spacer() // Provides more space at the bottom
        }
        .padding(30) // Overall padding for the content
    }
}

// MARK: - Preview for AboutYouStepView
struct AboutYouStepView_Previews: PreviewProvider {
    // Create dummy @State variables for the preview using .constant() or a wrapper struct
    @State static var age: String = ""
    @State static var profession: String = ""

    static var previews: some View {
        NavigationView {
            AboutYouStepView(ageInput: $age, professionInput: $profession)
        }
    }
}
