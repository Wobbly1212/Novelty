//
//  NotificationsPermissionStepView.swift
//  Novelty
//
//  Created by Hosein Darabi on 23/05/25.
//  Final version incorporating preview fixes.
//

import SwiftUI
import UserNotifications // For UNUserNotificationCenter and UIApplication

struct NotificationsPermissionStepView: View {
    // This view expects an instance of your DND-aware NotificationScheduler class.
    var notificationScheduler: NotificationScheduler

    // State variables managed by this view
    @State private var permissionRequested: Bool
    @State private var permissionGranted: Bool? // nil (not determined), true (granted), false (denied)

    // Main initializer used by your app's onboarding flow
    init(notificationScheduler: NotificationScheduler) {
        self.notificationScheduler = notificationScheduler
        // Initialize @State properties with default values for live app usage
        self._permissionRequested = State(initialValue: false)
        self._permissionGranted = State(initialValue: nil)
    }

    // Special initializer for SwiftUI Previews to set initial states
    #if DEBUG
    init(notificationScheduler: NotificationScheduler, permissionRequested: Bool, permissionGranted: Bool?) {
        self.notificationScheduler = notificationScheduler
        // Initialize @State properties with values passed directly for previewing specific UI states
        self._permissionRequested = State(initialValue: permissionRequested)
        self._permissionGranted = State(initialValue: permissionGranted)
    }
    #endif

    // MARK: - Body
    var body: some View {
        VStack(spacing: 25) {
            Spacer() // Pushes content towards vertical center

            Image(systemName: iconNameForCurrentState)
                .font(.system(size: 70, weight: .light))
                .foregroundColor(iconColorForCurrentState)
                .padding(.bottom, 15)
                .animation(.easeInOut, value: permissionGranted) // Animate icon/color changes

            Text("Stay Notified")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("Novelty sends you one delightful surprise each day. Enable notifications so you don't miss out on your daily moment of discovery!")
                .font(.system(size: 17, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            // Conditional UI for the button and feedback messages
            if !permissionRequested {
                Button {
                    requestNotificationPermission()
                } label: {
                    Text("Enable Notifications")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                // Feedback after permission has been requested
                if permissionGranted == true {
                    VStack(spacing: 10) {
                        Text("Awesome! Notifications are enabled. 🎉")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.green)
                        Text("Get ready for your daily novelties!")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                } else if permissionGranted == false {
                    VStack(spacing: 10) {
                        Text("Notifications Currently Disabled")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.orange)
                        Text("To receive daily novelties, please enable notifications for Novelty in your iPhone's Settings app.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Open Settings") {
                            openAppSettings()
                        }
                        .padding(.top, 5)
                        .buttonStyle(.bordered)
                    }
                } else { // permissionRequested is true, but permissionGranted is nil (should be brief)
                    Text("Checking permission status...")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            Spacer()
        }
        .padding(30)
        .onAppear {
            // Only check initial system status if states weren't set by a preview initializer
            // (i.e., if we used the main init where permissionGranted starts as nil and requested is false)
            if self.permissionGranted == nil && self.permissionRequested == false {
                 checkInitialNotificationStatus()
            }
        }
    }

    // MARK: - Private Helper Methods

    /// Checks the current notification authorization status when the view appears.
    private func checkInitialNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    self.permissionGranted = true
                    self.permissionRequested = true
                case .denied:
                    self.permissionGranted = false
                    self.permissionRequested = true
                case .notDetermined:
                    self.permissionGranted = nil
                    self.permissionRequested = false
                case .provisional, .ephemeral:
                    self.permissionGranted = true // Or handle as appropriate
                    self.permissionRequested = true
                @unknown default:
                    self.permissionGranted = nil
                    self.permissionRequested = false
                }
            }
        }
    }

    /// Requests notification permission using the NotificationScheduler instance.
    private func requestNotificationPermission() {
        notificationScheduler.requestNotificationAuthorization { granted, error in
            self.permissionGranted = granted
            self.permissionRequested = true

            if granted {
                notificationScheduler.setupTodaysNoveltyNotification()
            }
            
            if let error = error {
                print("NotificationsPermissionStepView: Authorization request error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Opens the app's settings in the system Settings app.
    private func openAppSettings() {
        if let appSettingsUrl = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(appSettingsUrl) {
            UIApplication.shared.open(appSettingsUrl)
        }
    }

    // MARK: - Computed Properties for UI
    
    /// Determines the icon name based on the permission state.
    private var iconNameForCurrentState: String {
        if !permissionRequested && permissionGranted == nil {
            return "bell.square.fill"
        }
        return permissionGranted == true ? "bell.and.waves.left.and.right.fill" : "bell.slash.circle.fill"
    }

    /// Determines the icon color based on the permission state.
    private var iconColorForCurrentState: Color {
        if !permissionRequested && permissionGranted == nil {
            return .accentColor
        }
        return permissionGranted == true ? .green : .orange
    }
}

// MARK: - Preview Provider
struct NotificationsPermissionStepView_Previews: PreviewProvider {
    // Create a static UserProfileManager for the preview
    static var previewUserProfileManager: UserProfileManager = {
        let manager = UserProfileManager() // Or UserProfileManager.preview if you have one
        // Configure manager.userProfile if NotificationsPermissionStepView depends on it for some reason
        return manager
    }()
    
    // Create a static NotificationScheduler for the preview
    static var previewNotificationScheduler = NotificationScheduler(userProfileManager: previewUserProfileManager)

    static var previews: some View {
        Group {
            // Uses the main init(); state will be influenced by .onAppear's checkInitialNotificationStatus
            NotificationsPermissionStepView(notificationScheduler: previewNotificationScheduler)
                .previewDisplayName("Initial State (Live Check)")

            // Uses the DEBUG init to force a specific state for preview
            NotificationsPermissionStepView(
                notificationScheduler: previewNotificationScheduler,
                permissionRequested: true,
                permissionGranted: true
            )
            .previewDisplayName("Permission Granted (Forced)")
            
            NotificationsPermissionStepView(
                notificationScheduler: previewNotificationScheduler,
                permissionRequested: true,
                permissionGranted: false
            )
            .previewDisplayName("Permission Denied (Forced)")
            
            NotificationsPermissionStepView(
                notificationScheduler: previewNotificationScheduler,
                permissionRequested: false,
                permissionGranted: nil
            )
            .previewDisplayName("Not Yet Requested (Forced)")
        }
    }
}
