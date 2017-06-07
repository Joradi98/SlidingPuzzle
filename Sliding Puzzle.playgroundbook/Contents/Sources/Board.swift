//
//  Board.swift
//
//
//  Created by Johannes on 10.03.17.
//  Copyright © 2017 Johannes Raufeisen. All rights reserved.
//
import Foundation
import UIKit
import SpriteKit
import GameplayKit

/** Structure holding possible board locations. Pay attention to the way of counting.
 *  x from left to right including 0
 *  y from bottom to top including 0
 *  boardNumber from topLeft to bottomRight
 */
public struct GridPosition: Equatable {
    ///x from left to right
    var x: Int
    ///y from bottom to top
    var y: Int
    
    ///Checks, whether to gridPositions are directly next to each other (diagonals not counting)
    public func isAdjacentTo(otherPosition: GridPosition) -> Bool {
        let s1 = abs(Int((otherPosition.x - x)))
        let s2 = abs(Int((otherPosition.y - y)))
        
        if s1 + s2 == 1 {
            return true
        }
        
        return false
    }
    
    ///Two positions are equal, when their x and y values are equal
    public static func ==(lhs: GridPosition, rhs: GridPosition) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    ///Returns the number correspoding to the board position (counting from top left to bottom right)
    public func boardNumber(parts: Int) -> Int {
        return (x + 1) + (parts - y - 1) * parts
    }
    
    ///Calculates the manhattenDistance (i.e. the difference in x and y coordinates) between to positions on the board.
    public func manhattenDistance(to: GridPosition) -> Int {
        return abs(to.x - x) + abs(to.y - y)
    }
    
}

public class QuadraticGrid: NSObject {
    ///Indicates the amount of pieces in which each side is cut. The result will be a quadratic layout (parts x parts)
    public var parts: Int = 1
    ///Save the correct order of image pieces (left -> right, top -> bottom)
    public var correctOrder: [SKSpriteNode: GridPosition] = [:]
    ///The currently displayed image pieces and their positions
    public var currentOrder: [SKSpriteNode: GridPosition] = [:]
    ///The currently free place (there need to be one in order to make the puzzle solvable)
    public var freePosition = GridPosition(x: 99,y: 99) {
        willSet(newPosition) {
            lastFreePosition = freePosition
        }
    }
    ///The position which has been blank before the latest move. This is used to decrease the amount of senseful moves.
    var lastFreePosition = GridPosition(x: 99,y: 99)
    ///A custom function
    public var customSolveFunction: (() -> Bool)?
    
    init(parts: Int) {
        super.init()
        self.parts = parts
        
    }
    
    ///Returns the center of the single piece, at the given grid coordinates in the given global size
    public func centerOfPiece(position: GridPosition, globalSize: CGSize) -> CGPoint {
        let singleSize = CGSize.init(width: globalSize.width / CGFloat(parts), height: globalSize.height / CGFloat(parts) )

        let center = CGPoint(x: globalSize.width / CGFloat(parts) * CGFloat(position.x) + singleSize.width / 2, y: globalSize.height / CGFloat(parts) * CGFloat(position.y) + singleSize.height / 2)
        
        return center
        
    }
    
    ///Swaps the position on the board without any animation
    public func swapNodes(node1: SKSpriteNode, node2: SKSpriteNode) {
        guard let position1 = currentOrder[node1] else {return}
        guard let position2 = currentOrder[node2] else {return}
        let center1 = node1.position
        
        currentOrder[node1] = position2
        node1.position = node2.position
        
        currentOrder[node2] = position1
        node2.position = center1
        
    }
    
    //Two board are considered equal, if there currnet layout is the same
    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherBoard = object as? QuadraticGrid else {return false}
        return currentOrder == otherBoard.currentOrder
    }
    
    ///Heuristic: Manhattan distance of all pieces
    public func computeManhattenDistance() -> Int {
        var manhattenDistance = 0
        for (piece, current) in currentOrder {
            guard let desired = correctOrder[piece] else {print("euhm..!?");return 0}
            manhattenDistance += current.manhattenDistance(to: desired)
        }
    
        return manhattenDistance

    }
    
    ///Heursitic: Number of linear conflicts within the puzzle
    public func numberOfLinearConflicts() -> Int {
        var num = 0
        for (piece1, current1) in currentOrder {
            for (piece2, current2) in currentOrder {
                //Skip equal pairs
                if current1 == current2 {
                    continue
                }
                
                guard let correct1 = correctOrder[piece1] else {return 0}
                guard let correct2 = correctOrder[piece2] else {return 0}

                //same line
                if current1.y == current2.y && correct1.y == correct2.y {
                    //Left <-> Right
                    if (current1.x - current2.x) * (correct1.x - correct2.x) < 0 {
                        num += 1
                    }
                    
                    
                }
                
                
            }
        }
    
        return num
    }
    
    ///Moving an adjacent piece "costs" 1 turn
    public func costToApplyNextState() -> Int {
        return 1
    }
    
}

///Conforming to the NSCopying protocol as required for using the GKGameModel
extension QuadraticGrid: NSCopying {
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy: QuadraticGrid = QuadraticGrid.init(parts: parts)
        copy.setGameModel(self)
        return copy
    }
    
    public override func copy() -> Any {
        let copy: QuadraticGrid = QuadraticGrid.init(parts: parts)
        copy.setGameModel(self)
        return copy
    }
    
}


extension QuadraticGrid: GKGameModel {
    
    public var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    public var activePlayer: GKGameModelPlayer? {
        return Player.allPlayers.first
    }
    
    ///As this is only a single player game, check if the puzzle is solved
    public func isWin(for player: GKGameModelPlayer) -> Bool {
        return isSolved()
    }
    
    public func isSolved() -> Bool {
        //Use the overwritten function
        if let customFunction = customSolveFunction {
            return customFunction()
        }
        //Elseway, use the default implementation
        //Check, if the pieces are at the right places
        for node in currentOrder.keys {
            if currentOrder[node] != correctOrder[node] {
                return false
            }
        }
        return true
    }
    
    public func isLoss(for player: GKGameModelPlayer) -> Bool {
        //You can't lose in a Singleplayer puzzle
        return false
    }
    
    public func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        guard let playerObject = player as? Player else {return nil}
        
        //No moves to be made, when the game is won (ie. puzzle solved)
        if isWin(for: playerObject) {
            return nil
        }
        
        var moves = [Move]()
        
        //All pieces near the freePosition can be moved except the one that has been moved last round
        for (piece, position) in currentOrder {
            if position.isAdjacentTo(otherPosition: freePosition) && position != lastFreePosition {
                moves.append(Move.init(movedPiece: piece))
            }
        }
        //Return possible moves
        return moves
    }
    
    public func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? QuadraticGrid {
            currentOrder = board.currentOrder
            correctOrder = board.correctOrder
            freePosition = board.freePosition
            lastFreePosition = board.lastFreePosition
            parts = board.parts
        }
    }
    
    ///Applies a move to the board, causing a change in the current order
    public func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard let move = gameModelUpdate as? Move else {return}
        guard let piecePosition = currentOrder[move.movedPiece] else {return}
        
        lastFreePosition = freePosition
        currentOrder[move.movedPiece] = freePosition
        freePosition = piecePosition
    }
    

    public func score(for player: GKGameModelPlayer) -> Int {
        //Score includes manhatten distance and linear conflicts
        return -( computeManhattenDistance() + 2 * numberOfLinearConflicts() )
    }
}

