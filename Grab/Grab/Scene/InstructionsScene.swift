//
//  InstructionsScene.swift
//  Grab
//
//  Created by Zhao on 2025/12/27.
//

import SpriteKit
import UIKit

/// Game instructions scene
class InstructionsScene: SKScene {
    
    private var backgroundNode: SKSpriteNode!
    private var overlayNode: SKShapeNode!
    private var titleLabel: SKLabelNode!
    private var backButton: SKShapeNode!
    private var scrollNode: SKNode!
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupOverlay()
        setupUI()
        displayInstructions()
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
        titleLabel.text = "How to Play"
        titleLabel.fontSize = 25
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - GameConstants.topSafeAreaHeight)
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
    
    private func displayInstructions() {
        let instructions = [
            "Game Objective",
            "Catch the falling mahjong tiles of Sticks to score points!",
            "",
            "Controls",
            "• Tap and hold the LEFT arrow to move left",
            "• Tap and hold the RIGHT arrow to move right",
            "• Use the catcher bar at the bottom to catch tiles",
            "",
            "Scoring",
            "• Catch Sticks tiles: +10 points",
            "• Catch Character or Dots tiles: -5 points",
            "",
            "Tips",
            "• Only catch the target Sticks tiles",
            "• Avoid catching Character or Dots tiles to prevent losing points",
            "• Your highest score will be saved automatically",
            "",
            "Good luck and have fun!"
        ]
        
        // Debug: Print screen size
        print("📱 InstructionsScene - Screen size: \(size.width) x \(size.height)")
        
        let startY = size.height - GameConstants.topSafeAreaHeight - 80
        var currentY = startY
        let lineSpacing: CGFloat = 18
        // Set margins to 18 as requested
        let leftMargin: CGFloat = 18
        let rightMargin: CGFloat = 18
        let maxWidth = size.width - leftMargin - rightMargin
        
        // Debug: Print layout info
        print("📐 Layout - Left margin: \(leftMargin), Right margin: \(rightMargin)")
        print("📐 Layout - Max width: \(maxWidth), Start Y: \(startY)")
        
        for (index, instruction) in instructions.enumerated() {
            if instruction.isEmpty {
                currentY -= lineSpacing / 2
                continue
            }
            
            let isTitle = instruction == "Game Objective" || 
                         instruction == "Controls" || 
                         instruction == "Scoring" || 
                         instruction == "Tips"
            
            let fontSize: CGFloat = isTitle ? 22 : 17
            let fontName = isTitle ? "AvenirNext-Bold" : "AvenirNext-Regular"
            
            // Use UIKit to calculate accurate text size
            let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: isTitle ? UIColor.yellow : UIColor.white
            ]
            
            let attributedString = NSAttributedString(string: instruction, attributes: attributes)
            let textRect = attributedString.boundingRect(
                with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
            
            let textWidth = ceil(textRect.width)
            let textHeight = ceil(textRect.height)
            
            // Debug: Print text info
            print("📝 Text [\(index)]: \"\(instruction.prefix(30))...\"")
            print("   Font size: \(fontSize), Text width: \(textWidth), Text height: \(textHeight)")
            print("   Max width: \(maxWidth), Fits: \(textWidth <= maxWidth)")
            
            // Create label with accurate size
            let label = SKLabelNode(fontNamed: fontName)
            label.text = instruction
            label.fontSize = fontSize
            label.fontColor = isTitle ? SKColor.yellow : SKColor.white
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .top
            label.numberOfLines = 0
            label.preferredMaxLayoutWidth = maxWidth
            
            // Calculate position: screen left edge + left margin
            // In SpriteKit, scene origin is at center, so:
            // Screen left edge = -size.width / 2
            // Text left edge should be at: screen left + margin
            let screenLeftEdge = -size.width / 2
            let screenLeftBound = screenLeftEdge + leftMargin
            
            // SKLabelNode with .left alignment: position.x is where text starts
            // However, there may be internal padding, so we add a small buffer
            // Use a more conservative approach: ensure text is well within bounds
            let buffer: CGFloat = 5 // Additional buffer to ensure text doesn't touch edge
            let textX = screenLeftBound + buffer
            
            label.position = CGPoint(x: textX, y: currentY)
            
            // Add to scene
            scrollNode.addChild(label)
            
            // Debug: Print position info
            print("   Screen left: \(screenLeftEdge), Screen left bound: \(screenLeftBound)")
            print("   Position: x=\(textX), y=\(currentY)")
            print("   Expected text left edge: \(textX)")
            print("   Screen bounds: left=\(screenLeftEdge), right=\(size.width/2)")
            
            currentY -= textHeight + lineSpacing
        }
        
        print("✅ Instructions display completed. Total items: \(instructions.count)")
        
        // Add fade-in animation
        scrollNode.alpha = 0
        scrollNode.run(SKAction.fadeIn(withDuration: 0.5))
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
        }
    }
    
    private func returnToMenu() {
        let transition = SKTransition.fade(withDuration: 0.5)
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = .aspectFill
        view?.presentScene(menuScene, transition: transition)
    }
}

