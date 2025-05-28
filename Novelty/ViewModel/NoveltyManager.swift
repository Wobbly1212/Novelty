//
//  NoveltyManager.swift
//  Novelty
//
//  Created by Fabio on 21/05/25.
//

import Foundation
import SwiftUI
class NoveltyManager: ObservableObject {
    @Published var todayNovelty: Novelty?
    @Published var history: [Novelty] = []
    private(set) var allNovelties: [Novelty] = []
    @AppStorage("NextNoveltyId") var NextNoveltyId: String = ""
    @AppStorage("CurrentNoveltyStatus") var CurrentNoveltyStatus: NoveltyStatus = .proposed
    
    private let historyURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("novelty_history.json")
    
    init() {
        loadNovelties()
        loadHistory()
        loadTodayNovelty()
    }
    
    private func loadNovelties() {
        guard let url = Bundle.main.url(forResource: "novelties", withExtension: "json") else {
                print("Error: novelties.json not found in bundle.")
                return
            }
            do {
                let data = try Data(contentsOf: url)
                let decodedNovelties = try JSONDecoder().decode([Novelty].self, from: data)
                self.allNovelties = decodedNovelties
                print("Loaded \(decodedNovelties.count) novelties from novelties.json")
            } catch {
                print("Failed to decode novelties.json: \(error)")
            }
        print(self.allNovelties.first!.title)
        }

        private func loadHistory() {
            if let data = try? Data(contentsOf: historyURL),
               let saved = try? JSONDecoder().decode([Novelty].self, from: data) {
                self.history = saved
            } else {
                self.history = []
            }
        }

        private func saveHistory() {
            if let data = try? JSONEncoder().encode(history) {
                try? data.write(to: historyURL)
            }
        }
    
        private func loadTodayNovelty() {
            self.todayNovelty = allNovelties.first {$0.id == NextNoveltyId}
            self.todayNovelty?.status = CurrentNoveltyStatus
        }

        func proposeNewNovelty() {
            var novelty = allNovelties.randomElement()!
            novelty.createdAt = Date()
            novelty.status = .proposed
            CurrentNoveltyStatus = .proposed
            todayNovelty = novelty
            NextNoveltyId = novelty.id
        }
    
        func acceptTodayNovelty() {
            todayNovelty?.status = .accepted
            CurrentNoveltyStatus = .accepted
        }
    
        func discardTodayNovelty() {
            proposeNewNovelty()
        }
    
        func doTodayNovelty() {
            todayNovelty?.status = .completed
            CurrentNoveltyStatus = .completed
            history.append(todayNovelty!)
            saveHistory()
            proposeNewNovelty()
        }
}
