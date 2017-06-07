//#-hidden-code
//
//  Contents.swift
//
//  Copyright Johannes Raufeisen
//
//#-end-hidden-code
/*:
 Now let's customize the sliding puzzle. You can choose another **image** or even take a photo on your own.
 
 After you have selected a new image, choose one of the available **filters** to give your puzzle a unique look.
 
 * callout(Filter):
 
    The following filter types are available.
    - sepia
    - blackWhite
    - none
 */
//#-hidden-code
import UIKit
import PlaygroundSupport

let gameController = SpriteViewController.loadFromStoryboard()
//#-end-hidden-code
//#-code-completion(identifier, show, .none, .blackWhite, .sepia)
let image = /*#-editable-code*/#imageLiteral(resourceName: "Lake.png")/*#-end-editable-code*/
let filter = /*#-editable-code Choose a filter*/ImageFilter.blackWhite/*#-end-editable-code*/
let size = 2
//#-hidden-code
public func startGame() {
    gameController.startGame(image: image , parts: size, filter: filter)
}
//#-end-hidden-code
startGame()


//#-hidden-code
PlaygroundPage.current.liveView = gameController
//#-end-hidden-code
