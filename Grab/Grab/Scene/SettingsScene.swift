//
//  SettingsScene.swift
//  Grab
//
//  Created by Zhao on 2026/05/18.
//

import SpriteKit
import StoreKit

/// 设置页面
class SettingsScene: SKScene {
    
    private var backgroundNode: SKSpriteNode!
    private var overlayNode: SKShapeNode!
    private var backButton: SKShapeNode!
    private var difficultyButtons: [SKNode] = []
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupOverlay()
        setupUI()
    }
    
    private func setupBackground() {
        backgroundNode = SKSpriteNode(imageNamed: "grabBackgroundImage")
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.size = size
        backgroundNode.zPosition = -1
        addChild(backgroundNode)
    }
    
    private func setupOverlay() {
        overlayNode = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        overlayNode.fillColor = SKColor.black
        overlayNode.alpha = GameConstants.overlayOpacity
        overlayNode.zPosition = 0
        addChild(overlayNode)
    }
    
    private func setupUI() {
        // Title Label
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Settings"
        titleLabel.fontSize = 36
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - GameConstants.topSafeAreaHeight - 40)
        titleLabel.zPosition = 10
        addChild(titleLabel)
        
        // Back Button
        backButton = createBackButton()
        addChild(backButton)
        
        // Difficulty Section
        let diffTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        diffTitle.text = "Difficulty"
        diffTitle.fontSize = 24
        diffTitle.fontColor = SKColor.lightGray
        diffTitle.position = CGPoint(x: size.width / 2, y: size.height - 250)
        diffTitle.zPosition = 10
        addChild(diffTitle)
        
        // Difficulty Buttons
        let difficulties: [GameDifficulty] = [.easy, .normal, .hard]
        let currentDiff = GameSettingsManager.shared.currentDifficulty
        
        let startY: CGFloat = size.height - 310
        let buttonSpacing: CGFloat = 70
        
        for (index, diff) in difficulties.enumerated() {
            let yPos = startY - CGFloat(index) * buttonSpacing
            let button = createDifficultyButton(diff: diff, isSelected: diff == currentDiff, position: CGPoint(x: size.width / 2, y: yPos))
            difficultyButtons.append(button)
            addChild(button)
        }
        
        // Rate App Button
        let rateButton = createRateButton(position: CGPoint(x: size.width / 2, y: 150))
        addChild(rateButton)
    }
    
    private func createBackButton() -> SKShapeNode {
        let buttonSize: CGFloat = 50
        let button = SKShapeNode(circleOfRadius: buttonSize / 2)
        button.fillColor = SKColor(white: 0.3, alpha: 0.8)
        button.strokeColor = SKColor.white
        button.lineWidth = 2
        button.position = CGPoint(x: GameConstants.screenMargin + buttonSize / 2, y: size.height - GameConstants.topSafeAreaHeight + buttonSize / 2)
        button.zPosition = 10
        button.name = "backButton"
        
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: -8, y: 0))
        arrowPath.addLine(to: CGPoint(x: 8, y: -8))
        arrowPath.addLine(to: CGPoint(x: 8, y: 8))
        arrowPath.closeSubpath()
        
        let arrow = SKShapeNode(path: arrowPath)
        arrow.fillColor = SKColor.white
        arrow.strokeColor = SKColor.white
        arrow.lineWidth = 1
        button.addChild(arrow)
        
        return button
    }
    
    private func createDifficultyButton(diff: GameDifficulty, isSelected: Bool, position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 10
        container.name = "diff_\(diff.rawValue)"
        
        let width: CGFloat = 200
        let height: CGFloat = 50
        
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 10)
        bg.fillColor = isSelected ? SKColor.systemBlue : SKColor(white: 0.3, alpha: 0.8)
        bg.strokeColor = isSelected ? SKColor.white : SKColor.gray
        bg.lineWidth = 2
        bg.name = "diffBg"
        container.addChild(bg)
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = diff.rawValue
        label.fontSize = 22
        label.fontColor = isSelected ? SKColor.white : SKColor.lightGray
        label.verticalAlignmentMode = .center
        label.name = "diffLabel"
        container.addChild(label)
        
        return container
    }
    
    private func createRateButton(position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 10
        container.name = "rateButton"
        
        let width: CGFloat = 200
        let height: CGFloat = 50
        
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 10)
        bg.fillColor = SKColor.systemPink
        bg.strokeColor = SKColor.white
        bg.lineWidth = 2
        container.addChild(bg)
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Rate App ⭐"
        label.fontSize = 22
        label.fontColor = SKColor.white
        label.verticalAlignmentMode = .center
        container.addChild(label)
        
        return container
    }
    
    private func updateDifficultySelection(selectedDiff: GameDifficulty) {
        GameSettingsManager.shared.currentDifficulty = selectedDiff
        
        for button in difficultyButtons {
            guard let diffRaw = button.name?.replacingOccurrences(of: "diff_", with: ""),
                  let bg = button.childNode(withName: "diffBg") as? SKShapeNode,
                  let label = button.childNode(withName: "diffLabel") as? SKLabelNode else { continue }
            
            let isSelected = (diffRaw == selectedDiff.rawValue)
            bg.fillColor = isSelected ? SKColor.systemBlue : SKColor(white: 0.3, alpha: 0.8)
            bg.strokeColor = isSelected ? SKColor.white : SKColor.gray
            label.fontColor = isSelected ? SKColor.white : SKColor.lightGray
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "backButton" || node.parent?.name == "backButton" {
                let transition = SKTransition.fade(withDuration: 0.5)
                let menuScene = MenuScene(size: size)
                menuScene.scaleMode = .aspectFill
                view?.presentScene(menuScene, transition: transition)
                return
            }
            
            if let name = node.name, name.hasPrefix("diff_") {
                let diffStr = name.replacingOccurrences(of: "diff_", with: "")
                if let diff = GameDifficulty(rawValue: diffStr) {
                    updateDifficultySelection(selectedDiff: diff)
                }
            } else if let parentName = node.parent?.name, parentName.hasPrefix("diff_") {
                let diffStr = parentName.replacingOccurrences(of: "diff_", with: "")
                if let diff = GameDifficulty(rawValue: diffStr) {
                    updateDifficultySelection(selectedDiff: diff)
                }
            }
            
            if node.name == "rateButton" || node.parent?.name == "rateButton" {
                if let scene = view?.window?.windowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }
}
