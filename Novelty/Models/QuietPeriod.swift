//
//  QuietPeriod.swift
//  Novelty
//
//  Created by Hosein Darabi on 23/05/25.
//


import Foundation

// MARK: - QuietPeriod
/// Represents a user-defined time range when notifications should be muted.
///
/// Used in `UserProfile` as part of the user's Do Not Disturb settings.
/// Codable → storable in UserDefaults; Identifiable → usable in SwiftUI lists.
struct QuietPeriod: Codable, Identifiable { 

    // MARK: - Core Properties

    /// Unique identifier for this quiet period. Required for tracking in lists and storage.
    let id: UUID

    /// The start time (hour + minute) of this quiet period.
    /// Only the time component is relevant — date is ignored.
    /// UI icon suggestion: "hourglass.bottomhalf.filled"
    var startTime: Date

    /// The end time (hour + minute) of this quiet period.
    /// UI icon suggestion: "hourglass.tophalf.filled"
    var endTime: Date

    /// Which days of the week this quiet period applies to.
    /// Uses Calendar-style values: 1 = Sunday, 7 = Saturday.
    /// Stored as a Set to avoid duplicates and enable fast lookup.
    var daysOfWeek: Set<Int>

    /// Optional user-friendly name (e.g., "Sleep", "Morning Focus").
    /// Helps with UI display and managing multiple entries.
    var name: String?

    /// Toggle to activate/deactivate this period without deleting it.
    /// UI icon suggestion: "checkmark.circle.fill" (enabled), "circle" (disabled)
    var isEnabled: Bool

    // MARK: - Initializer

    /// Creates a new quiet period definition.
    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date,
        daysOfWeek: Set<Int>,
        name: String? = nil,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.daysOfWeek = daysOfWeek
        self.name = name
        self.isEnabled = isEnabled
    }

    // MARK: - Helpers (Time Component Access)

    /// Extracts hour + minute components from start time (ignores date).
    var startTimeComponents: DateComponents {
        Calendar.current.dateComponents([.hour, .minute], from: startTime)
    }

    /// Extracts hour + minute components from end time (ignores date).
    var endTimeComponents: DateComponents {
        Calendar.current.dateComponents([.hour, .minute], from: endTime)
    }
}
