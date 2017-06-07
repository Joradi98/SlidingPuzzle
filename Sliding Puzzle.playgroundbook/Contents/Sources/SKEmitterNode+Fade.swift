//
//  SKEmitterNode+Fade.swift
//  
//
//  Created by Johannes on 11.03.17.
//  Copyright © 2017 Johannes Raufeisen. All rights reserved.
//

import Foundation
import SpriteKit

extension SKEmitterNode {
    
    /**
    *   Exponentially decreases the birthrate
    *   removes the node from its parent afterwards.
    */
    func graduallyDecreaseBirthRate() {
        Timer.scheduledTimer(timeInterval: 0.09, target: self, selector: #selector(decreaseBirthRate(timer:)) , userInfo: self, repeats: true)
    }
    
    
    ///Helper method to decrease the birth rate each tick. (called by the timer)
    @objc fileprivate func decreaseBirthRate(timer: Timer) {
        guard let node = timer.userInfo as? SKEmitterNode else {timer.invalidate();return}
        node.particleBirthRate /= 2
        //Break condition: Cut the birth rate to 0, if it's small enough for a smooth transition
        if node.particleBirthRate < 30 {
            node.removeFromParent()
            timer.invalidate()
        }
    }
}
