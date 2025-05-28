//
//  UserProfileManager.swift
//  Novelty
//
//  Created by YourTeam on May 21, 2025.
//  Refactored on May 23, 2025 to exclude DND Location features.
//

import Foundation
import Combine

// MARK: - UserProfileManager
/// The central ViewModel for handling user profile data and notification logic.
///
/// Responsibilities:
/// - Load and save the `UserProfile` (containing personal info and Quiet Periods) to `UserDefaults`.
/// - Evaluate whether notifications are allowed based on active Quiet Periods.
/// - Provide methods to modify the user's profile.
class UserProfileManager: ObservableObject {

    // MARK: - Published Properties

    /// Stores the current user profile. SwiftUI views observe this for changes.
    @Published var userProfile: UserProfile

    // MARK: - Storage Key

    /// Unique key for storing the profile in UserDefaults.
    private static let userDefaultsKey = "com.novelty.userProfile" // Ensure this is unique to your app

    // MARK: - Initialization

    /// Loads the saved profile from UserDefaults if it exists; otherwise, initializes an empty profile.
    init() {
        if let savedData = UserDefaults.standard.data(forKey: Self.userDefaultsKey) {
            do {
                // This decode assumes 'UserProfile.swift' has been updated to remove 'dndLocations'.
                let decoder = JSONDecoder()
                userProfile = try decoder.decode(UserProfile.self, from: savedData)
                print("UserProfileManager: Profile loaded successfully from UserDefaults.")
            } catch {
                print("UserProfileManager: Failed to decode saved profile. Initializing with default. Error: \(error)")
                userProfile = UserProfile.empty // UserProfile.empty should reflect no dndLocations
            }
        } else {
            print("UserProfileManager: No saved profile found in UserDefaults. Initializing with default.")
            userProfile = UserProfile.empty // UserProfile.empty should reflect no dndLocations
        }
    }

    // MARK: - Profile Persistence

