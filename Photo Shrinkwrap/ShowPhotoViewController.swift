//
//  ShowPhotoViewController.swift
//  Photo Shrinkwrap
//
//  Created by Remus Lazar on 03.11.15.
//  Copyright © 2015 Remus Lazar. All rights reserved.
//

import UIKit
import Photos

class ShowPhotoViewController: UIViewController, PHPhotoLibraryChangeObserver {

    struct Constants {
        static let AdjustmentFormatIdentifier = "info.lazar.photo-resize"
        static let AdjustmentFormatVersion = "1.0"
    }
    
    struct ResizePresets {
        static let MegaPixelsForTag = [
            1: 0.134, // HVGA
            2: 0.48, // SVGA
            3: 2.0, // FHD
        ]
        static let jpegCompressionQuality: CGFloat = 0.85
    }
    
    // our model
    var photo: PHAsset!
    
    private let pim = PHImageManager()
    private var requestIdentifier: PHImageRequestID = 0
    
    private func fetchImage() {

        if (photo == nil) {
            imageView.image = nil
            loadingProgressView.hidden = true
            return
        }
        
        let options = PHImageRequestOptions()
        loadingProgressView.setProgress(0, animated: false)
        loadingProgressView.hidden = false
        options.progressHandler = { (progress, error, stop, info) in
            dispatch_async(dispatch_get_main_queue()) {
                self.loadingProgressView.progress = Float(progress)
            }
        }
        options.networkAccessAllowed = true
        requestIdentifier = pim.requestImageForAsset(photo, targetSize: self.imageView.bounds.size, contentMode: .AspectFill, options: options) {
            (image, info) -> Void in
            if !info![PHImageResultIsDegradedKey]!.boolValue {
                self.requestIdentifier = 0
                self.loadingProgressView.hidden = true
                self.title = "\(Int(image!.size.width)) x \(Int(image!.size.height))"
            }
            self.imageView.image = image
            self.imageView.clipsToBounds = true
            self.imageView.contentMode = .ScaleAspectFit
        }
    }
    
    private func resizeImage(megaPixel: Double) {
        
        let options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = { (adjustmentData) in
            return adjustmentData.formatIdentifier == Constants.AdjustmentFormatIdentifier
        }
        
        photo.requestContentEditingInputWithOptions(options) { (contentEditingInput, info) in
            let url = contentEditingInput!.fullSizeImageURL!
            let orientation = contentEditingInput!.fullSizeImageOrientation
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
            let contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput!)
            
            let jpegData = outputImage!.jpegRepresentationWithCompressionQuality(ResizePresets.jpegCompressionQuality)
            jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
            contentEditingOutput.adjustmentData = adjustmentData
            
            // perform the changes
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                let request = PHAssetChangeRequest(forAsset: self.photo)
                request.contentEditingOutput = contentEditingOutput
                }, completionHandler: { (success, _) in
                    if (!success) { print("PHAssetChangeRequest failed") }
            })
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingProgressView: UIProgressView!
    @IBAction func resizePhoto(sender: UIBarButtonItem) {
        // Note: we're using the sender.tag value to distinguish between the 3 options
        // 1: small, 2: medium, 3: large
        resizeImage(ResizePresets.MegaPixelsForTag[sender.tag]!)
    }
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBAction func handleDelete(sender: AnyObject) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            PHAssetChangeRequest.deleteAssets([self.photo])
            }) { (success, error) -> Void in
                if (!success) {
                    print("Deletion request for asset \(self.photo) failed")
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
        }
    }

    // MARK: - ViewController Life Cycle
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton.enabled = photo.canPerformEditOperation(.Delete)
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchImage()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        if requestIdentifier != 0 {
            // cancel a pending request if the view will go away
            pim.cancelImageRequest(requestIdentifier)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange) {
        if photo == nil { return }
        
        dispatch_async(dispatch_get_main_queue()) {
            if let changeDetails = changeInstance.changeDetailsForObject(self.photo) {
                if let photo = changeDetails.objectAfterChanges as? PHAsset {
                    self.photo = photo
                    if (changeDetails.assetContentChanged) {
                        self.fetchImage()
                    }
                } else {
                    self.photo = nil
                    self.fetchImage()
                }
            }
        }
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
