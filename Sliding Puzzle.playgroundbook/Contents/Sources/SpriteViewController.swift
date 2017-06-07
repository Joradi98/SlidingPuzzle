//
//  SpriteViewController.swift
//
//
//  Created by Johannes on 11.03.17.
//  Copyright © 2017 Johannes Raufeisen. All rights reserved.
//
import UIKit
import PlaygroundSupport
import SpriteKit
import Foundation

@objc(SpriteViewController)
public class SpriteViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {

    @IBOutlet var safeArea: UIView!
    @IBOutlet var gameContainer: SKView!
    @IBOutlet var puzzleImageView: UIImageView!
    @IBOutlet var backgroundImageView: UIImageView!

    
    public var scene: GameScene?

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLayoutConstraint.activate([
            safeArea.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 20),
            safeArea.bottomAnchor.constraint(equalTo: liveViewSafeAreaGuide.bottomAnchor),
            ])
    
        gameContainer.constrainToCenterOfParent(withAspectRatio: 1.0)
   
        //Border
        addBorder()
    }

    ///Adds a wooden border around the SKView
    fileprivate func addBorder() {
        guard let borderImage = UIImage.init(named: "Border") else {return}
        gameContainer.layer.borderWidth = 10
        gameContainer.layer.borderColor = UIColor.init(patternImage: borderImage).cgColor
    }
    
    ///Presents the scene as soon as it has been set. Size capped to range [2, 7]
    public func startGame(image: UIImage, parts: Int, filter: ImageFilter = .none) {
        scene = GameScene(size: view.bounds.size)
        scene?.imageFilter = filter
        //Cap to senseful values
        var cappedParts = max(parts, 2)
        cappedParts = min(cappedParts, 7)
        
        scene?.createPuzzle(image: image, parts: cappedParts)
        addBlur()

        gameContainer.presentScene(scene)

    }
    
    ///Adds a copy of the image in the background (+ blur overlay)
    public func addBlur() {
        guard let game = scene?.game else {return}
    
        
        backgroundImageView.image = game.image
        
      
        //Extra light Blurview
        let blurView = UIVisualEffectView.init(frame: view.frame)
        view.insertSubview(blurView, aboveSubview: backgroundImageView)
        blurView.effect = UIBlurEffect.init(style: .extraLight)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: blurView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView, attribute: .width, relatedBy: .equal, toItem: view, attribute:.width, multiplier: 1, constant: 0)
        ])


    }
    
    
    ///Adds a button at the top-right corner used for giving the next best move
    public func addHintButton() {
        guard let scene = self.scene else {return}
        
        let container = OverlayView(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        safeArea.addSubview(container)
        
        
        let hintButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        
        hintButton.setTitle("?", for: .normal)
        hintButton.setTitleColor(.red, for: .normal)
        hintButton.titleLabel?.font = UIFont.init(name: (hintButton.titleLabel?.font)!.fontName, size: (hintButton.titleLabel?.font)!.pointSize + 2)
        hintButton.addTarget(scene, action: #selector(GameScene.showNextMove) , for: .touchUpInside)
        container.addSubview(hintButton)
        
    }

    
   
}

public extension SpriteViewController {
    class func loadFromStoryboard() -> SpriteViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        return storyboard.instantiateInitialViewController() as! SpriteViewController
    }

}
