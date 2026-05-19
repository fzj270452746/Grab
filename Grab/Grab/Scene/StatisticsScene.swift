//
//  StatisticsScene.swift
//  Grab
//
//  Created by Zhao on 2026/05/18.
//

import SpriteKit

/// 数据统计页面
class StatisticsScene: SKScene {
    
    private var backgroundNode: SKSpriteNode!
    private var overlayNode: SKShapeNode!
    private var backButton: SKShapeNode!
    
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
        titleLabel.text = "Statistics"
        titleLabel.fontSize = 36
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - GameConstants.topSafeAreaHeight - 40)
        titleLabel.zPosition = 10
        addChild(titleLabel)
        
        // Back Button
        backButton = createBackButton()
        addChild(backButton)
        
        // Stat Items
        let dataManager = GameDataManager.shared
        
        let stats = [
            ("Total Games Played", "\(dataManager.getTotalGamesPlayed())"),
            ("Highest Score", "\(dataManager.getHighestScore())"),
            ("Highest Combo", "\(dataManager.getHighestCombo())"),
            ("Total Score Earned", "\(dataManager.getTotalScore())")
        ]
        
        let startY = size.height - 250
        let spacing: CGFloat = 80
        
        for (index, stat) in stats.enumerated() {
            let yPos = startY - CGFloat(index) * spacing
            createStatRow(title: stat.0, value: stat.1, position: CGPoint(x: size.width / 2, y: yPos))
        }
    }
    
    private func createStatRow(title: String, value: String, position: CGPoint) {
        let container = SKNode()
        container.position = position
        container.zPosition = 10
        
        let bg = SKShapeNode(rectOf: CGSize(width: size.width - 60, height: 60), cornerRadius: 10)
        bg.fillColor = SKColor(white: 0.2, alpha: 0.8)
        bg.strokeColor = SKColor.gray
        bg.lineWidth = 1
        container.addChild(bg)
        
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        titleLabel.text = title
        titleLabel.fontSize = 20
        titleLabel.fontColor = SKColor.lightGray
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -size.width / 2 + 50, y: 0)
        container.addChild(titleLabel)
        
        let valueLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        valueLabel.text = value
        valueLabel.fontSize = 24
        valueLabel.fontColor = SKColor.yellow
        valueLabel.horizontalAlignmentMode = .right
        valueLabel.verticalAlignmentMode = .center
        valueLabel.position = CGPoint(x: size.width / 2 - 50, y: 0)
        container.addChild(valueLabel)
        
        addChild(container)
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
        }
    }
}
