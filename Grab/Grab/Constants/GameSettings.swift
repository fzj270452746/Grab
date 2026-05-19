//
//  GameSettings.swift
//  Grab
//
//  Created by Zhao on 2026/05/18.
//

import Foundation

/// 难度级别枚举
enum GameDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    
    var fallSpeedMultiplier: CGFloat {
        switch self {
        case .easy: return 0.8
        case .normal: return 1.0
        case .hard: return 1.5
        }
    }
    
    var spawnIntervalMultiplier: TimeInterval {
        switch self {
        case .easy: return 1.2
        case .normal: return 1.0
        case .hard: return 0.7
        }
    }
}

/// 游戏设置管理器
class GameSettingsManager {
    static let shared = GameSettingsManager()
    private let difficultyKey = "MahjongGrabDifficulty"
    
    private init() {}
    
    /// 获取当前难度
    var currentDifficulty: GameDifficulty {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: difficultyKey),
                  let difficulty = GameDifficulty(rawValue: rawValue) else {
                return .normal
            }
            return difficulty
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: difficultyKey)
        }
    }
}
