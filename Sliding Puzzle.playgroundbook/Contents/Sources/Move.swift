//
//  Move.swift
//  AI_Testing
//
//  Created by Johannes on 15.03.17.
//  Copyright © 2017 Johannes Raufeisen. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

///Modelling a move on the board. Specify an existing SKSpriteNode to initialize it
public class Move: NSObject, GKGameModelUpdate {
    public var value: Int = 0
    public var movedPiece: SKSpriteNode
    
        
    init(movedPiece: SKSpriteNode) {
        self.movedPiece = movedPiece
    }
    
   
    
}
