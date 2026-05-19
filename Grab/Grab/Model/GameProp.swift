//
//  GameProp.swift
//  Grab
//
//  Created by Zhao on 2026/05/18.
//

import UIKit
import SpriteKit

/// 游戏道具类型
enum GamePropType: String {
    case magnet = "Magnet" // 磁铁：吸附目标
    case slowMotion = "SlowMotion" // 减速：全局减速
    case shield = "Shield" // 护盾：抵消一次错误
    case bomb = "Bomb" // 炸弹：扣除生命值或大量分数
    
    var color: SKColor {
        switch self {
        case .magnet: return .blue
        case .slowMotion: return .cyan
        case .shield: return .green
        case .bomb: return .black
        }
    }
    
    var emoji: String {
        switch self {
        case .magnet: return "🧲"
        case .slowMotion: return "⏱️"
        case .shield: return "🛡️"
        case .bomb: return "💣"
        }
    }
}

/// 游戏道具模型
struct GameProp {
    var type: GamePropType
    
    static func randomProp() -> GameProp {
        let types: [GamePropType] = [.magnet, .slowMotion, .shield, .bomb]
        return GameProp(type: types.randomElement()!)
    }
}
