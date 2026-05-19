//
//  GameRecord.swift
//  Grab
//
//  Created by Zhao on 2025/12/27.
//

import Foundation

/// Game record model to store game history
struct GameRecord: Codable {
    let id: String
    let score: Int
    let date: Date
    let difficulty: GameDifficulty?
    let maxCombo: Int?
    
    init(score: Int, maxCombo: Int? = nil) {
        self.id = UUID().uuidString
        self.score = score
        self.date = Date()
        self.difficulty = GameSettingsManager.shared.currentDifficulty
        self.maxCombo = maxCombo
    }
}

/// Manager for game records storage
class GameDataManager {
    static let shared = GameDataManager()
    private let recordsKey = "MahjongGrabGameRecords"
    
    private init() {}
    
    /// Save a new game record
    func saveRecord(_ record: GameRecord) {
        var records = loadRecords()
        records.append(record)
        // Keep only the latest 100 records
        if records.count > 100 {
            records = Array(records.suffix(100))
        }
        saveRecords(records)
    }
    
    /// Load all game records
    func loadRecords() -> [GameRecord] {
        guard let data = UserDefaults.standard.data(forKey: recordsKey),
              let records = try? JSONDecoder().decode([GameRecord].self, from: data) else {
            return []
        }
        return records.sorted { $0.date > $1.date }
    }
    
    /// Delete a specific record by ID
    func deleteRecord(withId id: String) {
        var records = loadRecords()
        records.removeAll { $0.id == id }
        saveRecords(records)
    }
    
    /// Delete all records
    func deleteAllRecords() {
        UserDefaults.standard.removeObject(forKey: recordsKey)
    }
    
    /// Get highest score
    func getHighestScore() -> Int {
        let records = loadRecords()
        return records.map { $0.score }.max() ?? 0
    }
    
    /// Get highest combo
    func getHighestCombo() -> Int {
        let records = loadRecords()
        return records.compactMap { $0.maxCombo }.max() ?? 0
    }
    
    /// Get total games played
    func getTotalGamesPlayed() -> Int {
        return loadRecords().count
    }
    
    /// Get total score
    func getTotalScore() -> Int {
        let records = loadRecords()
        return records.reduce(0) { $0 + $1.score }
    }
    
    private func saveRecords(_ records: [GameRecord]) {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }
}

