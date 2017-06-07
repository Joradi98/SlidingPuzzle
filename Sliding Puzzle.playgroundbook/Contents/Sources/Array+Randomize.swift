//
//  ArrayExtension.swift
//  Blob It
//
//  Created by Johannes on 08.05.16.
//  Copyright © 2016 Johannes Raufeisen. All rights reserved.
//

import Foundation

extension Array {
    
    /**
     Puts the given array into a randomized order. Only senseful, if array is non-empty
     */
    mutating func randomize() {
        guard self.count > 0 else {print("Can't randomize empty array");return }
        for _ in 0...30 {
            //Get random index and corresponding item
            let randomIndex = Int(arc4random_uniform(UInt32(self.count)))
            let randomItem = self[randomIndex]
            
            //Remove it and put it to the end
            self.remove(at: randomIndex)
            self.append(randomItem)
        }
    }
    /**
     Returns a randomized copy of the given array.
     */
    func randomizedCopy() -> Array {
        var arrayCopy = self
        arrayCopy.randomize()
        
        return arrayCopy
        
    }
    
    /**
     Get random element from the array. Returns nil, if the array is empty.
    */
    func randomElement() -> Element? {
        guard self.count > 0 else {print("Can't get a random element from an empty array");return nil}
        let randomIndex = Int(arc4random_uniform(UInt32(self.count)))
        let randomItem = self[randomIndex]
        return randomItem
    }
    
  
    
}