    /// Saves the current `userProfile` to UserDefaults using JSON encoding.
    func saveUserProfile() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(userProfile)
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
            print("UserProfileManager: Profile saved successfully to UserDefaults.")
        } catch {
            print("UserProfileManager: Failed to encode profile for saving. Error: \(error)")
        }
    }

    // MARK: - Notification Logic

    /// Checks whether a notification is allowed based on Quiet Periods.
    /// - Parameter currentDate: The date and time to evaluate against. Defaults to the current time.
    /// - Returns: `true` if notifications are allowed, `false` otherwise.
    func isAllowedToSendNotification(currentDate: Date = Date()) -> Bool {
        // 1. If DND rules are globally disabled, notifications are allowed.
        guard userProfile.dndGloballyEnabled else {
            print("UserProfileManager: DND globally disabled — notification allowed.")
            return true
        }

        let calendar = Calendar.current
        let currentHourMinuteComponents = calendar.dateComponents([.hour, .minute], from: currentDate)
        let currentDayOfWeek = calendar.component(.weekday, from: currentDate) // 1=Sunday, ..., 7=Saturday

        // 2. Check against each active quiet period.
        for period in userProfile.quietPeriods where period.isEnabled {
            let periodStartComponents = period.startTimeComponents // Helper from QuietPeriod struct
            let periodEndComponents = period.endTimeComponents   // Helper from QuietPeriod struct

            // Case A: Standard (non-overnight) quiet period
            if !isOvernight(start: periodStartComponents, end: periodEndComponents) {
                if period.daysOfWeek.contains(currentDayOfWeek) &&
                   isTime(currentHourMinuteComponents, between: periodStartComponents, and: periodEndComponents) {
                    print("UserProfileManager: Blocked by active quiet period (same day): \(period.name ?? "Unnamed")")
                    return false
                }
            }
            // Case B: Overnight quiet period
            else {
                // Check if current time is in the first part of an overnight period that started today
                if period.daysOfWeek.contains(currentDayOfWeek) &&
                   isTime(currentHourMinuteComponents, atOrAfter: periodStartComponents) {
                    print("UserProfileManager: Blocked by overnight quiet period (starting today): \(period.name ?? "Unnamed")")
                    return false
                }

                // Check if current time is in the spillover part of an overnight period that started yesterday
                let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                let yesterdaysDayOfWeek = calendar.component(.weekday, from: yesterdayDate)
                
                if period.daysOfWeek.contains(yesterdaysDayOfWeek) &&
                   isTime(currentHourMinuteComponents, before: periodEndComponents) {
                    print("UserProfileManager: Blocked by overnight quiet period (spillover from yesterday): \(period.name ?? "Unnamed")")
                    return false
                }
            }
        }

        // 3. If no blocking Quiet Period rules matched, notifications are allowed.
        print("UserProfileManager: No active Quiet Hour rules matched. Notification allowed.")
        return true
    }

    // MARK: - Private Time Helper Functions

    private func timeInMinutes(from components: DateComponents) -> Int? {
        guard let hour = components.hour, let minute = components.minute else { return nil }
        return hour * 60 + minute
    }

    private func isTime(_ current: DateComponents, between start: DateComponents, and end: DateComponents) -> Bool {
        guard let currentMin = timeInMinutes(from: current),
              let startMin = timeInMinutes(from: start),
              let endMin = timeInMinutes(from: end) else { return false }
        return currentMin >= startMin && currentMin < endMin
    }

    private func isTime(_ current: DateComponents, atOrAfter start: DateComponents) -> Bool {
        guard let currentMin = timeInMinutes(from: current),
              let startMin = timeInMinutes(from: start) else { return false }
        return currentMin >= startMin
    }

    private func isTime(_ current: DateComponents, before end: DateComponents) -> Bool {
        guard let currentMin = timeInMinutes(from: current),
              let endMin = timeInMinutes(from: end) else { return false }
        return currentMin < endMin
    }

    private func isOvernight(start: DateComponents, end: DateComponents) -> Bool {
        guard let startMin = timeInMinutes(from: start),
              let endMin = timeInMinutes(from: end) else { return false }
        return startMin >= endMin
    }

    // MARK: - Public Profile Modification Methods

    func updateUserAge(_ age: Int?) {
        userProfile.age = age
        saveUserProfile()
    }

    func addHobby(_ hobby: String) {
        // Ensure hobbies array exists
        if userProfile.hobbies == nil {
            userProfile.hobbies = []
        }
        // Add hobby if it's not a duplicate (case-sensitive)
        if let trimmedHobby = hobby.trimmingCharacters(in: .whitespacesAndNewlines) as String?,
           !trimmedHobby.isEmpty,
           !(userProfile.hobbies?.contains(where: { $0.caseInsensitiveCompare(trimmedHobby) == .orderedSame }) ?? false) {
            userProfile.hobbies?.append(trimmedHobby)
            saveUserProfile()
        }
    }
    
    func removeHobby(_ hobbyToRemove: String) {
        userProfile.hobbies?.removeAll(where: { $0.caseInsensitiveCompare(hobbyToRemove) == .orderedSame })
        if userProfile.hobbies?.isEmpty ?? false {
            userProfile.hobbies = nil // Set to nil if array becomes empty
        }
        saveUserProfile()
    }

    func addQuietPeriod(_ period: QuietPeriod) {
        userProfile.quietPeriods.append(period)
        saveUserProfile()
    }

    func removeQuietPeriod(withID id: UUID) {
        userProfile.quietPeriods.removeAll { $0.id == id }
        saveUserProfile()
    }
    
    func updateQuietPeriod(_ periodToUpdate: QuietPeriod) {
        if let index = userProfile.quietPeriods.firstIndex(where: { $0.id == periodToUpdate.id }) {
            userProfile.quietPeriods[index] = periodToUpdate
            saveUserProfile()
        }
    }

    func toggleGlobalDND(isEnabled: Bool) {
        userProfile.dndGloballyEnabled = isEnabled 
        saveUserProfile()
    }

    // MARK: - Preview Support

    /// A static instance for SwiftUI Previews and testing.
    static var preview: UserProfileManager {
        let manager = UserProfileManager()
        // This assumes UserProfile.init and QuietPeriod.init are updated to exclude DNDLocation.
        manager.userProfile = UserProfile(
            age: 30,
            profession: "Illustrator",
            hobbies: ["Sketching", "Reading"],
            quietPeriods: [
                QuietPeriod(
                    startTime: Calendar.current.date(from: DateComponents(hour: 22, minute: 30))!,
                    endTime: Calendar.current.date(from: DateComponents(hour: 7, minute: 0))!,
                    daysOfWeek: [2,3,4,5,6], // Monday to Friday
                    name: "Sleep",
                    isEnabled: true
                )
            ],
            dndGloballyEnabled: true
        )
        return manager
    }
}
