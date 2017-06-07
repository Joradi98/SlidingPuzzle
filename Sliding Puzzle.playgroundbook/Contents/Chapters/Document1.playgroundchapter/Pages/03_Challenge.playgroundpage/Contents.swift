//#-hidden-code
//
//  Contents.swift
//
//  Copyright Johannes Raufeisen
//
//#-end-hidden-code
/*:
Use the power of Artificial intelligence and let the computer help you in solving more complex puzzles: When you tap on the "?" the AI will move a piece for you.

 **Goal:** Complete the function `isSolved()` that determines, whether the puzzle is currently solved. Every move will then be judged on how close it comes to this goal state.
 */
//#-hidden-code
import UIKit
import PlaygroundSupport

let gameController = SpriteViewController.loadFromStoryboard()
//#-end-hidden-code
//#-code-completion(everything, hide)
let image = /*#-editable-code*/#imageLiteral(resourceName: "balloon.png")/*#-end-editable-code*/
let filter = /*#-editable-code Choose a filter*/ImageFilter.none/*#-end-editable-code*/
let size = /*#-editable-code*/3/*#-end-editable-code*/ //Will be capped to range [2, 7]
//#-hidden-code
public func startGame() {
    gameController.startGame(image: image , parts: size, filter: filter)
}
//#-end-hidden-code

public func isSolved() -> Bool {
    //#-hidden-code
    //Setup for a better readability/usability on iPad
    guard let board = gameController.scene?.game?.board else {return false}
    let pieces = board.currentOrder.keys
    //#-end-hidden-code
    for piece in pieces {
        let currentPosition = board.currentOrder[piece]
        let correctPosition = board.correctOrder[piece]
        //#-code-completion(identifier, show, currentPosition, correctPosition)
        //#-code-completion(identifier, show, ==, !=, &&, ||, !)
        if /*#-editable-code*/<#T##Positions are not correct###>/*#-end-editable-code*/ {
            return false
        }
    }
    return true
}
startGame()
//#-hidden-code
gameController.scene?.game?.board.customSolveFunction = isSolved
PlaygroundPage.current.liveView = gameController
gameController.addHintButton()
//#-end-hidden-code
