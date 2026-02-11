//
//  QuizHistoryStore.swift
//  PersonalityQuiz
//
//  Created by Zainab on 2/11/26.
//

import Foundation

struct QuizHistoryEntry: Codable {
    let id: UUID
    let date: Date
    let quizTitle: String
    let resultEmoji: String
    let isTimed: Bool
    let timeLimitSeconds: Int?
    let elapsedSeconds: Double?
}

enum QuizHistoryStore {
    private static let key = "quizHistoryEntries"

    static func load() -> [QuizHistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let entries = try? decoder.decode([QuizHistoryEntry].self, from: data) {
            return entries
        }
        return []
    }

    static func save(_ entries: [QuizHistoryEntry]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func add(_ entry: QuizHistoryEntry) {
        var entries = load()
        entries.insert(entry, at: 0)
        save(entries)
    }
}
