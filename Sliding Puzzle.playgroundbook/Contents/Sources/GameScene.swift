//
//  GameScene.swift
//
//
//  Created by Johannes on 10.03.17.
//  Copyright © 2017 Johannes Raufeisen. All rights reserved.
//
import SpriteKit
import GameplayKit
import UIKit
import Foundation

public class GameScene: SKScene {
    
    public var imageFilter: ImageFilter = .none
    public var game: Game?
    
    //Strategist for determining the probably best move
    var strategist = GKMinmaxStrategist()

    override public func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = SKColor.clear
        
    }
    
    ///Creates the puzzle leaving one place on the board free
    public func createPuzzle(image: UIImage, parts: Int) {
        let newGame = Game.init(parts: parts, image: image)
        self.game = newGame
        
        let singleSize = CGSize.init(width: size.width / CGFloat(parts), height: size.height / CGFloat(parts) )
        var positions: [GridPosition] = []
        var omittedNode: SKSpriteNode?
        
        //Fill the positions and correct order with ALL possible locations on the grid
        for x in 0..<parts {
            for y in 0..<parts {
                var pieceImage = image.getPiece(x: x, y: y, numberOfPieces: parts)!
                pieceImage = pieceImage.filtered(filter: imageFilter)
                let pieceTexture = SKTexture(image: pieceImage)
                
                let pieceNode = SKSpriteNode(texture: pieceTexture)
                pieceNode.scale(to: singleSize )
                let correctPosition = GridPosition(x: x,y: y)
                positions.append( correctPosition )
                newGame.board.correctOrder[pieceNode] = correctPosition
                
                //The last (bottom right) part of the original image will be omitted
                if x == parts - 1 && y == 0 {
                    omittedNode = pieceNode
                }
            }
        }
        
        //Randomize the order
        positions.randomize()
        
        //Display and arrange the pieces except for one!
        let nodeArray = Array.init(newGame.board.correctOrder.keys)
        for i in 0..<nodeArray.count {
            let pieceNode = nodeArray[i]
            let randomPlace = positions[i]
            
            //The last (bottom right) part of the original image is left blank
            if pieceNode != omittedNode {
                pieceNode.position = newGame.board.centerOfPiece(position: randomPlace, globalSize: size)
                addChild(pieceNode)
                newGame.board.currentOrder[pieceNode] = randomPlace
            } else {
                //One piece must be omitted (bottom right)
                newGame.board.freePosition = randomPlace
            }
        }
        
         //Swap 2 pieces until the puzzle is solvable and not already solved
         while newGame.isSolvable() == false || newGame.board.isSolved() {
            guard let node1 = Array(newGame.board.currentOrder.keys).randomElement() else {break}
            guard let node2 = Array(newGame.board.currentOrder.keys).randomElement() else {break}
            newGame.board.swapNodes(node1: node1, node2: node2)
         }
   
        
        //After setting up the puzzle, configure the GKMinmaxStrategist
        configureAI()
    }

    fileprivate func configureAI() {
        guard let game = self.game else {return}
        strategist = GKMinmaxStrategist()
        strategist.maxLookAheadDepth = 7
        strategist.randomSource = GKARC4RandomSource()
        strategist.gameModel = game.board
    }
    
    ///Adds the missing image piece
    public func completePuzzle(completion: (() -> Void)? = nil) {
        guard let game = self.game else {return}
        guard game.state == .active else {return}
        guard let pieceImage = game.image.getPiece(x: game.board.freePosition.x , y: game.board.freePosition.y, numberOfPieces: game.board.parts) else {return}
        
        let pieceTexture = SKTexture(image: pieceImage.filtered(filter: imageFilter))
        let pieceNode = SKSpriteNode(texture: pieceTexture)
        let singleSize = CGSize.init(width: size.width / CGFloat(game.board.parts), height: size.height / CGFloat(game.board.parts) )
        
        pieceNode.scale(to: singleSize )
        pieceNode.position = QuadraticGrid.init(parts: game.board.parts).centerOfPiece(position: game.board.freePosition, globalSize: size)
        pieceNode.alpha = 0.0
        addChild(pieceNode)
        pieceNode.run(SKAction.fadeIn(withDuration: 0.4)) {
            completion?()
        }
        
    }
    

    
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let game = self.game else {return}
        guard game.state == .active else {return}
        guard let touchLocation = touches.first?.location(in: self) else {return}
        guard let selectedNode = self.nodes(at: touchLocation).first as? SKSpriteNode else {return}
        guard let nodePosition = game.board.currentOrder[selectedNode] else {return}
        
        //Only move the image piece, if there is enough space
        if nodePosition.isAdjacentTo(otherPosition: game.board.freePosition) {
            let newCenter = QuadraticGrid.init(parts: game.board.parts).centerOfPiece(position: game.board.freePosition, globalSize: size)
            let moveAction = SKAction.move(to: newCenter, duration: 0.3)
            moveAction.timingMode = .easeInEaseOut
            
            //Move the image piece and update the current order
            selectedNode.run(SKAction.group([moveAction, game.slideSound])) {
                self.checkForFinish()
            }
            
            game.board.currentOrder[selectedNode] = game.board.freePosition
            game.board.freePosition = nodePosition
            
        }
    }
    
    ///Checks, if the puzzle has been solved successfully
    fileprivate func checkForFinish() {
        guard let game = self.game else {return}
        
        //Check, if the pieces are at the right places
        for node in game.board.currentOrder.keys {
            if game.board.currentOrder[node] != game.board.correctOrder[node] {
                return
            }
        }
        
        //Completely display the puzzle and show the success animation
        completePuzzle() {
            if game.state != .solved {
                game.state = .solved
                self.run(game.successSound)
                self.addFinishAnimation()

            }
        }
    }
    
    ///Adds star particles around the image for indicating success in solving the puzzle
    fileprivate func addFinishAnimation() {
        //Distance to the border of scene
        let borderDistance = CGFloat(20)
        let path = "StarParticles.sks"
        
        //For each side, add a new emittingnode (with different angle and position)
        guard let emitterTop = SKEmitterNode.init(fileNamed: path) else {return}
        emitterTop.position = CGPoint.init(x: size.width / 2, y: size.height - borderDistance)
        emitterTop.particlePositionRange = CGVector.init(dx: size.width, dy: 0);
        emitterTop.targetNode = self
        emitterTop.emissionAngle = CGFloat.pi * CGFloat(3/2)
        
        guard let emitterDown = SKEmitterNode.init(fileNamed: path) else {return}
        emitterDown.position = CGPoint.init(x: size.width / 2, y: borderDistance)
        emitterDown.particlePositionRange = CGVector.init(dx: size.width, dy: 0);
        emitterDown.targetNode = self
        emitterDown.emissionAngle = CGFloat.pi * CGFloat(1/2)
        
        guard let emitterLeft = SKEmitterNode.init(fileNamed: path) else {return}
        emitterLeft.position = CGPoint.init(x: borderDistance, y: size.height / 2)
        emitterLeft.particlePositionRange = CGVector.init(dx: 0, dy: size.height);
        emitterLeft.targetNode = self
        emitterLeft.emissionAngle = CGFloat.pi * CGFloat(0/2)
        
        
        guard let emitterRight = SKEmitterNode.init(fileNamed: path) else {return}
        emitterRight.position = CGPoint.init(x: size.width  - borderDistance, y: size.height / 2)
        emitterRight.particlePositionRange = CGVector.init(dx: 0, dy: size.height);
        emitterRight.targetNode = self
        emitterRight.emissionAngle = CGFloat.pi * CGFloat(2/2)
        
        //Add them to the scene
        addChild(emitterTop)
        addChild(emitterDown)
        addChild(emitterLeft)
        addChild(emitterRight)
        
        //Exponential decay => removing the nodes
        for node in [emitterTop, emitterDown, emitterRight, emitterLeft] {
            node.graduallyDecreaseBirthRate()
        }
    }
    
    
    ///Executes the move that is currently considered the best one
    @objc public func showNextMove() {
        guard let game = self.game else {return}
        
        
        //Use the IDA* for sufficiently small puzzles
        if game.board.parts < 4 {
            guard let nextStep = game.solveIDA().first else {return}
            
            let newCenter = game.board.centerOfPiece(position: game.board.freePosition, globalSize: size)
            let moveAction = SKAction.move(to: newCenter, duration: 0.3)
            moveAction.timingMode = .easeInEaseOut
            
            //Move the image piece and update the current order
            nextStep.movedPiece.run(SKAction.group([moveAction, game.slideSound])) {
                self.checkForFinish()
            }
            
            
            //Apply
            game.board.apply(nextStep)

        } else {
            DispatchQueue.global().async { [unowned self] in
                guard let game = self.game else {return}
                guard let aiMove = self.strategist.bestMove(for: game.board.activePlayer!) as? Move else {return}
                let newCenter = game.board.centerOfPiece(position: game.board.freePosition, globalSize: self.size)
                let moveAction = SKAction.move(to: newCenter, duration: 0.3)
                moveAction.timingMode = .easeInEaseOut
                
                DispatchQueue.main.sync {
                    
                    //Move the image piece and update the current order
                    aiMove.movedPiece.run(SKAction.group([moveAction, game.slideSound])) {
                        self.checkForFinish()
                    }
                    //Apply
                    game.board.apply(aiMove)
                    
                }
                
                
            }

        }
        
        
    }
    
    
}

