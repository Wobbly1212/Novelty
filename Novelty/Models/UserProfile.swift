//
//  UserProfile.swift
//  Novelty
//
//  Created by YourTeam on May 21, 2025.
//

import Foundation

// MARK: - UserProfile
/// Stores the user's personal data and notification-blocking preferences.
///
/// This model is:
/// - Codable → easy to save/load from UserDefaults or JSON files.
/// - Identifiable → convenient for SwiftUI Lists or dynamic views.
///
/// It references:
/// - `QuietPeriod`: user-defined time ranges for blocking notifications.
/// - `DNDLocation`: user-defined locations where notifications should be silenced.
/// These are defined in their respective model files.

struct UserProfile: Codable, Identifiable {
    // MARK: - Identity

    /// Unique user ID (auto-generated).
    let id: UUID

    // MARK: - Personal Information

    /// The user's age. Optional.
    /// Can be shown in UI with symbol: "person.badge.clock".
    var age: Int?

    /// The user's profession (e.g., "student", "nurse"). Optional.
    /// UI symbol suggestion: "briefcase".
    var profession: String?

    /// The user's hobbies as a list of strings. Optional.
    /// UI symbol suggestion: "figure.play" or "heart.text.square".
    var hobbies: [String]?

    // MARK: - Do Not Disturb (DND) Preferences

    /// Custom time blocks when notifications should be muted.
    /// These map to `QuietPeriod` structs (see QuietPeriod.swift).
    /// Suggested UI symbol: "moon.zzz" or "bell.slash.circle".
    var quietPeriods: [QuietPeriod]

    
    /// Master toggle: enables or disables all DND settings globally.
    /// If `false`, both quietPeriods and dndLocations are ignored.
    /// UI toggle suggestion: "bell.slash.fill" vs. "bell.fill".
    var dndGloballyEnabled: Bool

    // MARK: - Initialization

    /// Initializes a new UserProfile instance.
    /// - Parameters:
    ///   - id: Auto-generated UUID.
    ///   - age: User age (optional).
    ///   - profession: User profession (optional).
    ///   - hobbies: List of hobbies (optional).
    ///   - quietPeriods: Time ranges to mute notifications.
    ///   - dndLocations: Block notifications at these locations.
    ///   - dndGloballyEnabled: Master toggle for DND settings.
    init(
        id: UUID = UUID(),
        age: Int? = nil,
        profession: String? = nil,
        hobbies: [String]? = nil,
        quietPeriods: [QuietPeriod] = [],
        dndGloballyEnabled: Bool = true
    ) {
        self.id = id
        self.age = age
        self.profession = profession
        self.hobbies = hobbies
        self.quietPeriods = quietPeriods
        self.dndGloballyEnabled = dndGloballyEnabled
    }

    // MARK: - Empty Default

    /// A blank profile useful for previews, debugging, or first launch.
    static var empty: UserProfile {
        UserProfile()
    }
}
