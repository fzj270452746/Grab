//
//  GameConstants.swift
//  Grab
//
//  Created by Zhao on 2025/12/27.
//

import SpriteKit

/// Game constants and configuration
struct GameConstants {
    // MARK: - Gameplay
    static let targetMahjongType = "aimage" // Target type to catch
    static let fallSpeed: CGFloat = 200.0 // Base falling speed
    static let spawnInterval: TimeInterval = 1.5 // Time between spawns
    static let correctCatchScore = 10 // Points for catching correct mahjong
    static let wrongCatchPenalty = -5 // Points penalty for wrong catch
    static let doubleScoreChance: Double = 0.3 // 30% chance for target mahjong to be double score
    
    // MARK: - Mahjong Movement
    static let horizontalMovementRange: CGFloat = 150.0 // Maximum horizontal movement distance
    static let horizontalMovementSpeed: TimeInterval = 1.5 // Base time for one complete horizontal cycle
    static let horizontalMovementStartTime: TimeInterval = 5.0 // Time before horizontal movement starts (seconds)
    static let speedIncreaseInterval: TimeInterval = 5.0 // Time interval between speed increases (seconds)
    static let speedIncreaseRate: Double = 0.01// Speed increase rate per interval (2%)
    static let minHorizontalMovementSpeed: TimeInterval = 0.5 // Minimum speed (fastest movement)
    
    // Calculate how many cycles it takes to reach minimum speed
    // baseSpeed * (0.9 ^ cycles) <= minSpeed
    // cycles >= log(minSpeed / baseSpeed) / log(0.9)
    static let speedCycleLength: Int = {
        let ratio = minHorizontalMovementSpeed / horizontalMovementSpeed
        let cycles = Int(ceil(log(ratio) / log(1.0 - speedIncreaseRate)))
        return max(cycles, 1) // Ensure at least 1 cycle
    }()
    
    // MARK: - Visual
    static let mahjongAspectRatio: CGFloat = 1.0 / 1.43 // Width to height ratio
    static let mahjongCornerRadius: CGFloat = 4.0
    static let mahjongBorderWidth: CGFloat = 2.0
    static let mahjongBorderColor = SKColor.white
    
    // MARK: - Catcher
    static let catcherHeight: CGFloat = 30.0
    static let catcherWidth: CGFloat = 80.0
    static let catcherColor = SKColor.systemBlue
    static let catcherCornerRadius: CGFloat = 8.0
    static let movementSpeed: CGFloat = 300.0
    
    // MARK: - UI Spacing
    static let screenMargin: CGFloat = 20.0
    static let overlayOpacity: CGFloat = 0.7
    static let topSafeAreaHeight: CGFloat = 100.0 // Status bar + Navigation bar height
    
    // MARK: - Animation
    static let catchAnimationDuration: TimeInterval = 0.3
    static let scoreAnimationDuration: TimeInterval = 0.5
    static let particleEffectDuration: TimeInterval = 1.0
}

