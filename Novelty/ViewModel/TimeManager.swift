//
//  TimeManager.swift
//  Novelty
//
//  Created by Fabio on 22/05/25.
//

import Foundation
import Combine

class TimeManager: ObservableObject {
    @Published var currentTime: Date = Date()
    private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var cancellables = Set<AnyCancellable>()

    init() {
        timer
            .sink { [weak self] date in
                self?.currentTime = date
            }
            .store(in: &cancellables)
    }
}
