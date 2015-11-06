//
//  PhotoResizeEngine.swift
//  Shrinkwrap
//
//  Created by Remus Lazar on 06.11.15.
//  Copyright © 2015 Remus Lazar. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PhotoResizeEngine {

    struct Constants {
        static let AdjustmentFormatIdentifier = "info.lazar.photo-resize"
        static let AdjustmentFormatVersion = "1.0"
    }
    
    struct ResizePresets {
        static let MegaPixelsForPreset = [
            1: 0.134, // HVGA
            2: 0.48, // SVGA
            3: 2.0, // FHD
        ]
        static let jpegCompressionQuality: CGFloat = 0.85
    }
    
    class func canHandleAdjustmentData(adjustmentData: PHAdjustmentData) -> Bool {
        return adjustmentData.formatIdentifier == Constants.AdjustmentFormatIdentifier
    }
    
    class func resizeImageForPreset(preset: Int, contentEditingInput: PHContentEditingInput) -> PHContentEditingOutput {
        
        let megaPixel = ResizePresets.MegaPixelsForPreset[preset]!
        
        let url = contentEditingInput.fullSizeImageURL!
        let orientation = contentEditingInput.fullSizeImageOrientation
        let inputImage = CIImage(contentsOfURL: url)!
        
        // scale the image to the desired resolution
        let scale = sqrt(CGFloat(megaPixel * 1_000_000) / (inputImage.extent.height * inputImage.extent.width))
        
        let filter = CIFilter(
            name: "CILanczosScaleTransform",
            withInputParameters: [
                kCIInputImageKey: inputImage.imageByApplyingOrientation(orientation),
                kCIInputScaleKey: scale,
                kCIInputAspectRatioKey: 1.0
            ])
        let outputImage = filter!.outputImage
        let adjustmentData = PHAdjustmentData(
            formatIdentifier: Constants.AdjustmentFormatIdentifier,
            formatVersion: Constants.AdjustmentFormatVersion,
            data: "\(megaPixel)".dataUsingEncoding(NSUTF8StringEncoding)!)
        let contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
        
        let jpegData = outputImage!.jpegRepresentationWithCompressionQuality(ResizePresets.jpegCompressionQuality)
        jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
        contentEditingOutput.adjustmentData = adjustmentData
        
        return contentEditingOutput
    }
    
}

extension CIImage {
    func jpegRepresentationWithCompressionQuality(quality: CGFloat) -> NSData {
        let eaglContext = EAGLContext(API: .OpenGLES2)
        let ciContext = CIContext(EAGLContext: eaglContext)
        //let ciContext = CIContext(options: [kCIContextUseSoftwareRenderer: false])
        let outputImageRef = ciContext.createCGImage(self, fromRect: self.extent)
        let uiImage = UIImage(CGImage: outputImageRef, scale: 1.0, orientation: .Up)
        return UIImageJPEGRepresentation(uiImage, quality)!
    }
}
