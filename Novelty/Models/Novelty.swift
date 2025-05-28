//
//  Novelry.swift
//  Novelty
//
//  Created by Fabio on 21/05/25.
//
import Foundation

enum NoveltyCategory: String, Codable {
    case sensory, motor, digital, cognitive
}

enum NoveltyStatus: String, Codable {
    case proposed
    case accepted
    case completed
    case delayed
    case discarded
}

struct Novelty: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let category: NoveltyCategory
    var status: NoveltyStatus?
    var createdAt: Date?
}
