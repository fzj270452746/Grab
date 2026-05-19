//
//  InstructionsViewController.swift
//  Grab
//
//  Created by Zhao on 2025/12/27.
//

import UIKit

/// Game instructions view controller using UIKit
class InstructionsViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var backgroundImageView: UIImageView!
    private var overlayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayInstructions()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Background Image
        backgroundImageView = UIImageView(image: UIImage(named: "grabBackgroundImage"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.frame = view.bounds
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundImageView)
        
        // Overlay
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(GameConstants.overlayOpacity)
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(overlayView)
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "How to Play"
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 25) ?? UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Back Button
        let backButton = UIButton(type: .custom)
        backButton.backgroundColor = UIColor(white: 0.3, alpha: 0.8)
        backButton.layer.cornerRadius = 25
        backButton.layer.borderWidth = 2
        backButton.layer.borderColor = UIColor.white.cgColor
        backButton.setImage(createBackArrowImage(), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        // Scroll View
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Content View
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: GameConstants.screenMargin),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 50),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func createBackArrowImage() -> UIImage? {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        // Draw left arrow
        context.move(to: CGPoint(x: 12, y: 4))
        context.addLine(to: CGPoint(x: 4, y: 10))
        context.addLine(to: CGPoint(x: 12, y: 16))
        context.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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
            "Scoring & Combo",
            "• Catch Sticks tiles: +10 points",
            "• Glowing Sticks tiles: 2x score!",
            "• Catch consecutively to build Combo (up to 5x multiplier!)",
            "• Catch Character/Dots tiles: -5 points & lose combo",
            "",
            "Props & Hazards",
            "• 🧲 Magnet: Attracts target tiles",
            "• ⏱️ Slow Motion: Slows down time",
            "• 🛡️ Shield: Blocks one penalty/bomb",
            "• 💣 Bomb: -20 points & lose combo",
            "",
            "Tips",
            "• Don't let Sticks drop off the screen, or you lose combo!",
            "• Use Settings (⚙️) to change difficulty",
            "",
            "Good luck and have fun!"
        ]
        
        let leftMargin: CGFloat = 18
        let rightMargin: CGFloat = 18
        let lineSpacing: CGFloat = 18
        
        var lastView: UIView?
        
        for (index, instruction) in instructions.enumerated() {
            if instruction.isEmpty {
                // Add spacing for empty lines
                let spacer = UIView()
                spacer.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(spacer)
                
                if let lastView = lastView {
                    NSLayoutConstraint.activate([
                        spacer.topAnchor.constraint(equalTo: lastView.bottomAnchor),
                        spacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                        spacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                        spacer.heightAnchor.constraint(equalToConstant: lineSpacing / 2)
                    ])
                } else {
                    NSLayoutConstraint.activate([
                        spacer.topAnchor.constraint(equalTo: contentView.topAnchor),
                        spacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                        spacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                        spacer.heightAnchor.constraint(equalToConstant: lineSpacing / 2)
                    ])
                }
                lastView = spacer
                continue
            }
            
            let isTitle = instruction == "Game Objective" ||
                         instruction == "Controls" ||
                         instruction == "Scoring & Combo" ||
                         instruction == "Props & Hazards" ||
                         instruction == "Tips"
            
            let label = UILabel()
            label.text = instruction
            label.font = isTitle ?
                UIFont(name: "AvenirNext-Bold", size: 22) ?? UIFont.boldSystemFont(ofSize: 22) :
                UIFont(name: "AvenirNext-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
            label.textColor = isTitle ? .yellow : .white
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
            
            // Constraints
            if let lastView = lastView {
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: lineSpacing),
                    label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftMargin),
                    label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -rightMargin)
                ])
            } else {
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                    label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftMargin),
                    label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -rightMargin)
                ])
            }
            
            lastView = label
        }
        
        // Set bottom constraint for content view
        if let lastView = lastView {
            NSLayoutConstraint.activate([
                lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
        }
        
        // Fade in animation
        contentView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.contentView.alpha = 1
        }
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

