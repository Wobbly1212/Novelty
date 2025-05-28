//
//  NotificationManager.swift
//  Novelty
//
//  Created by Fabio on 21/05/25.
//  Combined, Refactored, and Updated by YourTeam on May 23, 2025.
//

import Foundation
import UserNotifications
import Combine // For ObservableObject

class NotificationScheduler: ObservableObject {
    
    private let userProfileManager: UserProfileManager
    private let nextNoveltyTimeKey = "NextNoveltyTime" // Key for UserDefaults, used by your original logic

    init(userProfileManager: UserProfileManager) {
        self.userProfileManager = userProfileManager
    }

    /// Schedules a novelty notification for a specific calculated time, ONCE per call.
    /// To achieve "daily" notifications, this function should be invoked each day
    /// by your app's logic (e.g., via `setupTodaysNoveltyNotification`).
    /// This version checks DND Quiet Periods.
    ///
    /// - Parameter hour: The hour (0-23) for the notification. Defaults to 11, as in your original code.
    func scheduleNoveltyNotificationOnce(at hour: Int = 11) {
        // 1. Calculate the specific fire date and time based on your logic:
        //    Today, at the specified 'hour', and current actual minute + 1.
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        dateComponents.hour = hour
        
        let currentMinute = Calendar.current.component(.minute, from: Date())
        dateComponents.minute = currentMinute + 1
        // Calendar.current.date(from: dateComponents) will handle minute/hour/day rollovers if (currentMinute + 1) >= 60.

        guard let fireDate = Calendar.current.date(from: dateComponents) else {
            print("NotificationManager: Could not construct a valid fireDate for novelty notification.")
            return
        }
        
        // 2. Check DND (Quiet Periods) for this specific fireDate
        if userProfileManager.isAllowedToSendNotification(currentDate: fireDate) {
            let content = UNMutableNotificationContent()
            content.title = "Your novelty is here!" // Consider making titles more varied
            content.body = "Tap to view today's challenge and shift your perspective."
            content.sound = .default // Or a custom app sound: UNNotificationSound(named: UNNotificationSoundName("your_sound.aiff"))
            // content.categoryIdentifier = "NOVELTY_ACTIONS" // For custom actions like "Delay"

            // Trigger for a specific date and time, non-repeating.
            // The 'repeats: false' is crucial because dateComponents includes year, month, and day.
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let requestIdentifier = "dailyNovelty" // Consistent identifier

            // Remove any pending notification with the same ID to ensure this one is fresh
            // or to replace a previously delayed one.
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
            
            let request = UNNotificationRequest(
                identifier: requestIdentifier,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("NotificationManager: Error scheduling novelty notification: \(error.localizedDescription)")
                } else {
                    // Use .shortened for time as .short is not a member of Date.FormatStyle.TimeStyle
                    let fireDateFormatted = fireDate.formatted(date: .long, time: .shortened)
                    print("NotificationManager: Novelty notification scheduled successfully for \(fireDateFormatted).")
                    // Preserve your logic of saving the next novelty time to UserDefaults
                    UserDefaults.standard.set(fireDate.timeIntervalSince1970, forKey: self.nextNoveltyTimeKey)
                }
            }
        } else {
            let fireDateFormatted = fireDate.formatted(date: .abbreviated, time: .shortened)
            print("NotificationManager: Intended time \(fireDateFormatted) for novelty is blocked by DND (Quiet Hours). Notification not scheduled.")
        }
    }
    
    /// Delays the novelty notification by a short interval.
    /// This version checks DND Quiet Periods for the future fire time.
    /// It uses the same identifier "dailyNovelty", so it will replace any existing scheduled novelty.
    ///
    /// - Parameter bySeconds: The delay interval in seconds. Defaults to 60 seconds (1 minute).
    func delayNotification(bySeconds interval: TimeInterval = 60) {
        let fireDate = Date().addingTimeInterval(interval) // Calculate the exact future time

        // Check if the calculated future fire time is allowed by DND (Quiet Hours)
        if userProfileManager.isAllowedToSendNotification(currentDate: fireDate) {
            let content = UNMutableNotificationContent()
            content.title = "Your delayed novelty is here"
            content.body = "Ready now? Tap to view today's challenge."
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            
            let requestIdentifier = "dailyNovelty" // Same identifier, will replace any existing

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestIdentifier])

            let request = UNNotificationRequest(
                identifier: requestIdentifier,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("NotificationManager: Error scheduling delayed novelty: \(error.localizedDescription)")
                } else {
                    let minutes = Int(interval / 60)
                    print("NotificationManager: Delayed novelty notification scheduled in \(minutes) minute(s) for \(fireDate.formatted(date: .omitted, time: .shortened)).")
                    // Preserve your logic of saving the next novelty time to UserDefaults
                    UserDefaults.standard.set(fireDate.timeIntervalSince1970, forKey: self.nextNoveltyTimeKey)
                }
            }
        } else {
            let minutes = Int(interval / 60)
            let fireDateFormatted = fireDate.formatted(date: .omitted, time: .shortened)
            print("NotificationManager: Attempted delay, but fire time \(fireDateFormatted) (in \(minutes) minute(s)) is blocked by DND (Quiet Hours). Delayed notification not scheduled.")
        }
    }

    /// Requests authorization from the user to send notifications.
    /// This should be called at an appropriate point in your app's flow (e.g., during onboarding).
    /// - Parameter completion: A closure that returns whether permission was granted and any error.
    func requestNotificationAuthorization(completion: @escaping (_ granted: Bool, _ error: Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            // Ensure completion handler is called on the main thread for any UI updates
            DispatchQueue.main.async {
                if granted {
                    print("NotificationManager: Notification permission granted by user.")
                } else {
                    print("NotificationManager: Notification permission denied by user.")
                    if let error = error {
                        print("NotificationManager: Authorization request error: \(error.localizedDescription)")
                    }
                }
                completion(granted, error)
            }
        }
    }

    /// Call this function, for instance, daily when the app becomes active or is launched,
    /// to attempt scheduling today's novelty notification. It respects DND Quiet Hours.
    public func setupTodaysNoveltyNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { // Perform checks and scheduling on the main thread
                guard settings.authorizationStatus == .authorized else {
                    print("NotificationManager: Notification authorization not granted. Cannot schedule novelty. User may need to grant permission in system Settings.")
                    // If status is .notDetermined, you might consider calling requestNotificationAuthorization again,
                    // but typically that's handled explicitly during onboarding or a user action.
                    return
                }

                if settings.alertSetting == .enabled {
                    print("NotificationManager: Notifications authorized and alert setting enabled. Attempting to schedule today's novelty notification.")
                    // This calls your specific logic for a one-time schedule based on current time + offset and specified hour.
                    self.scheduleNoveltyNotificationOnce() // Uses default hour or you can pass a specific one.
                } else {
                    print("NotificationManager: Notifications are authorized, but system alert setting is disabled by the user for this app.")
                    // Since the user doesn't want alerts, clear any previously scheduled novelty notification.
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyNoveltyNotification"])
                    print("NotificationManager: Cleared any pending novelty notifications as alerts are disabled in system settings.")
                }
            }
        }
    }
}
