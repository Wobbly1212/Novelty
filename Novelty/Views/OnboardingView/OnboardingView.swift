//
//  OnboardingView.swift
//  Novelty
//
//  Created by YourTeam on May 21, 2025.
//  Ensuring correct structure and call to NotificationsPermissionStepView on May 23, 2025.
//

import SwiftUI
import UserNotifications // For checking notification settings in onAppear of a subview

// MARK: - OnboardingStep Enum
// Ensure this enum is defined, either here or in a globally accessible file.
enum OnboardingStep: Int, CaseIterable {
    case welcome
    case howItWorks
    case aboutYou
    case hobbies
    case quietHoursSetup
    case notificationsPermission
    case completion

    var title: String { // Example titles, adjust as needed
        switch self {
        case .welcome: return "Welcome!"
        case .howItWorks: return "How It Works"
        case .aboutYou: return "About You"
        case .hobbies: return "Your Hobbies"
        case .quietHoursSetup: return "Quiet Hours"
        case .notificationsPermission: return "Notifications"
        case .completion: return "All Set!"
        }
    }
}

// MARK: - Main OnboardingView Struct
struct OnboardingView: View {
    // MARK: - Properties
    @EnvironmentObject var userProfileManager: UserProfileManager
    // This 'notificationManager' instance IS of your DND-aware 'NotificationScheduler' class type
    var notificationManager: NotificationScheduler // Passed in
    var onOnboardingComplete: () -> Void          // Closure to call when done

    @State private var currentStep: OnboardingStep = .welcome

    // State variables for collecting data across steps
    @State private var ageInput: String = ""
    @State private var professionInput: String = ""
    @State private var hobbiesInput: String = ""
    @State private var tempQuietPeriods: [QuietPeriod] = []
    
    @State private var showingAddQuietPeriodSheet = false

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Indicator
                ProgressView(value: Double(currentStep.rawValue + 1), total: Double(OnboardingStep.allCases.count))
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 10)
                    .animation(.easeInOut, value: currentStep)

                // Dynamic content based on the current step
                Group {
                    switch currentStep {
                    case .welcome:
                        WelcomeStepView()  // Assumed to be defined elsewhere
                    case .howItWorks:
                        HowItWorksStepView() // Assumed to be defined elsewhere
                    case .aboutYou:
                        AboutYouStepView(ageInput: $ageInput, professionInput: $professionInput) // Assumed
                    case .hobbies:
                        HobbiesStepView(hobbiesInput: $hobbiesInput) // Assumed
                    case .quietHoursSetup:
                        QuietHoursStepView(quietPeriods: $tempQuietPeriods, showingAddSheet: $showingAddQuietPeriodSheet) // Assumed
                    case .notificationsPermission:
                        // --- THIS IS THE CORRECTED LINE ---
                        NotificationsPermissionStepView(notificationScheduler: notificationManager) // Correct label
                    case .completion:
                        CompletionStepView() // Assumed
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Navigation Buttons
                HStack {
                    if currentStep.rawValue > 0 && currentStep != .completion {
                        Button("Back") {
                            withAnimation(.easeInOut) {
                                if currentStep.rawValue > 0 {
                                    currentStep = OnboardingStep(rawValue: currentStep.rawValue - 1)!
                                }
                            }
                        }
                        .padding()
                        .buttonStyle(.bordered)
                    } else {
                        Spacer().frame(minWidth: 0)
                    }

                    Spacer()

                    Button(currentStep == .completion ? "Get Started!" : "Next") {
                        withAnimation(.easeInOut) {
                            handleNextButton()
                        }
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                .padding(.bottom, safeAreaInsetsBottom)
                .padding(.top, 5)
            }
            // .navigationTitle(currentStep.title) // Optional
            // .navigationBarHidden(true) // Optional
        }
        .sheet(isPresented: $showingAddQuietPeriodSheet) {
            // Assuming AddQuietPeriodView is defined elsewhere
            AddQuietPeriodView { newPeriod in
                tempQuietPeriods.append(newPeriod)
            }
            // .environmentObject(userProfileManager) // If AddQuietPeriodView needs it
        }
    } // --- End of var body: some View ---

    // MARK: - Methods
    // (handleNextButton and saveProfileData methods are correctly placed outside body)

    func handleNextButton() {
        if currentStep == .completion {
            saveProfileData()
            onOnboardingComplete()
        } else if currentStep.rawValue < OnboardingStep.allCases.count - 1 {
            currentStep = OnboardingStep(rawValue: currentStep.rawValue + 1)!
        }
    }

    func saveProfileData() {
        if let age = Int(ageInput), age > 0 {
            userProfileManager.userProfile.age = age
        } else if ageInput.isEmpty {
            userProfileManager.userProfile.age = nil
        }
        
        userProfileManager.userProfile.profession = professionInput.isEmpty ? nil : professionInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hobbiesInput.isEmpty {
            userProfileManager.userProfile.hobbies = nil
        } else {
            let hobbiesArray = hobbiesInput.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            userProfileManager.userProfile.hobbies = hobbiesArray.isEmpty ? nil : hobbiesArray
        }

        userProfileManager.userProfile.quietPeriods = tempQuietPeriods
        
        userProfileManager.saveUserProfile()
        print("OnboardingView: User profile data saved.")
    }
    
    private var safeAreaInsetsBottom: CGFloat {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.safeAreaInsets.bottom ?? 10
    }

} // --- End of struct OnboardingView ---
