//
//  GameScene.swift
//  Grab
//
//  Created by Zhao on 2025/12/27.
//

import SpriteKit

/// Main game scene
class GameScene: SKScene {
    
    // MARK: - Properties
    private var backgroundNode: SKSpriteNode!
    private var overlayNode: SKShapeNode!
    private var catcher: SKNode!
    private var leftArrow: SKSpriteNode!
    private var rightArrow: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var targetLabel: SKLabelNode!
    private var comboLabel: SKLabelNode!
    private var backButton: SKShapeNode!
    private var settingsButton: SKShapeNode!
    private var statisticsButton: SKShapeNode!
    
    private var currentScore: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(currentScore)"
            animateScoreChange()
        }
    }
    
    private var currentCombo: Int = 0 {
        didSet {
            comboLabel.text = currentCombo > 1 ? "Combo x\(currentCombo)" : ""
            if currentCombo > maxCombo {
                maxCombo = currentCombo
            }
        }
    }
    private var maxCombo: Int = 0
    
    private var isSlowMotionActive = false
    private var hasShield = false
    
    private var targetMahjong: GrabMj!
    private var isMovingLeft = false
    private var isMovingRight = false
    private var lastSpawnTime: TimeInterval = 0
    private var gameStartTime: TimeInterval = 0
    
    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        setupScene()
        setupBackground()
        setupOverlay()
        setupUI()
        setupIconButtons()
        setupCatcher()
        setupArrows()
        setupTarget()
        startGame()
    }
    
    override func willMove(from view: SKView) {
        // Clean up when leaving scene
    }
    
    // MARK: - Setup Methods
    
    private func setupScene() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
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
        // Score Label
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 22
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - GameConstants.topSafeAreaHeight - 40)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
        
        // Target Label
        targetLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        targetLabel.text = "Target: Sticks"
        targetLabel.fontSize = 24
        targetLabel.fontColor = SKColor.yellow
        targetLabel.position = CGPoint(x: size.width / 2, y: size.height - GameConstants.topSafeAreaHeight - 80)
        targetLabel.zPosition = 10
        addChild(targetLabel)
        
        // Combo Label
        comboLabel = SKLabelNode(fontNamed: "AvenirNext-BoldItalic")
        comboLabel.text = ""
        comboLabel.fontSize = 30
        comboLabel.fontColor = SKColor.orange
        comboLabel.position = CGPoint(x: size.width / 2, y: size.height - GameConstants.topSafeAreaHeight - 120)
        comboLabel.zPosition = 10
        addChild(comboLabel)
        
        // Back Button
        backButton = createBackButton()
        addChild(backButton)
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
    
    private func createBackButton() -> SKShapeNode {
        let buttonSize: CGFloat = 50
        let button = SKShapeNode(circleOfRadius: buttonSize / 2)
        button.fillColor = SKColor(white: 0.3, alpha: 0.8)
        button.strokeColor = SKColor.white
        button.lineWidth = 2
        button.position = CGPoint(x: GameConstants.screenMargin + buttonSize / 2, y: size.height - GameConstants.topSafeAreaHeight + buttonSize / 2)
        button.zPosition = 10
        button.name = "backButton"
        
        // Arrow icon
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
    
    private func setupCatcher() {
        // Create container node for catcher
        catcher = SKNode()
        catcher.position = CGPoint(x: size.width / 2, y: GameConstants.screenMargin + GameConstants.catcherHeight / 2)
        catcher.zPosition = 5
        
        // Main catcher body with gradient effect
        let mainBody = SKShapeNode(rectOf: CGSize(width: GameConstants.catcherWidth, height: GameConstants.catcherHeight), cornerRadius: GameConstants.catcherCornerRadius)
        mainBody.fillColor = GameConstants.catcherColor
        mainBody.strokeColor = SKColor.white
        mainBody.lineWidth = 3
        mainBody.glowWidth = 2
        catcher.addChild(mainBody)
        
        // Add inner highlight for depth
        let innerHighlight = SKShapeNode(rectOf: CGSize(width: GameConstants.catcherWidth - 4, height: GameConstants.catcherHeight - 4), cornerRadius: GameConstants.catcherCornerRadius - 2)
        innerHighlight.fillColor = SKColor.white.withAlphaComponent(0.3)
        innerHighlight.strokeColor = SKColor.clear
        innerHighlight.position = CGPoint(x: 0, y: 2)
        catcher.addChild(innerHighlight)
        
        // Add shadow effect
        let shadow = SKShapeNode(rectOf: CGSize(width: GameConstants.catcherWidth, height: GameConstants.catcherHeight), cornerRadius: GameConstants.catcherCornerRadius)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.3)
        shadow.strokeColor = SKColor.clear
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        catcher.addChild(shadow)
        
        // Add decorative lines
        for i in 0..<3 {
            let line = SKShapeNode(rectOf: CGSize(width: GameConstants.catcherWidth - 20, height: 2))
            line.fillColor = SKColor.white.withAlphaComponent(0.5)
            line.strokeColor = SKColor.clear
            let spacing = (GameConstants.catcherHeight - 6) / 4
            line.position = CGPoint(x: 0, y: -GameConstants.catcherHeight / 2 + spacing * CGFloat(i + 1))
            catcher.addChild(line)
        }
        
        // Physics body for collision detection
        catcher.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: GameConstants.catcherWidth, height: GameConstants.catcherHeight))
        catcher.physicsBody?.isDynamic = false
        catcher.physicsBody?.categoryBitMask = PhysicsCategory.catcher
        catcher.physicsBody?.contactTestBitMask = PhysicsCategory.mahjong | PhysicsCategory.prop
        
        addChild(catcher)
    }
    
    private func setupArrows() {
        let arrowSize: CGFloat = 50
        let arrowY = GameConstants.screenMargin + GameConstants.catcherHeight + arrowSize / 2 + 15
        
        // Left Arrow
        if let leftImage = UIImage(named: "leftImage") {
            let leftTexture = SKTexture(image: leftImage)
            leftArrow = SKSpriteNode(texture: leftTexture, size: CGSize(width: arrowSize, height: arrowSize))
            leftArrow.position = CGPoint(x: GameConstants.screenMargin + arrowSize / 2, y: arrowY)
            leftArrow.name = "leftArrow"
            leftArrow.zPosition = 5
            
            // Add shadow
            let leftShadow = SKSpriteNode(texture: leftTexture, size: CGSize(width: arrowSize, height: arrowSize))
            leftShadow.color = SKColor.black
            leftShadow.colorBlendFactor = 0.4
            leftShadow.alpha = 0.6
            leftShadow.position = CGPoint(x: 2, y: -2)
            leftShadow.zPosition = -1
            leftArrow.addChild(leftShadow)
            
            // Add glow effect using a white overlay
            let leftGlow = SKSpriteNode(texture: leftTexture, size: CGSize(width: arrowSize + 4, height: arrowSize + 4))
            leftGlow.color = SKColor.white
            leftGlow.colorBlendFactor = 0.3
            leftGlow.alpha = 0.5
            leftGlow.zPosition = -1
            leftArrow.addChild(leftGlow)
            
            addChild(leftArrow)
        }
        
        // Right Arrow
        if let rightImage = UIImage(named: "ringhtImage") {
            let rightTexture = SKTexture(image: rightImage)
            rightArrow = SKSpriteNode(texture: rightTexture, size: CGSize(width: arrowSize, height: arrowSize))
            rightArrow.position = CGPoint(x: size.width - GameConstants.screenMargin - arrowSize / 2, y: arrowY)
            rightArrow.name = "rightArrow"
            rightArrow.zPosition = 5
            
            // Add shadow
            let rightShadow = SKSpriteNode(texture: rightTexture, size: CGSize(width: arrowSize, height: arrowSize))
            rightShadow.color = SKColor.black
            rightShadow.colorBlendFactor = 0.4
            rightShadow.alpha = 0.6
            rightShadow.position = CGPoint(x: 2, y: -2)
            rightShadow.zPosition = -1
            rightArrow.addChild(rightShadow)
            
            // Add glow effect using a white overlay
            let rightGlow = SKSpriteNode(texture: rightTexture, size: CGSize(width: arrowSize + 4, height: arrowSize + 4))
            rightGlow.color = SKColor.white
            rightGlow.colorBlendFactor = 0.3
            rightGlow.alpha = 0.5
            rightGlow.zPosition = -1
            rightArrow.addChild(rightGlow)
            
            addChild(rightArrow)
        }
    }
    
    private func setupTarget() {
        targetMahjong = MahjongTiles.randomTile(ofType: GameConstants.targetMahjongType) ?? MahjongTiles.allTiles[0]
    }
    
    private func startGame() {
        currentScore = 0
        lastSpawnTime = 0 // Will be initialized in update method
        gameStartTime = 0 // Will be initialized in update method
        
        // Start spawning mahjong tiles using update loop
        // We'll use the scene's update method instead of Timer for better performance
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // Initialize timers on first update
        if lastSpawnTime == 0 {
            lastSpawnTime = currentTime
            gameStartTime = currentTime
        }
        
        let difficulty = GameSettingsManager.shared.currentDifficulty
        let currentSpawnInterval = GameConstants.spawnInterval * difficulty.spawnIntervalMultiplier
        
        // Spawn mahjong at intervals
        if currentTime - lastSpawnTime >= currentSpawnInterval {
            if Double.random(in: 0...1) < 0.15 {
                spawnProp() // 15% chance to spawn a prop
            } else {
                spawnMahjong()
            }
            lastSpawnTime = currentTime
        }
        
        // Update catcher position
        updateCatcherPosition()
        
        // Check for missed target mahjongs
        checkMissedMahjongs()
    }
    
    private func checkMissedMahjongs() {
        // Find mahjongs that have fallen below the screen
        for child in children {
            if let mahjongNode = child as? SKNode, mahjongNode.physicsBody?.categoryBitMask == PhysicsCategory.mahjong {
                if mahjongNode.position.y < -50 {
                    if let mahjong = mahjongNode.userData?["mahjong"] as? GrabMj, mahjong.isTarget {
                        // Missed a target mahjong, reset combo
                        currentCombo = 0
                    }
                    mahjongNode.removeFromParent()
                }
            }
        }
    }
    
    // MARK: - Game Logic
    
    private func spawnMahjong() {
        // Increase target mahjong (Sticks) appearance rate by 30%
        // 30% chance to spawn target type, otherwise random
        let mahjong: GrabMj
        if Double.random(in: 0...1) < 0.3 {
            // Spawn target type (Sticks)
            mahjong = MahjongTiles.randomTile(ofType: GameConstants.targetMahjongType) ?? MahjongTiles.randomTile()
        } else {
            // Spawn random tile
            mahjong = MahjongTiles.randomTile()
        }
        var isDoubleScore = false
        
        // Randomly mark target mahjong as double score
        if mahjong.isTarget && Double.random(in: 0...1) < GameConstants.doubleScoreChance {
            isDoubleScore = true
        }
        
        let mahjongNode = createMahjongNode(mahjong: mahjong, isDoubleScore: isDoubleScore)
        
        // Calculate elapsed game time
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - gameStartTime
        
        // Determine if horizontal movement should be enabled
        let shouldMoveHorizontally = elapsedTime >= GameConstants.horizontalMovementStartTime
        
        // Random X position
        let margin: CGFloat = shouldMoveHorizontally ? 80 : 50 // Larger margin if moving horizontally
        let randomX = CGFloat.random(in: margin...(size.width - margin))
        mahjongNode.position = CGPoint(x: randomX, y: size.height + 50)
        
        addChild(mahjongNode)
        
        // Falling animation
        let difficulty = GameSettingsManager.shared.currentDifficulty
        var currentFallSpeed = GameConstants.fallSpeed * difficulty.fallSpeedMultiplier
        if isSlowMotionActive {
            currentFallSpeed *= 0.5
        }
        
        let fallDistance = size.height + 100
        let fallDuration = TimeInterval(fallDistance / currentFallSpeed)
        let fallAction = SKAction.moveBy(x: 0, y: -fallDistance, duration: fallDuration)
        fallAction.timingMode = .linear
        
        let removeAction = SKAction.removeFromParent()
        
        // Add horizontal movement only if enough time has passed
        if shouldMoveHorizontally {
            // Calculate current horizontal movement speed (increases by 10% every 5 seconds)
            // Speed increases step-wise: every 5 seconds, speed increases by 10% (duration decreases by 10%)
            // When reaching maximum speed, reset to initial speed (cycle)
            let timeSinceMovementStart = elapsedTime - GameConstants.horizontalMovementStartTime
            let totalCycles = Int(timeSinceMovementStart / GameConstants.speedIncreaseInterval)
            
            // Use modulo to create a cycle: when reaching max speed, reset to start
            let speedIncreaseCycles = totalCycles % GameConstants.speedCycleLength
            
            // Each cycle reduces duration by 10% (multiplies by 0.9)
            // After n cycles: speed = baseSpeed * (0.9 ^ n)
            let speedMultiplier = pow(1.0 - GameConstants.speedIncreaseRate, Double(speedIncreaseCycles))
            var currentHorizontalSpeed = GameConstants.horizontalMovementSpeed * speedMultiplier
            if isSlowMotionActive {
                currentHorizontalSpeed *= 2.0 // takes longer
            }
            
            // Calculate screen edges
            let leftEdge = margin
            let rightEdge = size.width - margin
            let distanceToLeftEdge = randomX - leftEdge
            let distanceToRightEdge = rightEdge - randomX
            let totalHorizontalDistance = rightEdge - leftEdge
            
            // Calculate movement speed in points per second
            // currentHorizontalSpeed is the time for one complete cycle (left to right and back)
            // So speed = totalDistance / time
            let horizontalSpeedPerSecond = totalHorizontalDistance / currentHorizontalSpeed
            
            // Calculate duration to reach each edge based on distance and speed
            let durationToRightEdge = distanceToRightEdge / horizontalSpeedPerSecond
            let durationToLeftEdge = distanceToLeftEdge / horizontalSpeedPerSecond
            
            // Random initial direction
            let startDirection = Bool.random()
            
            // Create movement pattern that bounces off screen edges
            let moveToRightEdge = SKAction.moveTo(x: rightEdge, duration: TimeInterval(durationToRightEdge))
            moveToRightEdge.timingMode = .easeInEaseOut
            
            let moveToLeftEdge = SKAction.moveTo(x: leftEdge, duration: TimeInterval(durationToLeftEdge))
            moveToLeftEdge.timingMode = .easeInEaseOut
            
            // Also create actions for full width movement (for continuous bouncing)
            let fullMoveToRight = SKAction.moveTo(x: rightEdge, duration: TimeInterval(totalHorizontalDistance / horizontalSpeedPerSecond))
            fullMoveToRight.timingMode = .easeInEaseOut
            
            let fullMoveToLeft = SKAction.moveTo(x: leftEdge, duration: TimeInterval(totalHorizontalDistance / horizontalSpeedPerSecond))
            fullMoveToLeft.timingMode = .easeInEaseOut
            
            // Create the horizontal pattern that bounces between edges
            let horizontalPattern: SKAction
            if startDirection {
                // Start moving right first
                // First move to right edge from current position, then bounce between edges
                horizontalPattern = SKAction.sequence([
                    moveToRightEdge,
                    SKAction.repeatForever(SKAction.sequence([fullMoveToLeft, fullMoveToRight]))
                ])
            } else {
                // Start moving left first
                // First move to left edge from current position, then bounce between edges
                horizontalPattern = SKAction.sequence([
                    moveToLeftEdge,
                    SKAction.repeatForever(SKAction.sequence([fullMoveToRight, fullMoveToLeft]))
                ])
            }
            
            // Run horizontal movement and vertical falling simultaneously
            mahjongNode.run(horizontalPattern, withKey: "horizontalMovement")
        }
        
        // Always run falling animation
        mahjongNode.run(SKAction.sequence([fallAction, removeAction]), withKey: "falling")
    }
    
    private func spawnProp() {
        let prop = GameProp.randomProp()
        let propNode = createPropNode(prop: prop)
        
        let margin: CGFloat = 50
        let randomX = CGFloat.random(in: margin...(size.width - margin))
        propNode.position = CGPoint(x: randomX, y: size.height + 50)
        
        addChild(propNode)
        
        let difficulty = GameSettingsManager.shared.currentDifficulty
        var currentFallSpeed = GameConstants.fallSpeed * difficulty.fallSpeedMultiplier
        if isSlowMotionActive {
            currentFallSpeed *= 0.5
        }
        
        let fallDistance = size.height + 100
        let fallDuration = TimeInterval(fallDistance / currentFallSpeed)
        let fallAction = SKAction.moveBy(x: 0, y: -fallDistance, duration: fallDuration)
        fallAction.timingMode = .easeIn
        
        let removeAction = SKAction.removeFromParent()
        propNode.run(SKAction.sequence([fallAction, removeAction]), withKey: "falling")
    }
    
    private func createPropNode(prop: GameProp) -> SKNode {
        let container = SKNode()
        let size: CGFloat = 50
        
        let bg = SKShapeNode(circleOfRadius: size / 2)
        bg.fillColor = prop.type.color.withAlphaComponent(0.8)
        bg.strokeColor = SKColor.white
        bg.lineWidth = 2
        container.addChild(bg)
        
        let label = SKLabelNode(fontNamed: "AppleColorEmoji")
        label.text = prop.type.emoji
        label.fontSize = 30
        label.verticalAlignmentMode = .center
        container.addChild(label)
        
        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        container.run(SKAction.repeatForever(pulse))
        
        container.physicsBody = SKPhysicsBody(circleOfRadius: size / 2)
        container.physicsBody?.isDynamic = true
        container.physicsBody?.categoryBitMask = PhysicsCategory.prop
        container.physicsBody?.contactTestBitMask = PhysicsCategory.catcher
        container.physicsBody?.collisionBitMask = 0
        
        container.userData = NSMutableDictionary()
        container.userData?["prop"] = prop.type.rawValue
        
        return container
    }
    
    private func createMahjongNode(mahjong: GrabMj, isDoubleScore: Bool = false) -> SKNode {
        guard let image = mahjong.grabImage else {
            return SKNode()
        }
        
        let texture = SKTexture(image: image)
        
        // Calculate size maintaining aspect ratio
        let width: CGFloat = 60
        let height = width / GameConstants.mahjongAspectRatio
        
        let spriteNode = SKSpriteNode(texture: texture, size: CGSize(width: width, height: height))
        
        // Create border with rounded corners
        let borderNode = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: GameConstants.mahjongCornerRadius)
        borderNode.fillColor = SKColor.clear
        borderNode.strokeColor = isDoubleScore ? SKColor.yellow : GameConstants.mahjongBorderColor
        borderNode.lineWidth = isDoubleScore ? GameConstants.mahjongBorderWidth + 2 : GameConstants.mahjongBorderWidth
        borderNode.zPosition = 1
        
        let container = SKNode()
        container.addChild(spriteNode)
        container.addChild(borderNode)
        
        // Add double score visual effects
        if isDoubleScore {
            // Add glowing effect
            let glowNode = SKShapeNode(rectOf: CGSize(width: width + 8, height: height + 8), cornerRadius: GameConstants.mahjongCornerRadius + 2)
            glowNode.fillColor = SKColor.clear
            glowNode.strokeColor = SKColor.yellow
            glowNode.lineWidth = 3
            glowNode.alpha = 0.8
            glowNode.zPosition = -1
            container.addChild(glowNode)
            
            // Add pulsing animation
            let pulseOut = SKAction.scale(to: 1.15, duration: 0.5)
            let pulseIn = SKAction.scale(to: 1.0, duration: 0.5)
            let pulse = SKAction.repeatForever(SKAction.sequence([pulseOut, pulseIn]))
            container.run(pulse, withKey: "pulse")
            
            // Add rotation animation
            let rotate = SKAction.rotate(byAngle: 0.1, duration: 0.3)
            let rotateBack = SKAction.rotate(byAngle: -0.1, duration: 0.3)
            let wiggle = SKAction.repeatForever(SKAction.sequence([rotate, rotateBack]))
            container.run(wiggle, withKey: "wiggle")
            
            // Add color flash animation for glow
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.5)
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.5)
            let flash = SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn]))
            glowNode.run(flash)
            
            // Add "2x" label
            let doubleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            doubleLabel.text = "2x"
            doubleLabel.fontSize = 16
            doubleLabel.fontColor = SKColor.yellow
            doubleLabel.position = CGPoint(x: 0, y: -height / 2 - 15)
            doubleLabel.zPosition = 2
            container.addChild(doubleLabel)
            
            // Animate the label
            let labelBounce = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 5, duration: 0.3),
                SKAction.moveBy(x: 0, y: -5, duration: 0.3)
            ])
            doubleLabel.run(SKAction.repeatForever(labelBounce))
        }
        
        // Physics body
        container.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
        container.physicsBody?.isDynamic = true
        container.physicsBody?.categoryBitMask = PhysicsCategory.mahjong
        container.physicsBody?.contactTestBitMask = PhysicsCategory.catcher
        container.physicsBody?.collisionBitMask = 0
        
        // Store mahjong data
        container.userData = NSMutableDictionary()
        container.userData?["mahjong"] = mahjong
        container.userData?["isDoubleScore"] = isDoubleScore
        
        return container
    }
    
    private func updateCatcherPosition() {
        var newX = catcher.position.x
        let deltaTime: CGFloat = 1.0 / 60.0 // Assume 60 FPS
        
        if isMovingLeft {
            newX -= GameConstants.movementSpeed * deltaTime
            newX = max(GameConstants.catcherWidth / 2 + GameConstants.screenMargin, newX)
        }
        
        if isMovingRight {
            newX += GameConstants.movementSpeed * deltaTime
            newX = min(size.width - GameConstants.catcherWidth / 2 - GameConstants.screenMargin, newX)
        }
        
        catcher.position.x = newX
    }
    
    private func handleMahjongCaught(_ mahjongNode: SKNode) {
        guard let mahjong = mahjongNode.userData?["mahjong"] as? GrabMj else { return }
        
        let isCorrect = mahjong.isTarget
        let isDoubleScore = mahjongNode.userData?["isDoubleScore"] as? Bool ?? false
        
        if isCorrect {
            currentCombo += 1
            var score = GameConstants.correctCatchScore
            if isDoubleScore {
                score *= 2 // Double the score
            }
            
            // Apply combo multiplier (max x5)
            let comboMultiplier = min(currentCombo, 5)
            score *= comboMultiplier
            
            currentScore += score
            showCatchAnimation(node: mahjongNode, isCorrect: true, isDoubleScore: isDoubleScore)
        } else {
            if hasShield {
                // Use shield to prevent combo reset and penalty
                hasShield = false
                showPropText("Shield Used!", color: .green, position: mahjongNode.position)
            } else {
                currentCombo = 0
                currentScore += GameConstants.wrongCatchPenalty
                showCatchAnimation(node: mahjongNode, isCorrect: false, isDoubleScore: false)
            }
        }
        
        mahjongNode.removeFromParent()
    }
    
    private func handlePropCaught(_ propNode: SKNode) {
        guard let propRaw = propNode.userData?["prop"] as? String,
              let propType = GamePropType(rawValue: propRaw) else { return }
        
        switch propType {
        case .magnet:
            activateMagnet()
            showPropText("Magnet Active!", color: .blue, position: propNode.position)
        case .slowMotion:
            activateSlowMotion()
            showPropText("Slow Motion!", color: .cyan, position: propNode.position)
        case .shield:
            hasShield = true
            showPropText("Shield Acquired!", color: .green, position: propNode.position)
        case .bomb:
            if hasShield {
                hasShield = false
                showPropText("Shield Blocked Bomb!", color: .green, position: propNode.position)
            } else {
                currentCombo = 0
                currentScore -= 20
                showPropText("BOMB! -20", color: .red, position: propNode.position)
            }
        }
        
        propNode.removeFromParent()
    }
    
    private func activateMagnet() {
        // Find all target mahjongs and move them to catcher
        for child in children {
            if let mahjongNode = child as? SKNode, mahjongNode.physicsBody?.categoryBitMask == PhysicsCategory.mahjong {
                if let mahjong = mahjongNode.userData?["mahjong"] as? GrabMj, mahjong.isTarget {
                    mahjongNode.removeAllActions()
                    let moveToCatcher = SKAction.move(to: CGPoint(x: catcher.position.x, y: catcher.position.y), duration: 0.2)
                    mahjongNode.run(moveToCatcher)
                }
            }
        }
    }
    
    private func activateSlowMotion() {
        isSlowMotionActive = true
        // Slow down all existing falling objects
        for child in children {
            if let action = child.action(forKey: "falling") {
                action.speed = 0.5
            }
            if let action = child.action(forKey: "horizontalMovement") {
                action.speed = 0.5
            }
        }
        
        // Reset after 5 seconds
        run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.run { [weak self] in
                self?.isSlowMotionActive = false
                // Restore speed
                if let children = self?.children {
                    for child in children {
                        if let action = child.action(forKey: "falling") {
                            action.speed = 1.0
                        }
                        if let action = child.action(forKey: "horizontalMovement") {
                            action.speed = 1.0
                        }
                    }
                }
            }
        ]))
    }
    
    private func showPropText(_ text: String, color: SKColor, position: CGPoint) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 24
        label.fontColor = color
        label.position = position
        label.zPosition = 15
        
        addChild(label)
        
        let action = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 50, duration: 1.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])
        label.run(action)
    }
    
    private func showCatchAnimation(node: SKNode, isCorrect: Bool, isDoubleScore: Bool = false) {
        // Particle effect using shape nodes
        let particleCount = isDoubleScore ? 25 : 15 // More particles for double score
        let particleColor = isDoubleScore ? SKColor.yellow : (isCorrect ? SKColor.green : SKColor.red)
        
        for i in 0..<particleCount {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(particleCount))
            let particle = SKShapeNode(circleOfRadius: isDoubleScore ? 6 : 4)
            particle.fillColor = particleColor
            particle.strokeColor = particleColor
            particle.position = node.position
            particle.zPosition = 20
            
            addChild(particle)
            
            let distance: CGFloat = isDoubleScore ? 70 : 50
            let moveX = cos(angle) * distance
            let moveY = sin(angle) * distance
            
            let moveAction = SKAction.moveBy(x: moveX, y: moveY, duration: GameConstants.particleEffectDuration)
            let fadeAction = SKAction.fadeOut(withDuration: GameConstants.particleEffectDuration)
            let removeAction = SKAction.removeFromParent()
            
            particle.run(SKAction.group([moveAction, fadeAction, removeAction]))
        }
        
        // Score popup
        let scoreValue = isCorrect ? (isDoubleScore ? GameConstants.correctCatchScore * 2 : GameConstants.correctCatchScore) : GameConstants.wrongCatchPenalty
        let scoreText = isCorrect ? (isDoubleScore ? "+\(scoreValue) (2x!)" : "+\(scoreValue)") : "\(scoreValue)"
        let scorePopup = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scorePopup.text = scoreText
        scorePopup.fontSize = isDoubleScore ? 42 : 36
        scorePopup.fontColor = isDoubleScore ? SKColor.yellow : (isCorrect ? SKColor.green : SKColor.red)
        scorePopup.position = node.position
        scorePopup.zPosition = 15
        
        addChild(scorePopup)
        
        let popupAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 50, duration: GameConstants.scoreAnimationDuration),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])
        scorePopup.run(popupAction)
    }
    
    private func animateScoreChange() {
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        scoreLabel.run(SKAction.sequence([scaleUp, scaleDown]))
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
            
            if node.name == "settingsButton" || (node.parent?.name == "settingsButton") {
                saveCurrentGame()
                let transition = SKTransition.fade(withDuration: 0.5)
                let settingsScene = SettingsScene(size: size)
                settingsScene.scaleMode = .aspectFill
                view?.presentScene(settingsScene, transition: transition)
                return
            }
            
            if node.name == "statisticsButton" || (node.parent?.name == "statisticsButton") {
                saveCurrentGame()
                let transition = SKTransition.fade(withDuration: 0.5)
                let statisticsScene = StatisticsScene(size: size)
                statisticsScene.scaleMode = .aspectFill
                view?.presentScene(statisticsScene, transition: transition)
                return
            }
            
            if node.name == "leftArrow" || (node.parent?.name == "leftArrow") {
                isMovingLeft = true
            }
            
            if node.name == "rightArrow" || (node.parent?.name == "rightArrow") {
                isMovingRight = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMovingLeft = false
        isMovingRight = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMovingLeft = false
        isMovingRight = false
    }
    
    private func saveCurrentGame() {
        if currentScore > 0 {
            let record = GameRecord(score: currentScore, maxCombo: maxCombo)
            GameDataManager.shared.saveRecord(record)
        }
    }
    
    private func returnToMenu() {
        saveCurrentGame()
        
        let transition = SKTransition.fade(withDuration: 0.5)
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = .aspectFill
        view?.presentScene(menuScene, transition: transition)
    }
}

// MARK: - Physics Categories

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let mahjong: UInt32 = 0b1
    static let catcher: UInt32 = 0b10
    static let prop: UInt32 = 0b100
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var mahjongNode: SKNode?
        var propNode: SKNode?
        var catcherNode: SKNode?
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.mahjong {
            mahjongNode = contact.bodyA.node
            if contact.bodyB.categoryBitMask == PhysicsCategory.catcher {
                catcherNode = contact.bodyB.node
            }
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.mahjong {
            mahjongNode = contact.bodyB.node
            if contact.bodyA.categoryBitMask == PhysicsCategory.catcher {
                catcherNode = contact.bodyA.node
            }
        }
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.prop {
            propNode = contact.bodyA.node
            if contact.bodyB.categoryBitMask == PhysicsCategory.catcher {
                catcherNode = contact.bodyB.node
            }
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.prop {
            propNode = contact.bodyB.node
            if contact.bodyA.categoryBitMask == PhysicsCategory.catcher {
                catcherNode = contact.bodyA.node
            }
        }
        
        if let mahjong = mahjongNode, let _ = catcherNode {
            handleMahjongCaught(mahjong)
        } else if let prop = propNode, let _ = catcherNode {
            handlePropCaught(prop)
        }
    }
}

