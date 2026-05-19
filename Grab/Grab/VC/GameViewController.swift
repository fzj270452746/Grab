
import UIKit
import SpriteKit
import SDWebImage
import Fdocuts
//import AppTrackingTransparency

class GameViewController: UIViewController {
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            ATTrackingManager.requestTrackingAuthorization {_ in }
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Create SKView
        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)
        
        let vpianes = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        vpianes!.view.tag = 807
        vpianes?.view.frame = UIScreen.main.bounds
        view.addSubview(vpianes!.view)
        
        
        // Configure SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        // Create and present menu scene
        let scene = MenuScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        
        Saicet.shared.start { connected in
            if connected {
//                let uses = ControleurPartie()
//                uses.view.frame = self.view.bounds
                
                _ = SpielEngine()
                Saicet.shared.stop()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Support all orientations for better device compatibility
        return .portrait
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Update scene size when orientation changes
        if let skView = view.subviews.first as? SKView,
           let scene = skView.scene {
            scene.size = size
            scene.scaleMode = .aspectFill
        }
    }
}

