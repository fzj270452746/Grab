//
//  MenuScene.swift
//  Grab
//
//  Created by Zhao on 2025/12/27.
//

import SpriteKit
import UIKit

/// Main menu scene
class MenuScene: SKScene {
    
    private var backgroundNode: SKSpriteNode!
    private var overlayNode: SKShapeNode!
    private var playButton: SKNode!
    private var recordsButton: SKNode!
    private var instructionsButton: SKNode!
    private var settingsButton: SKNode!
    private var statisticsButton: SKNode!
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupOverlay()
        setupButtons()
        setupIconButtons()
        addAnimations()
    }
    
    // MARK: - Setup Methods
    
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
    
    private func setupButtons() {
        let buttonHeight: CGFloat = 50
        let buttonWidth: CGFloat = 250
        let buttonSpacing: CGFloat = 15
        let startY = size.height * 0.5
        
        // Play Button - Dark blue
        playButton = createButton(
            text: "Play Game",
            width: buttonWidth,
            height: buttonHeight,
            position: CGPoint(x: size.width / 2, y: startY),
            color: SKColor(red: 0.15, green: 0.25, blue: 0.4, alpha: 0.95)
        )
        playButton.name = "playButton"
        addChild(playButton)
        
        // Records Button - Dark purple
        recordsButton = createButton(
            text: "Game Records",
            width: buttonWidth,
            height: buttonHeight,
            position: CGPoint(x: size.width / 2, y: startY - (buttonHeight + buttonSpacing)),
            color: SKColor(red: 0.3, green: 0.15, blue: 0.35, alpha: 0.95)
        )
        recordsButton.name = "recordsButton"
        addChild(recordsButton)
        
        // Instructions Button - Dark green
        instructionsButton = createButton(
            text: "How to Play",
            width: buttonWidth,
            height: buttonHeight,
            position: CGPoint(x: size.width / 2, y: startY - (buttonHeight + buttonSpacing) * 2),
            color: SKColor(red: 0.15, green: 0.35, blue: 0.25, alpha: 0.95)
        )
        instructionsButton.name = "instructionsButton"
        addChild(instructionsButton)
    }
    
    private func setupIconButtons() {
        let buttonSize: CGFloat = 50
        let rightMargin = size.width - GameConstants.screenMargin - buttonSize / 2
        let topY = size.height - GameConstants.topSafeAreaHeight + buttonSize / 2
        
        settingsButton = createIconButton(imageName: "设置图片", name: "settingsButton")
        settingsButton.position = CGPoint(x: rightMargin, y: topY)
        addChild(settingsButton)
        
        statisticsButton = createIconButton(imageName: "统计图片", name: "statisticsButton")
        statisticsButton.position = CGPoint(x: rightMargin - buttonSize - 15, y: topY)
        addChild(statisticsButton)
    }
    
    private func createIconButton(imageName: String, name: String) -> SKShapeNode {
        let buttonSize: CGFloat = 50
        let button = SKShapeNode(circleOfRadius: buttonSize / 2)
        button.fillColor = SKColor(white: 0.3, alpha: 0.8)
        button.strokeColor = SKColor.white
        button.lineWidth = 2
        button.zPosition = 10
        button.name = name
        
        let sprite = SKSpriteNode(imageNamed: imageName)
        // 根据情况调整图标大小
        sprite.size = CGSize(width: 28, height: 28)
        sprite.position = .zero
        button.addChild(sprite)
        
        return button
    }
    
    private func createButton(text: String, width: CGFloat, height: CGFloat, position: CGPoint, color: SKColor = SKColor.systemBlue) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 1
        
        // Main button background with gradient effect
        let button = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 15)
        button.fillColor = color
        button.strokeColor = SKColor.white
        button.lineWidth = 3
        button.glowWidth = 2
        container.addChild(button)
        
        // Add inner highlight for depth
        let innerHighlight = SKShapeNode(rectOf: CGSize(width: width - 6, height: height - 6), cornerRadius: 12)
        innerHighlight.fillColor = SKColor.white.withAlphaComponent(0.2)
        innerHighlight.strokeColor = SKColor.clear
        innerHighlight.position = CGPoint(x: 0, y: 2)
        container.addChild(innerHighlight)
        
        // Add shadow effect
        let shadow = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 15)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.3)
        shadow.strokeColor = SKColor.clear
        shadow.position = CGPoint(x: 3, y: -3)
        shadow.zPosition = -1
        container.addChild(shadow)
        
        // Button label
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 26
        label.fontColor = SKColor.white
        label.verticalAlignmentMode = .center
        label.zPosition = 2
        container.addChild(label)
        
        return container
    }
    
    private func addAnimations() {
        // Button hover effect
        let buttonScale = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        
        playButton.run(SKAction.repeatForever(buttonScale))
        recordsButton.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                buttonScale
            ])
        ))
        instructionsButton.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.4),
                buttonScale
            ])
        ))
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if let buttonName = node.name {
                handleButtonTap(buttonName)
            } else if let parent = node.parent, let buttonName = parent.name {
                handleButtonTap(buttonName)
            }
        }
    }
    
    // Helper method to find the view controller from SKView
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = view
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    private func handleButtonTap(_ buttonName: String) {
        let transition = SKTransition.fade(withDuration: 0.5)
        
        switch buttonName {
        case "playButton":
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: transition)
            
        case "recordsButton":
            let recordsScene = RecordsScene(size: size)
            recordsScene.scaleMode = .aspectFill
            view?.presentScene(recordsScene, transition: transition)
            
        case "statisticsButton":
            let statisticsScene = StatisticsScene(size: size)
            statisticsScene.scaleMode = .aspectFill
            view?.presentScene(statisticsScene, transition: transition)
            
        case "settingsButton":
            let settingsScene = SettingsScene(size: size)
            settingsScene.scaleMode = .aspectFill
            view?.presentScene(settingsScene, transition: transition)
            
        case "instructionsButton":
            // Present UIViewController instead of SpriteKit scene
            if let viewController = findViewController() {
                let instructionsVC = InstructionsViewController()
                instructionsVC.modalPresentationStyle = .fullScreen
                instructionsVC.modalTransitionStyle = .crossDissolve
                viewController.present(instructionsVC, animated: true, completion: nil)
            }
            
        default:
            break
        }
    }
}

