//
//  NoveltyApp.swift // Or contemplativeApp.swift
//  Novelty
//
//  Created by Fabio on 21/05/25.
//  Updated by YourTeam on May 23, 2025 to integrate UserProfileManager and DND-aware NotificationManager.
//

import SwiftUI

@main
struct contemplativeApp: App {
    
    // MARK: - User's Existing Managers & State
    /// Manages the core novelty content and logic.
    @StateObject var noveltyContentManager: NoveltyManager 
    
    /// User's custom time manager.
    @StateObject var timeManager: TimeManager
    
    // This local @State for current time might be for specific immediate logic.
    // Be mindful if it causes excessive view updates.
    @State private var currentTime = Date()

    // MARK: - Managers for User Preferences & Notifications (Our additions)
    /// Manages user profile data (age, hobbies, Quiet Hours) and persistence.
    @StateObject var userProfileManager: UserProfileManager
    
    /// Manages notification scheduling, permissions, and respects DND (Quiet Hours).
    @StateObject var dndAwareNotificationManager: NotificationScheduler // Renamed to avoid conflict if user has another "NotificationManager"
 
    // MARK: - App Storage for Persistent State
    /// Tracks if onboarding has been completed. `false` means show onboarding.
    @AppStorage("novelty_onboarding_completed_v1") var hasCompletedOnboarding: Bool = false // Changed key for clarity & versioning
    
    /// Tracks the ID of the next novelty to be proposed.
    @AppStorage("NextNoveltyId") var nextNoveltyId: String = ""
    
    /// Tracks the timestamp for the next novelty.
    @AppStorage("NextNoveltyTime") var nextNoveltyTime: Double = Double.infinity
    
    /// Tracks the current status of the novelty (e.g., proposed, accepted, delayed, completed).
    /// Assuming NoveltyStatus is a Codable enum you've defined.
    @AppStorage("CurrentNoveltyStatus") var currentNoveltyStatus: NoveltyStatus = .proposed

    // MARK: - Initialization
    init() {
        // Initialize UserProfileManager first as dndAwareNotificationManager depends on it.
        let upManager = UserProfileManager() // Create instance once
        _userProfileManager = StateObject(wrappedValue: upManager)
        
        // Initialize our DND-aware NotificationManager with the instance of UserProfileManager.
        _dndAwareNotificationManager = StateObject(wrappedValue: NotificationScheduler(userProfileManager: upManager))
        
        // Initialize your existing managers.
        _noveltyContentManager = StateObject(wrappedValue: NoveltyManager()) // Assuming NoveltyManager() is its correct init
        _timeManager = StateObject(wrappedValue: TimeManager())             // Assuming TimeManager() is its correct init
        
        print("contemplativeApp Initialized. Onboarding completed: \(hasCompletedOnboarding)")
        // You might want to call dndAwareNotificationManager.setupTodaysNoveltyNotification() here
        // if hasCompletedOnboarding is true, or handle it in RootRouterView/MainView's .onAppear.
    }

    // MARK: - Scene Definition
    var body: some Scene {
        WindowGroup {
            // RootRouterView will now decide whether to show OnboardingView or MainView
            // based on the 'hasCompletedOnboarding' flag.
            RootRouterView(
                // Pass the AppStorage binding so OnboardingView can update it.
                // This is one way; another is for RootRouterView to directly read @AppStorage.
                hasCompletedOnboarding: $hasCompletedOnboarding
            )
            .environmentObject(noveltyContentManager)      // User's existing NoveltyManager
            .environmentObject(timeManager)                // User's existing TimeManager
            .environmentObject(userProfileManager)         // Our UserProfileManager for preferences/DND rules
            .environmentObject(dndAwareNotificationManager) // Our DND-aware NotificationManager
        }
    }
}
