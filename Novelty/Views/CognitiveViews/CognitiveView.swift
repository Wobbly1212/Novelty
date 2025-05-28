//
//  Untitled.swift
//  Novelty
//
//  Created by Fabio on 21/05/25.
//

import SwiftUI

struct CognitiveView: View {
    @EnvironmentObject var manager: NoveltyManager
    @State private var noveltytime: Double = Double.infinity
    
    @AppStorage("onboarding") var onboarding: Bool = false
    @AppStorage("NextNoveltyId") var NextNoveltyId: String = ""
    @AppStorage("NextNoveltyTime") var NextNoveltyTime: Double = Double.infinity
    var body: some View {
        NavigationStack {
            
            Text("Cognitive Novelty")
            Text(manager.todayNovelty?.title ?? "No Novelty")
            HStack {
                Button("Discard") {
                    manager.discardTodayNovelty()
                    print("Novelty Discarded", NextNoveltyTime, NextNoveltyId)
                }.buttonStyle(.borderedProminent)
                Button("Accept") {
                    manager.acceptTodayNovelty()
                    manager.doTodayNovelty()
                    print("Novelty accepted and done", NextNoveltyTime, NextNoveltyId)
                }.buttonStyle(.borderedProminent)
                Button("Delay") {
                    print("Notification Delayed", NextNoveltyTime, NextNoveltyId)
                }.buttonStyle(.borderedProminent)
            }
            
            Button("Reset") {
                onboarding = false
                NextNoveltyId = ""
                NextNoveltyTime = Double.infinity
            }
            .buttonStyle(.borderedProminent)
        }.onAppear {
            noveltytime = NextNoveltyTime
        }
        .onChange(of: NextNoveltyTime) { newValue in
            noveltytime = newValue
        }
    }
}

