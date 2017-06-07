//
//  Player.swift
//  AI_Testing
//
//  Created by Johannes on 15.03.17.
//  Copyright © 2017 Johannes Raufeisen. All rights reserved.
//

import Foundation
import GameplayKit

///Modelling exisitng players. As this is a single player game there is only one possible player.
class Player: NSObject, GKGameModelPlayer {
    var playerId: Int = 0
    static var allPlayers = [Player()]

}
