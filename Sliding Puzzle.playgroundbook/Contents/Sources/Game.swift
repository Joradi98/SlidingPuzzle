//
//  Game.swift
//
//
//  Created by Johannes on 10.03.17.
//  Copyright © 2017 Johannes Raufeisen. All rights reserved.
//
import Foundation
import UIKit
import SpriteKit

///The state of the game. Used for distinguishing whether the puzzle is already solved
public enum State {
    case active
    case solved
}

public class Game: NSObject {
    ///The board used
    public var board: QuadraticGrid = QuadraticGrid.init(parts: 2)
    ///Current state
    public var state: State = .active
    //The image to use for the puzzle
    public var image: UIImage = UIImage.init(named: "balloon.png")!
    
    //Sounds
    
    public let slideSound = SKAction.playSoundFileNamed("Slide.m4a", waitForCompletion: false)
    public let successSound = SKAction.playSoundFileNamed("Success.mp3", waitForCompletion: false)
    
    ///Used by the -solveIDA() method in order to store the correct moves
    fileprivate var movesToSolve = [Move]()
    fileprivate static let found: Int = -1
    fileprivate static let notFound: Int = 9999
    
    
    init(parts: Int, image: UIImage) {
        super.init()
        self.board = QuadraticGrid.init(parts: parts)
        self.state = .active
        self.image = image
    }
    
    ///Checks, if the current puzzle is actually solvable.
    public func isSolvable() -> Bool {
        
        var currentOrder: [SKSpriteNode: Int] = [:]
        for (key, value) in board.currentOrder {
            currentOrder[key] = value.boardNumber(parts: board.parts)
        }
        var correctOrder: [SKSpriteNode: Int] = [:]
        for (key, value) in board.correctOrder {
            correctOrder[key] = value.boardNumber(parts: board.parts)
        }
        
        //Current board order
        var resultingOrder: [Int: Int] = [:]
        for node in currentOrder.keys {
            //This piece is at .. but should be at ...
            resultingOrder[currentOrder[node]!] = correctOrder[node]!
        }
        
        let usedPlaces = resultingOrder.keys.sorted()
        var result: [Int] = []
        for i in usedPlaces {
            result.append(resultingOrder[i]!)
        }
        
        //Counts the number of false pairs
        var disorder = 0
        
        //For every element
        for i in 0..<result.count {
            //Look at the lefthand elements
            for j in 0..<i {
                if result[j] > result[i] { disorder += 1 }
            }
        }
        //Only puzzles with an even disorder are solvable
        if board.parts % 2 == 0 {
            return (disorder + (board.parts - board.freePosition.y )) % 2 == 0
        } else {
            return disorder % 2 == 0
        }
    }
    
    /**
    *   Returns an array containing all the moves to successfully solve the puzzle (empty array, if no solution was found). Recommended for size <= 3x3.
    *   This method implements the Iterative Deepening A* algorithm.
    */
    public func solveIDA() -> [Move] {
        //Reset the last solution
        movesToSolve.removeAll()
        
        var bound: Int = board.computeManhattenDistance() + 2 * board.numberOfLinearConflicts()
        
        while true {
            let t = search(node: self.board, g: 0, bound: bound)

            if t == Game.found {
                return movesToSolve
            }
            if t == Game.notFound {
                return [Move]()
            }
            bound = t
        }
        
    }
    
    ///Helper method for the IDA* algorithm
    fileprivate func search(node: QuadraticGrid, g: Int, bound: Int ) -> Int {
        let f = g + node.computeManhattenDistance()
        if f > bound  {
            return f
        }
        
        if node.isSolved() {
            return Game.found
        }
        
        var min = Game.notFound
        
        guard let possibleMoves = node.gameModelUpdates(for: board.activePlayer!) as? [Move] else {return Game.notFound}
        for move in possibleMoves {
            let newState = node.copy() as! QuadraticGrid
            newState.apply(move)
            
            let t = search(node: newState, g: g + node.costToApplyNextState(), bound: bound)
            if t == Game.found {

                movesToSolve.insert(move, at: 0)
                return Game.found
            }
            
            if t < min {
                min = t
            }
            
            
        }
        return min
        
    }
    
    
   
    
    
    
    
}
