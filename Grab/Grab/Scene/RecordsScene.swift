//
//  RecordsScene.swift
//  Grab
//
//  Created by Zhao on 2025/12/27.
//

import SpriteKit

/// Game records scene
class RecordsScene: SKScene {
    
    private var backgroundNode: SKSpriteNode!
    private var overlayNode: SKShapeNode!
    private var titleLabel: SKLabelNode!
    private var backButton: SKShapeNode!
    private var scrollNode: SKNode!
    private var records: [GameRecord] = []
    private var recordNodes: [SKNode] = []
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupOverlay()
        setupUI()
        loadRecords()
        displayRecords()
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
    
    private func setupUI() {
        // Title
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Game Records"
        titleLabel.fontSize = 22
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - GameConstants.topSafeAreaHeight - 40)
        titleLabel.zPosition = 10
        addChild(titleLabel)
        
        // Back Button
        backButton = createBackButton()
        addChild(backButton)
        
        // Scroll container
        scrollNode = SKNode()
        scrollNode.zPosition = 5
        addChild(scrollNode)
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
    
    private func loadRecords() {
        records = GameDataManager.shared.loadRecords()
    }
    
    private func displayRecords() {
        // Clear existing records
        recordNodes.forEach { $0.removeFromParent() }
        recordNodes.removeAll()
        
        if records.isEmpty {
            showEmptyMessage()
            return
        }
        
        let startY = size.height - GameConstants.topSafeAreaHeight - 110
        let itemHeight: CGFloat = 75
        let spacing: CGFloat = 12
        
        for (index, record) in records.enumerated() {
            let yPosition = startY - CGFloat(index) * (itemHeight + spacing)
            // Only display records that fit on screen
            if yPosition < -size.height / 2 + 50 {
                break
            }
            let recordNode = createRecordNode(record: record, index: index, yPosition: yPosition)
            scrollNode.addChild(recordNode)
            recordNodes.append(recordNode)
        }
    }
    
    private func createRecordNode(record: GameRecord, index: Int, yPosition: CGFloat) -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: size.width / 2, y: yPosition)
        
        // Background
        let background = SKShapeNode(rectOf: CGSize(width: size.width - GameConstants.screenMargin * 2, height: 70), cornerRadius: 10)
        background.fillColor = SKColor.systemBlue.withAlphaComponent(0.7)
        background.strokeColor = SKColor.white
        background.lineWidth = 2
        container.addChild(background)
        
        // Rank
        let rankLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        rankLabel.text = "#\(index + 1)"
        rankLabel.fontSize = 22
        rankLabel.fontColor = SKColor.white
        rankLabel.horizontalAlignmentMode = .left
        rankLabel.position = CGPoint(x: -size.width / 2 + GameConstants.screenMargin + 25, y: 0)
        container.addChild(rankLabel)
        
        // Score
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: \(record.score)"
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = SKColor.yellow
        scoreLabel.position = CGPoint(x: -60, y: 0)
        container.addChild(scoreLabel)
        
        // Date - Format: "2025 at 15:05"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd HH:mm"
        let dateLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        dateLabel.text = dateFormatter.string(from: record.date)
        dateLabel.fontSize = 16
        dateLabel.fontColor = SKColor.lightGray
        dateLabel.horizontalAlignmentMode = .right
        dateLabel.position = CGPoint(x: size.width / 2 - GameConstants.screenMargin - 70, y: 0)
        container.addChild(dateLabel)
        
        // Delete button
        let deleteButton = SKShapeNode(circleOfRadius: 18)
        deleteButton.fillColor = SKColor.systemRed
        deleteButton.strokeColor = SKColor.white
        deleteButton.lineWidth = 2
        deleteButton.position = CGPoint(x: size.width / 2 - GameConstants.screenMargin - 25, y: 0)
        deleteButton.name = "delete_\(record.id)"
        container.addChild(deleteButton)
        
        let xLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        xLabel.text = "×"
        xLabel.fontSize = 22
        xLabel.fontColor = SKColor.white
        xLabel.verticalAlignmentMode = .center
        deleteButton.addChild(xLabel)
        
        return container
    }
    
    private func showEmptyMessage() {
        let emptyLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        emptyLabel.text = "No game records yet.\nPlay the game to create records!"
        emptyLabel.fontSize = 24
        emptyLabel.fontColor = SKColor.lightGray
        emptyLabel.numberOfLines = 2
        emptyLabel.verticalAlignmentMode = .center
        emptyLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        emptyLabel.zPosition = 5
        scrollNode.addChild(emptyLabel)
        
        // Add pulsing animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 1.0),
            SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        ])
        emptyLabel.run(SKAction.repeatForever(pulse))
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "backButton" || (node.parent?.name == "backButton") {
                returnToMenu()
                return
            }
            
            if let nodeName = node.name, nodeName.hasPrefix("delete_") {
                let recordId = String(nodeName.dropFirst(7))
                deleteRecord(withId: recordId)
                return
            }
            
            if let parent = node.parent, let parentName = parent.name, parentName.hasPrefix("delete_") {
                let recordId = String(parentName.dropFirst(7))
                deleteRecord(withId: recordId)
                return
            }
        }
    }
    
    private func deleteRecord(withId id: String) {
        GameDataManager.shared.deleteRecord(withId: id)
        loadRecords()
        displayRecords()
        
        // Add delete animation
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        scrollNode.run(SKAction.sequence([fadeOut, fadeIn]))
    }
    
    private func returnToMenu() {
        let transition = SKTransition.fade(withDuration: 0.5)
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = .aspectFill
        view?.presentScene(menuScene, transition: transition)
    }
}

