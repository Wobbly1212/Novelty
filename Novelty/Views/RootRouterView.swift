//
//  RootRouterView.swift
//  Novelty
//
//  Created by Fabio on 22/05/25.
//  Updated by YourTeam on May 23, 2025.
//

import SwiftUI

struct RootRouterView: View {
    @Binding var hasCompletedOnboarding: Bool

    @EnvironmentObject var noveltyContentManager: NoveltyManager
    @EnvironmentObject var timeManager: TimeManager
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var dndAwareNotificationManager: NotificationScheduler

    @AppStorage("NextNoveltyId") var nextNoveltyId: String = ""
    @AppStorage("NextNoveltyTime") var nextNoveltyTime: Double = Double.infinity

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                if timeManager.currentTime >= Date(timeIntervalSince1970: nextNoveltyTime) {
                    if let _ = noveltyContentManager.todayNovelty {
                        NoveltyRouterView()
                    } else {
                        VStack {
                            Text("Loading today's novelty...")
                                .font(.title2)
                            ProgressView()
                                .padding()
                            Text("If this persists, please check back later.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    MainView()
                }
            } else {
                OnboardingView(
                    notificationManager: dndAwareNotificationManager,
                    onOnboardingComplete: {
                        self.hasCompletedOnboarding = true
                    }
                )
            }
        }
        .onAppear {
            if hasCompletedOnboarding {
                dndAwareNotificationManager.setupTodaysNoveltyNotification()
            }
        }
    }
}


