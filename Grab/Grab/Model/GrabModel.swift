//
//  GrabModel.swift
//  Grab
//
//  Created by Zhao on 2025/12/27.
//

import UIKit
import SpriteKit

/// Mahjong tile model
struct GrabMj {
    var grabImage: UIImage?
    var grabValue: Int? // Mahjong value
    var imageName: String // Image asset name
    var type: String // Type identifier (aimage, bimage, images)
    
    init(imageName: String, grabValue: Int, type: String) {
        self.imageName = imageName
        self.grabValue = grabValue
        self.type = type
        self.grabImage = UIImage(named: imageName)
    }
    
    /// Check if this is the target type to catch
    var isTarget: Bool {
        return type == GameConstants.targetMahjongType
    }
    
    /// Get display name for the mahjong type
    var displayName: String {
        switch type {
        case "aimage":
            return "Sticks"
        case "bimage":
            return "Character"
        case "images":
            return "Dots"
        default:
            return "Unknown"
        }
    }
}

//将 Type A 改为Sticks；  Type B 改为：Character； Type C 改为Dots
  
/// Collection of all mahjong tiles
struct MahjongTiles {
    static let allTiles: [GrabMj] = {
        var tiles: [GrabMj] = []
        
        // Type A tiles (target type) 改为Sticks
        for i in 0...8 {
            tiles.append(GrabMj(imageName: "aimage \(i)", grabValue: i + 1, type: "aimage"))
        }
        
        // Type B tiles 改为Character
        for i in 0...8 {
            tiles.append(GrabMj(imageName: "bimage \(i)", grabValue: i + 1, type: "bimage"))
        }
        
        // Type C tiles 改为Dots
        for i in 0...8 {
            tiles.append(GrabMj(imageName: "images \(i)", grabValue: i + 1, type: "images"))
        }
        
        return tiles
    }()
    
    /// Get a random mahjong tile
    static func randomTile() -> GrabMj {
        return allTiles.randomElement() ?? allTiles[0]
    }
    
    /// Get a random tile of specific type
    static func randomTile(ofType type: String) -> GrabMj? {
        let filtered = allTiles.filter { $0.type == type }
        return filtered.randomElement()
    }
}
