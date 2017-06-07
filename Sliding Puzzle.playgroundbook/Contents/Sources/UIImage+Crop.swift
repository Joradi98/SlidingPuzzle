//
//  UIImage+Crop.swift
//
//
//  Created by Johannes on 11.03.17.
//  Copyright © 2017 Johannes Raufeisen. All rights reserved.
//
import Foundation
import UIKit
import CoreImage

public enum ImageFilter {
    case none
    case blackWhite
    case sepia
}


extension UIImage {
    
    /**
     *   Receive the pieces at the position (x, y) (including (0,0)) counting from the left to the right and from bottom to top! Number of pieces refers to
     *   how many times each side gets cut
     **/
    func getPiece(x: Int, y: Int, numberOfPieces: Int) -> UIImage? {
        let completeRect = CGRect.init(x: 0, y: 0, width: self.size.width * self.scale, height: self.size.height * self.scale)
        
        let partWidth: CGFloat = completeRect.width / CGFloat(numberOfPieces)
        let partHeight: CGFloat = completeRect.height / CGFloat(numberOfPieces)
        
        if let piece = self.cgImage?.cropping(to: CGRect.init(x: partWidth * CGFloat(x), y: completeRect.height - partHeight * CGFloat(y+1), width: partWidth, height: partHeight)) {
            return UIImage.init(cgImage: piece)
        } else {
            return nil
        }
        
    }
    
    /// Creates a filtered image using one of the predefined cases (ImageFilter)
    func filtered(filter: ImageFilter) -> UIImage {
        switch filter {
        case .sepia:
            guard let filter = CIFilter(name: "CISepiaTone") else {return self}
            filter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
            filter.setValue(0.8, forKey: kCIInputIntensityKey)
            guard let outputImage = filter.outputImage else {return self}
            let ctx = CIContext(options:nil)
            guard let cgImage = ctx.createCGImage(outputImage, from: outputImage.extent) else {return self}
            return UIImage.init(cgImage: cgImage)
        case .blackWhite:
            guard let filter = CIFilter(name: "CIPhotoEffectTonal") else {return self}
            filter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
            guard let outputImage = filter.outputImage else {return self}
            let ctx = CIContext(options:nil)
            guard let cgImage = ctx.createCGImage(outputImage, from: outputImage.extent) else {return self}
            return UIImage.init(cgImage: cgImage)
            
        default:
            return self
        }
    }
    
}
