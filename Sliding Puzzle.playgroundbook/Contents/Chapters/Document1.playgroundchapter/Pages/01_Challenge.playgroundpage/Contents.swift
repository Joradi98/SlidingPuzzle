//#-hidden-code
//
//  Contents.swift
//
//  Copyright Johannes Raufeisen
//
//#-end-hidden-code
/*:
In this playground, you’ll configure your own sliding puzzle and learn how to let the computer help you in solving them.
 
**Goal:** Arrange the pieces in the right order, so that a complete picture shows up.
 
Run the code below in order to practice the game mechanics with an easy puzzle at the beginning. You can click on a single piece in the puzzle to move it.
 */

//#-hidden-code
import UIKit
import PlaygroundSupport

let gameController = SpriteViewController.loadFromStoryboard()
//#-end-hidden-code
let image = /*#-editable-code*/#imageLiteral(resourceName: "balloon.png")/*#-end-editable-code*/
let size = 2
//#-hidden-code
public func startGame() {
    gameController.startGame(image: image , parts: size)
}
//#-end-hidden-code
startGame()

//#-hidden-code
PlaygroundPage.current.liveView = gameController
//#-end-hidden-code




